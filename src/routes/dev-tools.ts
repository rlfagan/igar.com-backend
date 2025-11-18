import { Router, Request, Response } from 'express';
import bcrypt from 'bcrypt';
import pool from '../db';

const router = Router();
const SALT_ROUNDS = 10;

/**
 * POST /api/dev/reset-admin-password
 * Reset admin password to 'password123'
 * DEVELOPMENT/DEBUGGING ONLY - Remove in production
 */
router.post('/reset-admin-password', async (req: Request, res: Response) => {
  try {
    const email = 'faganronan@gmail.com';
    const newPassword = 'password123';

    // Hash the new password
    const hashedPassword = await bcrypt.hash(newPassword, SALT_ROUNDS);

    // Update the admin user's password
    const result = await pool.query(
      'UPDATE users SET password_hash = $1, updated_at = CURRENT_TIMESTAMP WHERE email = $2 RETURNING id, email, role',
      [hashedPassword, email]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Admin user not found',
      });
    }

    res.json({
      success: true,
      message: 'Admin password reset successfully',
      user: result.rows[0],
      credentials: {
        email,
        password: newPassword,
      },
    });
  } catch (error) {
    console.error('Reset password error:', error);
    res.status(500).json({ success: false, message: 'Failed to reset password' });
  }
});

/**
 * GET /api/dev/test-login
 * Test login credentials
 */
router.post('/test-login', async (req: Request, res: Response) => {
  try {
    const { email, password } = req.body;

    // Find user
    const result = await pool.query(
      'SELECT id, email, password_hash, full_name as name, role FROM users WHERE email = $1',
      [email]
    );

    if (result.rows.length === 0) {
      return res.json({
        success: false,
        message: 'User not found',
        details: { userExists: false },
      });
    }

    const user = result.rows[0];

    // Test password
    const isValidPassword = await bcrypt.compare(password, user.password_hash);

    res.json({
      success: isValidPassword,
      message: isValidPassword ? 'Password is correct' : 'Password is incorrect',
      details: {
        userExists: true,
        passwordMatch: isValidPassword,
        userId: user.id,
        userRole: user.role,
      },
    });
  } catch (error) {
    console.error('Test login error:', error);
    res.status(500).json({ success: false, message: 'Failed to test login' });
  }
});

export default router;
