import { Router, Request, Response } from 'express';
import pool from '../db';
import { performAIReview, getReviewBySubmissionId } from '../services/aiReview';
import { z } from 'zod';

const router = Router();

// Validation schema
const submissionSchema = z.object({
  // Section 1
  project_name: z.string().min(1),
  model_name: z.string().min(1),
  model_type: z.string().min(1),
  model_type_other: z.string().optional(),
  model_origin: z.string().min(1),
  model_origin_name: z.string().optional(),
  model_origin_version: z.string().optional(),
  model_origin_url: z.string().optional(),
  vendor_name: z.string().optional(),

  // Section 2
  intended_purpose: z.string().min(1),
  business_impact_category: z.string().min(1),
  regulated_decisions: z.array(z.string()),
  human_in_loop: z.boolean(),

  // Section 3
  data_sources: z.string().min(1),
  contains_customer_data: z.string().min(1),
  labels_modified: z.boolean(),
  labels_description: z.string().optional(),

  // Section 4
  modifications: z.array(z.string()),
  training_config_location: z.string().optional(),

  // Section 5
  deployment_location: z.string().min(1),
  deployment_location_other: z.string().optional(),
  access_teams: z.string().optional(),
  input_format: z.string().optional(),
  output_format: z.string().optional(),

  // Section 6
  sees_sensitive_data: z.string().min(1),
  safety_features: z.array(z.string()),
  known_risks: z.string().optional(),

  // Section 7
  artifacts: z.array(z.number()).optional(),
});

// Create a new submission
router.post('/', async (req: Request, res: Response) => {
  try {
    // Validate input
    const validatedData = submissionSchema.parse(req.body);

    // Insert submission
    const query = `
      INSERT INTO submissions (
        user_id, project_name, model_name, model_type, model_type_other,
        model_origin, model_origin_name, model_origin_version, model_origin_url,
        vendor_name, intended_purpose, business_impact_category, regulated_decisions,
        human_in_loop, data_sources, contains_customer_data, labels_modified,
        labels_description, modifications, training_config_location, deployment_location,
        deployment_location_other, access_teams, input_format, output_format,
        sees_sensitive_data, safety_features, known_risks, status
      ) VALUES (
        $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16,
        $17, $18, $19, $20, $21, $22, $23, $24, $25, $26, $27, $28, $29
      ) RETURNING id
    `;

    const values = [
      (req as any).user?.id || 1, // TODO: Get from auth middleware
      validatedData.project_name,
      validatedData.model_name,
      validatedData.model_type,
      validatedData.model_type_other,
      validatedData.model_origin,
      validatedData.model_origin_name,
      validatedData.model_origin_version,
      validatedData.model_origin_url,
      validatedData.vendor_name,
      validatedData.intended_purpose,
      validatedData.business_impact_category,
      JSON.stringify(validatedData.regulated_decisions),
      validatedData.human_in_loop,
      validatedData.data_sources,
      validatedData.contains_customer_data,
      validatedData.labels_modified,
      validatedData.labels_description,
      JSON.stringify(validatedData.modifications),
      validatedData.training_config_location,
      validatedData.deployment_location,
      validatedData.deployment_location_other,
      validatedData.access_teams,
      validatedData.input_format,
      validatedData.output_format,
      validatedData.sees_sensitive_data,
      JSON.stringify(validatedData.safety_features),
      validatedData.known_risks,
      'submitted',
    ];

    const result = await pool.query(query, values);
    const submissionId = result.rows[0].id;

    // Associate uploaded artifacts with this submission
    if (validatedData.artifacts && validatedData.artifacts.length > 0) {
      const updateArtifactsQuery = 'UPDATE artifacts SET submission_id = $1 WHERE id = ANY($2)';
      await pool.query(updateArtifactsQuery, [submissionId, validatedData.artifacts]);
    }

    // Trigger AI review asynchronously
    performAIReview({
      id: submissionId,
      ...validatedData,
    }).catch((error) => {
      console.error('AI Review failed for submission', submissionId, error);
    });

    res.status(201).json({
      success: true,
      submissionId,
      message: 'Submission created successfully. AI review in progress.',
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ success: false, errors: error.errors });
    }
    console.error('Submission error:', error);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// Get all submissions
router.get('/', async (req: Request, res: Response) => {
  try {
    const { status, limit = 50, offset = 0 } = req.query;

    let query = 'SELECT * FROM submissions';
    const values: any[] = [];

    if (status) {
      query += ' WHERE status = $1';
      values.push(status);
    }

    query += ' ORDER BY created_at DESC LIMIT $' + (values.length + 1) + ' OFFSET $' + (values.length + 2);
    values.push(limit, offset);

    const result = await pool.query(query, values);

    res.json({
      success: true,
      submissions: result.rows,
      total: result.rowCount,
    });
  } catch (error) {
    console.error('Get submissions error:', error);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// Get a specific submission
router.get('/:id', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    const submissionQuery = 'SELECT * FROM submissions WHERE id = $1';
    const submissionResult = await pool.query(submissionQuery, [id]);

    if (submissionResult.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Submission not found' });
    }

    const submission = submissionResult.rows[0];

    // Get AI review
    const review = await getReviewBySubmissionId(parseInt(id));

    // Get artifacts
    const artifactsQuery = 'SELECT * FROM artifacts WHERE submission_id = $1';
    const artifactsResult = await pool.query(artifactsQuery, [id]);

    // Get model metadata if available
    let modelMetadata = null;
    if (submission.model_origin_name) {
      const modelQuery = 'SELECT * FROM ref_models WHERE name = $1 LIMIT 1';
      const modelResult = await pool.query(modelQuery, [submission.model_origin_name]);
      if (modelResult.rows.length > 0) {
        modelMetadata = modelResult.rows[0];
      }
    }

    res.json({
      success: true,
      submission,
      review,
      artifacts: artifactsResult.rows,
      modelMetadata,
    });
  } catch (error) {
    console.error('Get submission error:', error);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// Update submission status
router.patch('/:id/status', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    if (!['submitted', 'under_review', 'approved', 'approved_with_conditions', 'denied'].includes(status)) {
      return res.status(400).json({ success: false, message: 'Invalid status' });
    }

    const query = 'UPDATE submissions SET status = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2 RETURNING *';
    const result = await pool.query(query, [status, id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Submission not found' });
    }

    res.json({
      success: true,
      submission: result.rows[0],
    });
  } catch (error) {
    console.error('Update status error:', error);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// Get review for a submission
router.get('/:id/review', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const review = await getReviewBySubmissionId(parseInt(id));

    if (!review) {
      return res.status(404).json({ success: false, message: 'Review not found' });
    }

    res.json({
      success: true,
      review,
    });
  } catch (error) {
    console.error('Get review error:', error);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

export default router;
