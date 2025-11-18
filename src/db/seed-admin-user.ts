import pool from '../db';
import bcrypt from 'bcrypt';

const SALT_ROUNDS = 10;

async function seedAdminUser() {
  try {
    console.log('🌱 Seeding admin user...');

    const email = 'faganronan@gmail.com';
    const password = 'password123';
    const name = 'Ronan Fagan';

    // Check if user already exists
    const existingUser = await pool.query(
      'SELECT id FROM users WHERE email = $1',
      [email]
    );

    if (existingUser.rows.length > 0) {
      console.log('✅ Admin user already exists');
      return;
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, SALT_ROUNDS);

    // Create admin user
    const result = await pool.query(
      `INSERT INTO users (email, password_hash, name, role)
       VALUES ($1, $2, $3, $4)
       RETURNING id, email, name, role`,
      [email, hashedPassword, name, 'admin']
    );

    console.log('✅ Admin user created:', result.rows[0]);
    console.log(`   Email: ${email}`);
    console.log(`   Password: ${password}`);
  } catch (error) {
    console.error('❌ Failed to seed admin user:', error);
    throw error;
  } finally {
    await pool.end();
  }
}

seedAdminUser();
