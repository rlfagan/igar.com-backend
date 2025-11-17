-- Clean slate script for Railway Postgres
-- Run this directly in the Railway Postgres terminal with: \i /path/to/this/file
-- Or copy/paste the entire contents into psql

-- Step 1: Drop the migration tracking table
DROP TABLE IF EXISTS schema_migrations CASCADE;

-- Step 2: Clear duplicate data from modification_classes
DELETE FROM modification_classes WHERE class_number IN (0, 1, 2, 3, 4, 5, 6);

-- Step 3: Clear duplicate data from governance_roles
DELETE FROM governance_roles WHERE role_name IN (
  'Model Owner',
  'Technical Reviewer',
  'AI Safety Officer',
  'Data Governance Officer',
  'Security Reviewer',
  'Legal Counsel',
  'Data Protection Officer',
  'Chief AI Officer',
  'CISO',
  'CTO',
  'Ethics Board'
);

-- Verify cleanup
SELECT 'schema_migrations dropped' as status;
SELECT COUNT(*) as modification_classes_count FROM modification_classes;
SELECT COUNT(*) as governance_roles_count FROM governance_roles;
