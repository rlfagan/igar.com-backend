import { Router, Request, Response } from 'express';
import pool from '../db';

const router = Router();

// GET all departments
router.get('/', async (req: Request, res: Response) => {
  try {
    const result = await pool.query(`
      SELECT
        id, name, slug, description,
        parent_department_id, entra_id, entra_display_name,
        is_active, created_at, updated_at
      FROM departments
      WHERE is_active = true
      ORDER BY name ASC
    `);

    res.json({
      success: true,
      departments: result.rows,
    });
  } catch (error) {
    console.error('Error fetching departments:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch departments',
    });
  }
});

// GET single department by ID
router.get('/:id', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    const result = await pool.query(`
      SELECT
        id, name, slug, description,
        parent_department_id, entra_id, entra_display_name,
        is_active, created_at, updated_at
      FROM departments
      WHERE id = $1
    `, [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Department not found',
      });
    }

    res.json({
      success: true,
      department: result.rows[0],
    });
  } catch (error) {
    console.error('Error fetching department:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch department',
    });
  }
});

// POST create new department
router.post('/', async (req: Request, res: Response) => {
  try {
    const { name, description, parent_department_id } = req.body;

    if (!name) {
      return res.status(400).json({
        success: false,
        message: 'Department name is required',
      });
    }

    // Generate slug from name
    const slug = name
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/^-|-$/g, '');

    // Check if slug already exists
    const existingDept = await pool.query(
      'SELECT id FROM departments WHERE slug = $1',
      [slug]
    );

    if (existingDept.rows.length > 0) {
      return res.status(400).json({
        success: false,
        message: 'A department with this name already exists',
      });
    }

    const result = await pool.query(`
      INSERT INTO departments (name, slug, description, parent_department_id)
      VALUES ($1, $2, $3, $4)
      RETURNING *
    `, [name, slug, description || '', parent_department_id || null]);

    res.status(201).json({
      success: true,
      message: 'Department created successfully',
      department: result.rows[0],
    });
  } catch (error) {
    console.error('Error creating department:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create department',
    });
  }
});

// PUT update existing department
router.put('/:id', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const { name, description, parent_department_id, is_active } = req.body;

    const result = await pool.query(`
      UPDATE departments
      SET
        name = COALESCE($1, name),
        description = COALESCE($2, description),
        parent_department_id = COALESCE($3, parent_department_id),
        is_active = COALESCE($4, is_active),
        updated_at = CURRENT_TIMESTAMP
      WHERE id = $5
      RETURNING *
    `, [name, description, parent_department_id, is_active, id]);

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Department not found',
      });
    }

    res.json({
      success: true,
      message: 'Department updated successfully',
      department: result.rows[0],
    });
  } catch (error) {
    console.error('Error updating department:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update department',
    });
  }
});

// DELETE department
router.delete('/:id', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    // Check if this is the global department
    const dept = await pool.query(
      'SELECT slug FROM departments WHERE id = $1',
      [id]
    );

    if (dept.rows.length > 0 && dept.rows[0].slug === 'global') {
      return res.status(400).json({
        success: false,
        message: 'Cannot delete the global department',
      });
    }

    const result = await pool.query(
      'DELETE FROM departments WHERE id = $1 RETURNING id',
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Department not found',
      });
    }

    res.json({
      success: true,
      message: 'Department deleted successfully',
    });
  } catch (error) {
    console.error('Error deleting department:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete department',
    });
  }
});

export default router;
