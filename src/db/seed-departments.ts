import { pool } from './connection';

const departments = [
  { name: 'Engineering', slug: 'engineering', description: 'Software development and technical teams' },
  { name: 'Product', slug: 'product', description: 'Product management and design' },
  { name: 'Data Science', slug: 'data-science', description: 'Data analytics and machine learning teams' },
  { name: 'Marketing', slug: 'marketing', description: 'Marketing and communications' },
  { name: 'Sales', slug: 'sales', description: 'Sales and business development' },
  { name: 'Customer Success', slug: 'customer-success', description: 'Customer support and success' },
  { name: 'Finance', slug: 'finance', description: 'Finance and accounting' },
  { name: 'Legal', slug: 'legal', description: 'Legal and compliance' },
  { name: 'Human Resources', slug: 'human-resources', description: 'HR and people operations' },
  { name: 'Operations', slug: 'operations', description: 'Business operations' },
];

async function seedDepartments() {
  try {
    console.log('🏢 Seeding departments...');

    for (const dept of departments) {
      await pool.query(`
        INSERT INTO departments (name, slug, description, is_active)
        VALUES ($1, $2, $3, true)
        ON CONFLICT (slug) DO UPDATE SET
          name = EXCLUDED.name,
          description = EXCLUDED.description,
          updated_at = CURRENT_TIMESTAMP
      `, [dept.name, dept.slug, dept.description]);

      console.log(`  ✓ ${dept.name}`);
    }

    console.log('✅ Departments seeded successfully');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding departments:', error);
    process.exit(1);
  }
}

seedDepartments();
