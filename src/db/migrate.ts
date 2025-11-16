import { Pool } from 'pg';
import * as fs from 'fs';
import * as path from 'path';
import dotenv from 'dotenv';

dotenv.config();

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

async function migrate() {
  try {
    console.log('Running database migrations...');

    // Create migrations tracking table if it doesn't exist
    await pool.query(`
      CREATE TABLE IF NOT EXISTS schema_migrations (
        version VARCHAR(255) PRIMARY KEY,
        applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // Check if base schema has been applied
    const baseSchemaCheck = await pool.query(
      `SELECT version FROM schema_migrations WHERE version = 'base-schema'`
    );

    if (baseSchemaCheck.rows.length === 0) {
      console.log('  Running base schema...');
      const schemaPath = path.join(__dirname, 'schema.sql');
      const schema = fs.readFileSync(schemaPath, 'utf-8');
      await pool.query(schema);
      await pool.query(
        `INSERT INTO schema_migrations (version) VALUES ('base-schema')`
      );
      console.log('✅ Base schema loaded');
    } else {
      console.log('✅ Base schema already applied');
    }

    // Run migration files that haven't been applied yet
    const migrationsDir = path.join(__dirname, 'migrations');
    const migrationFiles = fs.readdirSync(migrationsDir)
      .filter(file => file.endsWith('.sql'))
      .sort();

    for (const file of migrationFiles) {
      const check = await pool.query(
        `SELECT version FROM schema_migrations WHERE version = $1`,
        [file]
      );

      if (check.rows.length === 0) {
        console.log(`  Running migration: ${file}`);
        const migrationPath = path.join(migrationsDir, file);
        const migration = fs.readFileSync(migrationPath, 'utf-8');
        await pool.query(migration);
        await pool.query(
          `INSERT INTO schema_migrations (version) VALUES ($1)`,
          [file]
        );
      } else {
        console.log(`  Skipping ${file} (already applied)`);
      }
    }

    console.log('✅ All migrations completed successfully');
    process.exit(0);
  } catch (error) {
    console.error('❌ Migration failed:', error);
    process.exit(1);
  }
}

migrate();
