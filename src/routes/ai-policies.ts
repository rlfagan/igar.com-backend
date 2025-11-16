import { Router, Request, Response } from 'express';
import { pool } from '../db/connection';

const router = Router();

// GET all AI catalog policies
router.get('/', async (req: Request, res: Response) => {
  try {
    const result = await pool.query(`
      SELECT
        id, name, slug, description,
        approved_models, approved_tools, approved_oss, approved_datasets,
        denied_models, denied_tools, denied_oss, denied_datasets, denied_use_cases,
        review_models, review_tools, review_oss, review_datasets, review_use_cases,
        is_active, is_default, version,
        created_at, updated_at
      FROM ai_catalog_policies
      WHERE is_active = true
      ORDER BY is_default DESC, created_at DESC
    `);

    res.json({
      success: true,
      policies: result.rows,
    });
  } catch (error) {
    console.error('Error fetching AI catalog policies:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch AI catalog policies',
    });
  }
});

// GET single AI catalog policy by ID
router.get('/:id', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    const result = await pool.query(`
      SELECT
        id, name, slug, description,
        approved_models, approved_tools, approved_oss, approved_datasets,
        denied_models, denied_tools, denied_oss, denied_datasets, denied_use_cases,
        review_models, review_tools, review_oss, review_datasets, review_use_cases,
        is_active, is_default, version,
        created_at, updated_at
      FROM ai_catalog_policies
      WHERE id = $1
    `, [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Policy not found',
      });
    }

    res.json({
      success: true,
      policy: result.rows[0],
    });
  } catch (error) {
    console.error('Error fetching AI catalog policy:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch AI catalog policy',
    });
  }
});

// POST create new AI catalog policy
router.post('/', async (req: Request, res: Response) => {
  const client = await pool.connect();

  try {
    const { name, description, approved, denied, review, use_case_restrictions } = req.body;

    if (!name) {
      return res.status(400).json({
        success: false,
        message: 'Policy name is required',
      });
    }

    // Generate slug from name
    const slug = name
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/^-|-$/g, '');

    // Check if slug already exists
    const existingPolicy = await client.query(
      'SELECT id FROM ai_catalog_policies WHERE slug = $1',
      [slug]
    );

    if (existingPolicy.rows.length > 0) {
      return res.status(400).json({
        success: false,
        message: 'A policy with this name already exists',
      });
    }

    // Start transaction
    await client.query('BEGIN');

    const result = await client.query(`
      INSERT INTO ai_catalog_policies (
        name, slug, description,
        approved_models, approved_tools, approved_oss, approved_datasets,
        denied_models, denied_tools, denied_oss, denied_datasets, denied_use_cases,
        review_models, review_tools, review_oss, review_datasets, review_use_cases
      ) VALUES (
        $1, $2, $3,
        $4, $5, $6, $7,
        $8, $9, $10, $11, $12,
        $13, $14, $15, $16, $17
      )
      RETURNING *
    `, [
      name,
      slug,
      description || '',
      approved?.models || [],
      approved?.tools || [],
      approved?.oss || [],
      approved?.datasets || [],
      denied?.models || [],
      denied?.tools || [],
      denied?.oss || [],
      denied?.datasets || [],
      denied?.use_cases || [],
      review?.models || [],
      review?.tools || [],
      review?.oss || [],
      review?.datasets || [],
      review?.use_cases || [],
    ]);

    const policyId = result.rows[0].id;

    // Save use case restrictions if provided
    if (use_case_restrictions && Array.isArray(use_case_restrictions)) {
      for (const restriction of use_case_restrictions) {
        const { itemId, mode, allowedUseCases, deniedUseCases } = restriction;

        // Determine category from the item ID being in which list
        let category = 'model';
        if (approved?.tools?.includes(itemId) || denied?.tools?.includes(itemId) || review?.tools?.includes(itemId)) {
          category = 'tool';
        } else if (approved?.oss?.includes(itemId) || denied?.oss?.includes(itemId) || review?.oss?.includes(itemId)) {
          category = 'oss';
        } else if (approved?.datasets?.includes(itemId) || denied?.datasets?.includes(itemId) || review?.datasets?.includes(itemId)) {
          category = 'dataset';
        }

        await client.query(`
          INSERT INTO policy_resource_restrictions (
            policy_id, resource_id, resource_category, approval_status,
            use_case_restriction_mode, allowed_use_cases, denied_use_cases
          ) VALUES ($1, $2, $3, $4, $5, $6, $7)
        `, [
          policyId,
          itemId,
          category,
          'approved', // Only approved items have restrictions
          mode,
          mode === 'whitelist' ? allowedUseCases : [],
          mode === 'blacklist' ? deniedUseCases : [],
        ]);
      }
    }

    await client.query('COMMIT');

    res.status(201).json({
      success: true,
      message: 'AI catalog policy created successfully',
      policy: result.rows[0],
    });
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Error creating AI catalog policy:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create AI catalog policy',
    });
  } finally {
    client.release();
  }
});

// PUT update existing AI catalog policy
router.put('/:id', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const { name, description, approved, denied, review } = req.body;

    // Fetch existing policy
    const existing = await pool.query(
      'SELECT * FROM ai_catalog_policies WHERE id = $1',
      [id]
    );

    if (existing.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Policy not found',
      });
    }

    const result = await pool.query(`
      UPDATE ai_catalog_policies
      SET
        name = COALESCE($1, name),
        description = COALESCE($2, description),
        approved_models = COALESCE($3, approved_models),
        approved_tools = COALESCE($4, approved_tools),
        approved_oss = COALESCE($5, approved_oss),
        approved_datasets = COALESCE($6, approved_datasets),
        denied_models = COALESCE($7, denied_models),
        denied_tools = COALESCE($8, denied_tools),
        denied_oss = COALESCE($9, denied_oss),
        denied_datasets = COALESCE($10, denied_datasets),
        denied_use_cases = COALESCE($11, denied_use_cases),
        review_models = COALESCE($12, review_models),
        review_tools = COALESCE($13, review_tools),
        review_oss = COALESCE($14, review_oss),
        review_datasets = COALESCE($15, review_datasets),
        review_use_cases = COALESCE($16, review_use_cases),
        version = version + 1,
        updated_at = CURRENT_TIMESTAMP
      WHERE id = $17
      RETURNING *
    `, [
      name,
      description,
      approved?.models,
      approved?.tools,
      approved?.oss,
      approved?.datasets,
      denied?.models,
      denied?.tools,
      denied?.oss,
      denied?.datasets,
      denied?.use_cases,
      review?.models,
      review?.tools,
      review?.oss,
      review?.datasets,
      review?.use_cases,
      id,
    ]);

    res.json({
      success: true,
      message: 'AI catalog policy updated successfully',
      policy: result.rows[0],
    });
  } catch (error) {
    console.error('Error updating AI catalog policy:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update AI catalog policy',
    });
  }
});

// DELETE AI catalog policy
router.delete('/:id', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    const result = await pool.query(
      'DELETE FROM ai_catalog_policies WHERE id = $1 RETURNING id',
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Policy not found',
      });
    }

    res.json({
      success: true,
      message: 'AI catalog policy deleted successfully',
    });
  } catch (error) {
    console.error('Error deleting AI catalog policy:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete AI catalog policy',
    });
  }
});

export default router;
