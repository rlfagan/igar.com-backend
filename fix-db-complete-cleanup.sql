-- Complete cleanup script for Railway Postgres
-- Run this in the Railway Postgres terminal
-- This clears ALL migration state including indexes

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

-- Step 4: Drop all indexes from migration 009_ai_governance_framework.sql
DROP INDEX IF EXISTS idx_submissions_modification_class;
DROP INDEX IF EXISTS idx_submissions_conformity_status;
DROP INDEX IF EXISTS idx_governance_approvals_submission;
DROP INDEX IF EXISTS idx_governance_approvals_status;
DROP INDEX IF EXISTS idx_governance_evidence_submission;
DROP INDEX IF EXISTS idx_conformity_assessments_submission;
DROP INDEX IF EXISTS idx_post_market_monitoring_submission;
DROP INDEX IF EXISTS idx_ai_incidents_submission;
DROP INDEX IF EXISTS idx_ai_incidents_severity;
DROP INDEX IF EXISTS idx_modification_risk_scores_submission;

-- Verify cleanup
SELECT 'Cleanup complete!' as status;
SELECT COUNT(*) as modification_classes_count FROM modification_classes;
SELECT COUNT(*) as governance_roles_count FROM governance_roles;
