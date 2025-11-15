import { Router, Request, Response } from 'express';
import pool from '../db';
import { z } from 'zod';
import { calculateModificationClassRisk } from '../services/governanceRiskScoring';

const router = Router();

/**
 * GET /api/governance/modification-classes
 * Get all modification classes with their requirements
 */
router.get('/modification-classes', async (req: Request, res: Response) => {
  try {
    const result = await pool.query(
      'SELECT * FROM modification_classes ORDER BY class_number ASC'
    );

    res.json({
      success: true,
      modification_classes: result.rows,
    });
  } catch (error) {
    console.error('Get modification classes error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch modification classes' });
  }
});

/**
 * GET /api/governance/modification-classes/:classNumber
 * Get detailed information about a specific modification class
 */
router.get('/modification-classes/:classNumber', async (req: Request, res: Response) => {
  try {
    const { classNumber } = req.params;

    const [classResult, rolesResult] = await Promise.all([
      pool.query(
        'SELECT * FROM modification_classes WHERE class_number = $1',
        [classNumber]
      ),
      pool.query(
        `SELECT gr.* FROM governance_roles gr
         WHERE $1 = ANY(gr.required_for_classes)
         ORDER BY gr.role_name`,
        [classNumber]
      )
    ]);

    if (classResult.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Modification class not found' });
    }

    res.json({
      success: true,
      modification_class: classResult.rows[0],
      required_roles: rolesResult.rows,
    });
  } catch (error) {
    console.error('Get modification class error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch modification class' });
  }
});

/**
 * POST /api/governance/submissions/:submissionId/calculate-risk
 * Calculate risk score for a submission based on modification class
 */
router.post('/submissions/:submissionId/calculate-risk', async (req: Request, res: Response) => {
  try {
    const { submissionId } = req.params;

    // Get submission data
    const submissionResult = await pool.query(
      'SELECT * FROM submissions WHERE id = $1',
      [submissionId]
    );

    if (submissionResult.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Submission not found' });
    }

    const submission = submissionResult.rows[0];

    if (!submission.modification_class && submission.modification_class !== 0) {
      return res.status(400).json({
        success: false,
        message: 'Modification class must be set before calculating risk'
      });
    }

    // Calculate risk
    const riskResult = await calculateModificationClassRisk(
      parseInt(submissionId),
      submission.modification_class,
      submission
    );

    res.json({
      success: true,
      risk_calculation: riskResult,
    });
  } catch (error) {
    console.error('Calculate risk error:', error);
    res.status(500).json({ success: false, message: 'Failed to calculate risk' });
  }
});

/**
 * POST /api/governance/submissions/:submissionId/approvals
 * Create governance approval request
 */
router.post('/submissions/:submissionId/approvals', async (req: Request, res: Response) => {
  try {
    const { submissionId } = req.params;
    const schema = z.object({
      role_id: z.number(),
      approver_user_id: z.number().optional(),
      comments: z.string().optional(),
    });

    const data = schema.parse(req.body);

    const result = await pool.query(
      `INSERT INTO governance_approvals
       (submission_id, role_id, approver_user_id, approval_status, comments)
       VALUES ($1, $2, $3, 'pending', $4)
       RETURNING *`,
      [submissionId, data.role_id, data.approver_user_id, data.comments]
    );

    res.status(201).json({
      success: true,
      approval: result.rows[0],
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ success: false, errors: error.errors });
    }
    console.error('Create approval error:', error);
    res.status(500).json({ success: false, message: 'Failed to create approval' });
  }
});

/**
 * PUT /api/governance/approvals/:approvalId
 * Update approval status
 */
router.put('/approvals/:approvalId', async (req: Request, res: Response) => {
  try {
    const { approvalId } = req.params;
    const schema = z.object({
      approval_status: z.enum(['approved', 'rejected', 'needs_info']),
      comments: z.string().optional(),
      evidence_reviewed: z.array(z.string()).optional(),
      conditions: z.string().optional(),
    });

    const data = schema.parse(req.body);

    const result = await pool.query(
      `UPDATE governance_approvals
       SET approval_status = $1,
           comments = $2,
           evidence_reviewed = $3,
           conditions = $4,
           approval_date = CURRENT_TIMESTAMP,
           updated_at = CURRENT_TIMESTAMP
       WHERE id = $5
       RETURNING *`,
      [
        data.approval_status,
        data.comments,
        data.evidence_reviewed,
        data.conditions,
        approvalId
      ]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Approval not found' });
    }

    // Check if all approvals are complete
    const submission_id = result.rows[0].submission_id;
    await checkAllApprovalsComplete(submission_id);

    res.json({
      success: true,
      approval: result.rows[0],
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ success: false, errors: error.errors });
    }
    console.error('Update approval error:', error);
    res.status(500).json({ success: false, message: 'Failed to update approval' });
  }
});

/**
 * GET /api/governance/submissions/:submissionId/approvals
 * Get all approvals for a submission
 */
router.get('/submissions/:submissionId/approvals', async (req: Request, res: Response) => {
  try {
    const { submissionId } = req.params;

    const result = await pool.query(
      `SELECT ga.*, gr.role_name, gr.role_description, u.full_name as approver_name
       FROM governance_approvals ga
       JOIN governance_roles gr ON ga.role_id = gr.id
       LEFT JOIN users u ON ga.approver_user_id = u.id
       WHERE ga.submission_id = $1
       ORDER BY ga.created_at ASC`,
      [submissionId]
    );

    res.json({
      success: true,
      approvals: result.rows,
    });
  } catch (error) {
    console.error('Get approvals error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch approvals' });
  }
});

/**
 * POST /api/governance/submissions/:submissionId/evidence
 * Upload governance evidence
 */
router.post('/submissions/:submissionId/evidence', async (req: Request, res: Response) => {
  try {
    const { submissionId } = req.params;
    const schema = z.object({
      evidence_type: z.string(),
      evidence_category: z.string().optional(),
      file_path: z.string(),
      metadata: z.any().optional(),
    });

    const data = schema.parse(req.body);

    const result = await pool.query(
      `INSERT INTO governance_evidence
       (submission_id, evidence_type, evidence_category, file_path, metadata, uploaded_by)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING *`,
      [
        submissionId,
        data.evidence_type,
        data.evidence_category,
        data.file_path,
        data.metadata ? JSON.stringify(data.metadata) : null,
        (req as any).user?.id || 1
      ]
    );

    res.status(201).json({
      success: true,
      evidence: result.rows[0],
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ success: false, errors: error.errors });
    }
    console.error('Upload evidence error:', error);
    res.status(500).json({ success: false, message: 'Failed to upload evidence' });
  }
});

/**
 * POST /api/governance/submissions/:submissionId/conformity-assessment
 * Create or update conformity assessment
 */
router.post('/submissions/:submissionId/conformity-assessment', async (req: Request, res: Response) => {
  try {
    const { submissionId } = req.params;
    const schema = z.object({
      assessment_type: z.enum(['self_assessment', 'third_party', 'notified_body']),
      assessor_name: z.string(),
      assessor_organization: z.string().optional(),
      general_description: z.string().optional(),
      intended_purpose: z.string().optional(),
      risk_management_system: z.any().optional(),
      data_governance_measures: z.any().optional(),
      technical_documentation: z.any().optional(),
      transparency_provisions: z.any().optional(),
      human_oversight_measures: z.any().optional(),
      accuracy_robustness_measures: z.any().optional(),
      conformity_status: z.enum(['conformant', 'non_conformant', 'conditional', 'pending']).optional(),
      non_conformities: z.array(z.string()).optional(),
      remediation_plan: z.string().optional(),
    });

    const data = schema.parse(req.body);

    const result = await pool.query(
      `INSERT INTO conformity_assessments
       (submission_id, assessment_type, assessor_name, assessor_organization,
        general_description, intended_purpose, risk_management_system,
        data_governance_measures, technical_documentation, transparency_provisions,
        human_oversight_measures, accuracy_robustness_measures, conformity_status,
        non_conformities, remediation_plan, assessment_date)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, CURRENT_TIMESTAMP)
       RETURNING *`,
      [
        submissionId,
        data.assessment_type,
        data.assessor_name,
        data.assessor_organization,
        data.general_description,
        data.intended_purpose,
        data.risk_management_system ? JSON.stringify(data.risk_management_system) : null,
        data.data_governance_measures ? JSON.stringify(data.data_governance_measures) : null,
        data.technical_documentation ? JSON.stringify(data.technical_documentation) : null,
        data.transparency_provisions ? JSON.stringify(data.transparency_provisions) : null,
        data.human_oversight_measures ? JSON.stringify(data.human_oversight_measures) : null,
        data.accuracy_robustness_measures ? JSON.stringify(data.accuracy_robustness_measures) : null,
        data.conformity_status || 'pending',
        data.non_conformities,
        data.remediation_plan
      ]
    );

    res.status(201).json({
      success: true,
      assessment: result.rows[0],
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ success: false, errors: error.errors });
    }
    console.error('Create conformity assessment error:', error);
    res.status(500).json({ success: false, message: 'Failed to create conformity assessment' });
  }
});

/**
 * POST /api/governance/submissions/:submissionId/incidents
 * Report an AI incident
 */
router.post('/submissions/:submissionId/incidents', async (req: Request, res: Response) => {
  try {
    const { submissionId } = req.params;
    const schema = z.object({
      incident_type: z.string(),
      severity: z.enum(['minor', 'major', 'critical']),
      description: z.string(),
      affected_users: z.number().optional(),
      harm_caused: z.string().optional(),
    });

    const data = schema.parse(req.body);

    const result = await pool.query(
      `INSERT INTO ai_incidents
       (submission_id, incident_date, incident_type, severity, description,
        affected_users, harm_caused, status, reported_by)
       VALUES ($1, CURRENT_TIMESTAMP, $2, $3, $4, $5, $6, 'open', $7)
       RETURNING *`,
      [
        submissionId,
        data.incident_type,
        data.severity,
        data.description,
        data.affected_users,
        data.harm_caused,
        (req as any).user?.id || 1
      ]
    );

    // If critical, notify authorities (placeholder - implement actual notification)
    if (data.severity === 'critical') {
      console.log(`CRITICAL INCIDENT REPORTED: Submission ${submissionId}`);
      // TODO: Implement EU AI Act Article 62 notification
    }

    res.status(201).json({
      success: true,
      incident: result.rows[0],
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ success: false, errors: error.errors });
    }
    console.error('Report incident error:', error);
    res.status(500).json({ success: false, message: 'Failed to report incident' });
  }
});

/**
 * Helper function to check if all approvals are complete
 */
async function checkAllApprovalsComplete(submissionId: number) {
  const result = await pool.query(
    `SELECT COUNT(*) as total,
            SUM(CASE WHEN approval_status = 'approved' THEN 1 ELSE 0 END) as approved,
            SUM(CASE WHEN approval_status = 'rejected' THEN 1 ELSE 0 END) as rejected
     FROM governance_approvals
     WHERE submission_id = $1`,
    [submissionId]
  );

  const stats = result.rows[0];

  if (stats.total > 0) {
    if (stats.approved === stats.total) {
      // All approved - update submission status
      await pool.query(
        `UPDATE submissions
         SET status = 'approved', reviewed_at = CURRENT_TIMESTAMP
         WHERE id = $1`,
        [submissionId]
      );
    } else if (parseInt(stats.rejected) > 0) {
      // Any rejection - mark as denied
      await pool.query(
        `UPDATE submissions
         SET status = 'denied', reviewed_at = CURRENT_TIMESTAMP
         WHERE id = $1`,
        [submissionId]
      );
    }
  }
}

export default router;
