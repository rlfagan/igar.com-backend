import { Router, Request, Response } from 'express';
import bcrypt from 'bcrypt';
import { z } from 'zod';
import pool from '../db';
import { authenticateToken, requireAdmin, AuthRequest } from '../middleware/auth';

const router = Router();
const SALT_ROUNDS = 10;

// All routes require admin authentication
router.use(authenticateToken);
router.use(requireAdmin);

/**
 * GET /api/users
 * Get all users (admin only)
 */
router.get('/', async (req: AuthRequest, res: Response) => {
  try {
    const result = await pool.query(
      `SELECT id, email, full_name as name, role, created_at, updated_at
       FROM users
       ORDER BY created_at DESC`
    );

    res.json({
      success: true,
      users: result.rows,
    });
  } catch (error) {
    console.error('Get users error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch users' });
  }
});

/**
 * GET /api/users/:id
 * Get a specific user by ID (admin only)
 */
router.get('/:id', async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params;

    const result = await pool.query(
      `SELECT id, email, full_name as name, role, created_at, updated_at
       FROM users
       WHERE id = $1`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    res.json({
      success: true,
      user: result.rows[0],
    });
  } catch (error) {
    console.error('Get user error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch user' });
  }
});

/**
 * POST /api/users
 * Create a new user (admin only)
 */
router.post('/', async (req: AuthRequest, res: Response) => {
  try {
    const schema = z.object({
      email: z.string().email(),
      name: z.string().min(1),
      password: z.string().min(8),
      role: z.enum(['user', 'admin', 'reviewer']),
    });

    const data = schema.parse(req.body);

    // Check if user already exists
    const existingUser = await pool.query(
      'SELECT id FROM users WHERE email = $1',
      [data.email]
    );

    if (existingUser.rows.length > 0) {
      return res.status(400).json({
        success: false,
        message: 'User with this email already exists',
      });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(data.password, SALT_ROUNDS);

    // Create user
    const result = await pool.query(
      `INSERT INTO users (email, password_hash, full_name, role)
       VALUES ($1, $2, $3, $4)
       RETURNING id, email, full_name as name, role, created_at`,
      [data.email, hashedPassword, data.name, data.role]
    );

    res.status(201).json({
      success: true,
      user: result.rows[0],
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ success: false, errors: error.errors });
    }
    console.error('Create user error:', error);
    res.status(500).json({ success: false, message: 'Failed to create user' });
  }
});

/**
 * PUT /api/users/:id
 * Update a user (admin only)
 */
router.put('/:id', async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params;

    const schema = z.object({
      email: z.string().email().optional(),
      name: z.string().min(1).optional(),
      role: z.enum(['user', 'admin', 'reviewer']).optional(),
      password: z.string().min(8).optional(),
    });

    const data = schema.parse(req.body);

    // Check if user exists
    const existingUser = await pool.query(
      'SELECT id FROM users WHERE id = $1',
      [id]
    );

    if (existingUser.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    // Build dynamic update query
    const updates: string[] = [];
    const values: any[] = [];
    let paramCount = 1;

    if (data.email) {
      updates.push(`email = $${paramCount++}`);
      values.push(data.email);
    }
    if (data.name) {
      updates.push(`full_name = $${paramCount++}`);
      values.push(data.name);
    }
    if (data.role) {
      updates.push(`role = $${paramCount++}`);
      values.push(data.role);
    }
    if (data.password) {
      const hashedPassword = await bcrypt.hash(data.password, SALT_ROUNDS);
      updates.push(`password_hash = $${paramCount++}`);
      values.push(hashedPassword);
    }

    if (updates.length === 0) {
      return res.status(400).json({ success: false, message: 'No fields to update' });
    }

    updates.push(`updated_at = CURRENT_TIMESTAMP`);
    values.push(id);

    const result = await pool.query(
      `UPDATE users
       SET ${updates.join(', ')}
       WHERE id = $${paramCount}
       RETURNING id, email, full_name as name, role, updated_at`,
      values
    );

    res.json({
      success: true,
      user: result.rows[0],
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ success: false, errors: error.errors });
    }
    console.error('Update user error:', error);
    res.status(500).json({ success: false, message: 'Failed to update user' });
  }
});

/**
 * DELETE /api/users/:id
 * Delete a user (admin only)
 */
router.delete('/:id', async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params;

    // Prevent deleting self
    if (req.user?.id === parseInt(id)) {
      return res.status(400).json({
        success: false,
        message: 'Cannot delete your own account',
      });
    }

    const result = await pool.query(
      'DELETE FROM users WHERE id = $1 RETURNING id',
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    res.json({
      success: true,
      message: 'User deleted successfully',
    });
  } catch (error) {
    console.error('Delete user error:', error);
    res.status(500).json({ success: false, message: 'Failed to delete user' });
  }
});

export default router;
