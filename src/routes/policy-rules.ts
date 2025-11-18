import { Router, Request, Response } from 'express';
import pool from '../db';
import { authenticateToken, requireAdmin, AuthRequest } from '../middleware/auth';

const router = Router();

// All routes require authentication
router.use(authenticateToken);

/**
 * GET /api/policies/:policyId/rules
 * Get all rules for a specific policy
 */
router.get('/:policyId/rules', async (req: AuthRequest, res: Response) => {
  try {
    const { policyId } = req.params;

    const result = await pool.query(
      `SELECT pr.*,
              u1.full_name as created_by_name,
              u2.full_name as updated_by_name,
              array_agg(DISTINCT d.name) FILTER (WHERE d.name IS NOT NULL) as department_names
       FROM policy_rules pr
       LEFT JOIN users u1 ON pr.created_by = u1.id
       LEFT JOIN users u2 ON pr.updated_by = u2.id
       LEFT JOIN departments d ON d.id = ANY(pr.department_ids)
       WHERE pr.policy_id = $1
       GROUP BY pr.id, u1.full_name, u2.full_name
       ORDER BY pr.priority DESC, pr.created_at DESC`,
      [policyId]
    );

    res.json({
      success: true,
      rules: result.rows,
    });
  } catch (error) {
    console.error('Error fetching policy rules:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch policy rules' });
  }
});

/**
 * GET /api/policies/:policyId/rules/:ruleId
 * Get a specific rule
 */
router.get('/:policyId/rules/:ruleId', async (req: AuthRequest, res: Response) => {
  try {
    const { policyId, ruleId } = req.params;

    const result = await pool.query(
      `SELECT pr.*,
              u1.full_name as created_by_name,
              u2.full_name as updated_by_name,
              array_agg(DISTINCT d.name) FILTER (WHERE d.name IS NOT NULL) as department_names
       FROM policy_rules pr
       LEFT JOIN users u1 ON pr.created_by = u1.id
       LEFT JOIN users u2 ON pr.updated_by = u2.id
       LEFT JOIN departments d ON d.id = ANY(pr.department_ids)
       WHERE pr.id = $1 AND pr.policy_id = $2
       GROUP BY pr.id, u1.full_name, u2.full_name`,
      [ruleId, policyId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Rule not found' });
    }

    res.json({
      success: true,
      rule: result.rows[0],
    });
  } catch (error) {
    console.error('Error fetching policy rule:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch policy rule' });
  }
});

/**
 * POST /api/policies/:policyId/rules
 * Create a new rule (admin only)
 */
router.post('/:policyId/rules', requireAdmin, async (req: AuthRequest, res: Response) => {
  try {
    const { policyId } = req.params;
    const {
      name,
      description,
      action,
      priority,
      is_active,
      conditions,
      department_ids,
      stop_on_match,
      custom_message,
    } = req.body;

    // Validate required fields
    if (!name || !action || !conditions) {
      return res.status(400).json({
        success: false,
        message: 'Name, action, and conditions are required',
      });
    }

    // Validate action
    if (!['approve', 'deny', 'review'].includes(action)) {
      return res.status(400).json({
        success: false,
        message: 'Action must be one of: approve, deny, review',
      });
    }

    // Validate conditions format
    if (!Array.isArray(conditions)) {
      return res.status(400).json({
        success: false,
        message: 'Conditions must be an array',
      });
    }

    const result = await pool.query(
      `INSERT INTO policy_rules (
        policy_id, name, description, action, priority, is_active,
        conditions, department_ids, stop_on_match, custom_message,
        created_by, updated_by
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $11)
      RETURNING *`,
      [
        policyId,
        name,
        description || null,
        action,
        priority || 0,
        is_active !== false,
        JSON.stringify(conditions),
        department_ids || [],
        stop_on_match !== false,
        custom_message || null,
        req.user?.id,
      ]
    );

    res.status(201).json({
      success: true,
      message: 'Policy rule created successfully',
      rule: result.rows[0],
    });
  } catch (error) {
    console.error('Error creating policy rule:', error);
    res.status(500).json({ success: false, message: 'Failed to create policy rule' });
  }
});

/**
 * PUT /api/policies/:policyId/rules/:ruleId
 * Update an existing rule (admin only)
 */
router.put('/:policyId/rules/:ruleId', requireAdmin, async (req: AuthRequest, res: Response) => {
  try {
    const { policyId, ruleId } = req.params;
    const {
      name,
      description,
      action,
      priority,
      is_active,
      conditions,
      department_ids,
      stop_on_match,
      custom_message,
    } = req.body;

    // Check if rule exists
    const existingRule = await pool.query(
      'SELECT id FROM policy_rules WHERE id = $1 AND policy_id = $2',
      [ruleId, policyId]
    );

    if (existingRule.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Rule not found' });
    }

    // Build dynamic update query
    const updates: string[] = [];
    const values: any[] = [];
    let paramCount = 1;

    if (name !== undefined) {
      updates.push(`name = $${paramCount++}`);
      values.push(name);
    }
    if (description !== undefined) {
      updates.push(`description = $${paramCount++}`);
      values.push(description);
    }
    if (action !== undefined) {
      if (!['approve', 'deny', 'review'].includes(action)) {
        return res.status(400).json({
          success: false,
          message: 'Action must be one of: approve, deny, review',
        });
      }
      updates.push(`action = $${paramCount++}`);
      values.push(action);
    }
    if (priority !== undefined) {
      updates.push(`priority = $${paramCount++}`);
      values.push(priority);
    }
    if (is_active !== undefined) {
      updates.push(`is_active = $${paramCount++}`);
      values.push(is_active);
    }
    if (conditions !== undefined) {
      if (!Array.isArray(conditions)) {
        return res.status(400).json({
          success: false,
          message: 'Conditions must be an array',
        });
      }
      updates.push(`conditions = $${paramCount++}`);
      values.push(JSON.stringify(conditions));
    }
    if (department_ids !== undefined) {
      updates.push(`department_ids = $${paramCount++}`);
      values.push(department_ids);
    }
    if (stop_on_match !== undefined) {
      updates.push(`stop_on_match = $${paramCount++}`);
      values.push(stop_on_match);
    }
    if (custom_message !== undefined) {
      updates.push(`custom_message = $${paramCount++}`);
      values.push(custom_message);
    }

    if (updates.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'No fields to update',
      });
    }

    // Add updated_by and updated_at
    updates.push(`updated_by = $${paramCount++}`);
    values.push(req.user?.id);
    updates.push('updated_at = CURRENT_TIMESTAMP');

    // Add WHERE clause parameters
    values.push(ruleId, policyId);

    const result = await pool.query(
      `UPDATE policy_rules
       SET ${updates.join(', ')}
       WHERE id = $${paramCount++} AND policy_id = $${paramCount++}
       RETURNING *`,
      values
    );

    res.json({
      success: true,
      message: 'Policy rule updated successfully',
      rule: result.rows[0],
    });
  } catch (error) {
    console.error('Error updating policy rule:', error);
    res.status(500).json({ success: false, message: 'Failed to update policy rule' });
  }
});

/**
 * DELETE /api/policies/:policyId/rules/:ruleId
 * Delete a rule (admin only)
 */
router.delete('/:policyId/rules/:ruleId', requireAdmin, async (req: AuthRequest, res: Response) => {
  try {
    const { policyId, ruleId } = req.params;

    const result = await pool.query(
      'DELETE FROM policy_rules WHERE id = $1 AND policy_id = $2 RETURNING id',
      [ruleId, policyId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Rule not found' });
    }

    res.json({
      success: true,
      message: 'Policy rule deleted successfully',
    });
  } catch (error) {
    console.error('Error deleting policy rule:', error);
    res.status(500).json({ success: false, message: 'Failed to delete policy rule' });
  }
});

/**
 * POST /api/policies/:policyId/rules/:ruleId/toggle
 * Toggle rule active status (admin only)
 */
router.post('/:policyId/rules/:ruleId/toggle', requireAdmin, async (req: AuthRequest, res: Response) => {
  try {
    const { policyId, ruleId } = req.params;

    const result = await pool.query(
      `UPDATE policy_rules
       SET is_active = NOT is_active, updated_by = $1, updated_at = CURRENT_TIMESTAMP
       WHERE id = $2 AND policy_id = $3
       RETURNING *`,
      [req.user?.id, ruleId, policyId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Rule not found' });
    }

    res.json({
      success: true,
      message: `Rule ${result.rows[0].is_active ? 'activated' : 'deactivated'} successfully`,
      rule: result.rows[0],
    });
  } catch (error) {
    console.error('Error toggling policy rule:', error);
    res.status(500).json({ success: false, message: 'Failed to toggle policy rule' });
  }
});

export default router;
