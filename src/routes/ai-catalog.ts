import { Router, Request, Response } from 'express';
import { pool } from '../db/connection';

const router = Router();

// GET all catalog items (with optional filtering)
router.get('/', async (req: Request, res: Response) => {
  try {
    const { category, provider, search, active_only } = req.query;

    let query = 'SELECT * FROM ai_catalog_items WHERE 1=1';
    const params: any[] = [];
    let paramCount = 1;

    if (category) {
      query += ` AND category = $${paramCount}`;
      params.push(category);
      paramCount++;
    }

    if (provider) {
      query += ` AND provider = $${paramCount}`;
      params.push(provider);
      paramCount++;
    }

    if (active_only === 'true') {
      query += ` AND is_active = true`;
    }

    if (search) {
      query += ` AND (
        name ILIKE $${paramCount} OR
        provider ILIKE $${paramCount} OR
        description ILIKE $${paramCount} OR
        catalog_id ILIKE $${paramCount}
      )`;
      params.push(`%${search}%`);
      paramCount++;
    }

    query += ' ORDER BY category, provider, name';

    const result = await pool.query(query, params);

    res.json({
      success: true,
      items: result.rows,
      count: result.rows.length,
    });
  } catch (error) {
    console.error('Error fetching catalog items:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch catalog items',
    });
  }
});

// GET single catalog item by ID
router.get('/:id', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    const result = await pool.query(
      'SELECT * FROM ai_catalog_items WHERE id = $1',
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Catalog item not found',
      });
    }

    res.json({
      success: true,
      item: result.rows[0],
    });
  } catch (error) {
    console.error('Error fetching catalog item:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch catalog item',
    });
  }
});

// POST create new catalog item
router.post('/', async (req: Request, res: Response) => {
  try {
    const {
      catalog_id,
      name,
      provider,
      category,
      description,
      tags,
      version,
      license,
      homepage_url,
      documentation_url,
    } = req.body;

    if (!catalog_id || !name || !category) {
      return res.status(400).json({
        success: false,
        message: 'catalog_id, name, and category are required',
      });
    }

    // Check for duplicates
    const existingItem = await pool.query(
      'SELECT id FROM ai_catalog_items WHERE catalog_id = $1',
      [catalog_id]
    );

    if (existingItem.rows.length > 0) {
      return res.status(409).json({
        success: false,
        message: `Catalog item with ID "${catalog_id}" already exists`,
      });
    }

    const result = await pool.query(
      `INSERT INTO ai_catalog_items (
        catalog_id, name, provider, category, description, tags,
        version, license, homepage_url, documentation_url
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
      RETURNING *`,
      [
        catalog_id,
        name,
        provider || null,
        category,
        description || null,
        tags || [],
        version || null,
        license || null,
        homepage_url || null,
        documentation_url || null,
      ]
    );

    res.status(201).json({
      success: true,
      message: 'Catalog item created successfully',
      item: result.rows[0],
    });
  } catch (error) {
    console.error('Error creating catalog item:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create catalog item',
    });
  }
});

// PUT update catalog item
router.put('/:id', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const {
      catalog_id,
      name,
      provider,
      category,
      description,
      tags,
      version,
      license,
      homepage_url,
      documentation_url,
      is_active,
      is_deprecated,
      deprecation_note,
    } = req.body;

    // Check if item exists
    const existing = await pool.query(
      'SELECT id FROM ai_catalog_items WHERE id = $1',
      [id]
    );

    if (existing.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Catalog item not found',
      });
    }

    const result = await pool.query(
      `UPDATE ai_catalog_items SET
        catalog_id = COALESCE($1, catalog_id),
        name = COALESCE($2, name),
        provider = COALESCE($3, provider),
        category = COALESCE($4, category),
        description = COALESCE($5, description),
        tags = COALESCE($6, tags),
        version = COALESCE($7, version),
        license = COALESCE($8, license),
        homepage_url = COALESCE($9, homepage_url),
        documentation_url = COALESCE($10, documentation_url),
        is_active = COALESCE($11, is_active),
        is_deprecated = COALESCE($12, is_deprecated),
        deprecation_note = COALESCE($13, deprecation_note),
        updated_at = CURRENT_TIMESTAMP
      WHERE id = $14
      RETURNING *`,
      [
        catalog_id,
        name,
        provider,
        category,
        description,
        tags,
        version,
        license,
        homepage_url,
        documentation_url,
        is_active,
        is_deprecated,
        deprecation_note,
        id,
      ]
    );

    res.json({
      success: true,
      message: 'Catalog item updated successfully',
      item: result.rows[0],
    });
  } catch (error) {
    console.error('Error updating catalog item:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update catalog item',
    });
  }
});

// DELETE catalog item
router.delete('/:id', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    const result = await pool.query(
      'DELETE FROM ai_catalog_items WHERE id = $1 RETURNING *',
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Catalog item not found',
      });
    }

    res.json({
      success: true,
      message: 'Catalog item deleted successfully',
      item: result.rows[0],
    });
  } catch (error) {
    console.error('Error deleting catalog item:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete catalog item',
    });
  }
});

// POST bulk import from array
router.post('/bulk-import', async (req: Request, res: Response) => {
  try {
    const { items } = req.body;

    if (!Array.isArray(items) || items.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'items must be a non-empty array',
      });
    }

    const results = {
      created: 0,
      updated: 0,
      skipped: 0,
      errors: [] as string[],
    };

    for (const item of items) {
      try {
        const { id: catalog_id, name, provider, category, description, tags } = item;

        if (!catalog_id || !name || !category) {
          results.skipped++;
          results.errors.push(`Skipped item missing required fields: ${JSON.stringify(item)}`);
          continue;
        }

        // Check if exists
        const existing = await pool.query(
          'SELECT id FROM ai_catalog_items WHERE catalog_id = $1',
          [catalog_id]
        );

        if (existing.rows.length > 0) {
          // Update existing
          await pool.query(
            `UPDATE ai_catalog_items SET
              name = $1, provider = $2, description = $3, tags = $4, updated_at = CURRENT_TIMESTAMP
            WHERE catalog_id = $5`,
            [name, provider || null, description || null, tags || [], catalog_id]
          );
          results.updated++;
        } else {
          // Create new
          await pool.query(
            `INSERT INTO ai_catalog_items (catalog_id, name, provider, category, description, tags)
            VALUES ($1, $2, $3, $4, $5, $6)`,
            [catalog_id, name, provider || null, category, description || null, tags || []]
          );
          results.created++;
        }
      } catch (itemError) {
        results.errors.push(`Error processing item ${item.id}: ${itemError}`);
      }
    }

    res.json({
      success: true,
      message: 'Bulk import completed',
      results,
    });
  } catch (error) {
    console.error('Error in bulk import:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to complete bulk import',
    });
  }
});

export default router;
