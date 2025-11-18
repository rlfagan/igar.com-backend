import bcrypt from 'bcrypt';
import pool from '../src/db';

const SALT_ROUNDS = 10;

async function resetAdminPassword() {
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
      console.error('Admin user not found');
      process.exit(1);
    }

    console.log('✅ Admin password reset successfully');
    console.log(`Email: ${email}`);
    console.log(`New Password: ${newPassword}`);
    console.log(`User ID: ${result.rows[0].id}`);
    console.log(`Role: ${result.rows[0].role}`);

    await pool.end();
    process.exit(0);
  } catch (error) {
    console.error('Error resetting password:', error);
    await pool.end();
    process.exit(1);
  }
}

resetAdminPassword();
