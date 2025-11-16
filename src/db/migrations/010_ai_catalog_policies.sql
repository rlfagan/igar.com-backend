-- AI Catalog Policies Migration
-- Stores approved/denied/review-required AI resources from drag-and-drop policy editor

-- Departments table (will sync with Entra ID)
CREATE TABLE IF NOT EXISTS departments (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  slug VARCHAR(255) NOT NULL UNIQUE,
  description TEXT,
  parent_department_id INTEGER REFERENCES departments(id),

  -- Entra ID integration fields
  entra_id VARCHAR(255) UNIQUE,
  entra_display_name VARCHAR(255),
  entra_last_sync TIMESTAMP,

  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- AI Catalog Policies
CREATE TABLE IF NOT EXISTS ai_catalog_policies (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  slug VARCHAR(255) NOT NULL UNIQUE,
  description TEXT,

  -- Policy lists (stored as arrays of catalog item IDs)
  approved_models TEXT[] DEFAULT ARRAY[]::TEXT[],
  approved_tools TEXT[] DEFAULT ARRAY[]::TEXT[],
  approved_oss TEXT[] DEFAULT ARRAY[]::TEXT[],
  approved_datasets TEXT[] DEFAULT ARRAY[]::TEXT[],

  denied_models TEXT[] DEFAULT ARRAY[]::TEXT[],
  denied_tools TEXT[] DEFAULT ARRAY[]::TEXT[],
  denied_oss TEXT[] DEFAULT ARRAY[]::TEXT[],
  denied_datasets TEXT[] DEFAULT ARRAY[]::TEXT[],
  denied_use_cases TEXT[] DEFAULT ARRAY[]::TEXT[],

  review_models TEXT[] DEFAULT ARRAY[]::TEXT[],
  review_tools TEXT[] DEFAULT ARRAY[]::TEXT[],
  review_oss TEXT[] DEFAULT ARRAY[]::TEXT[],
  review_datasets TEXT[] DEFAULT ARRAY[]::TEXT[],
  review_use_cases TEXT[] DEFAULT ARRAY[]::TEXT[],

  -- Metadata
  is_active BOOLEAN DEFAULT true,
  is_default BOOLEAN DEFAULT false,
  is_global BOOLEAN DEFAULT true, -- If false, applies only to specific departments
  version INTEGER DEFAULT 1,

  -- Audit fields
  created_by INTEGER REFERENCES users(id),
  updated_by INTEGER REFERENCES users(id),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Policy-Department mapping (many-to-many)
CREATE TABLE IF NOT EXISTS policy_departments (
  id SERIAL PRIMARY KEY,
  policy_id INTEGER REFERENCES ai_catalog_policies(id) ON DELETE CASCADE,
  department_id INTEGER REFERENCES departments(id) ON DELETE CASCADE,

  -- Override settings per department
  override_approved JSONB, -- Can add additional approved items for this dept
  override_denied JSONB,   -- Can add additional denied items for this dept

  assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  assigned_by INTEGER REFERENCES users(id),

  UNIQUE(policy_id, department_id)
);

-- Policy version history
CREATE TABLE IF NOT EXISTS ai_catalog_policy_versions (
  id SERIAL PRIMARY KEY,
  policy_id INTEGER REFERENCES ai_catalog_policies(id) ON DELETE CASCADE,
  version INTEGER NOT NULL,

  -- Snapshot of policy at this version
  policy_snapshot JSONB NOT NULL,

  -- Change tracking
  change_description TEXT,
  changed_by INTEGER REFERENCES users(id),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_departments_slug ON departments(slug);
CREATE INDEX idx_departments_entra_id ON departments(entra_id);
CREATE INDEX idx_departments_parent ON departments(parent_department_id);
CREATE INDEX idx_ai_catalog_policies_slug ON ai_catalog_policies(slug);
CREATE INDEX idx_ai_catalog_policies_active ON ai_catalog_policies(is_active);
CREATE INDEX idx_ai_catalog_policies_default ON ai_catalog_policies(is_default);
CREATE INDEX idx_ai_catalog_policies_global ON ai_catalog_policies(is_global);
CREATE INDEX idx_policy_departments_policy ON policy_departments(policy_id);
CREATE INDEX idx_policy_departments_department ON policy_departments(department_id);
CREATE INDEX idx_ai_catalog_policy_versions_policy ON ai_catalog_policy_versions(policy_id);

-- Ensure only one default policy
CREATE UNIQUE INDEX unique_default_policy ON ai_catalog_policies(is_default) WHERE is_default = true;

-- Comments
COMMENT ON TABLE departments IS 'Organizational departments, synced with Microsoft Entra ID';
COMMENT ON TABLE ai_catalog_policies IS 'AI governance policies defining approved, denied, and review-required AI resources';
COMMENT ON TABLE policy_departments IS 'Maps policies to specific departments with optional overrides';
COMMENT ON TABLE ai_catalog_policy_versions IS 'Version history for AI catalog policies';

-- Insert default department for global policies
INSERT INTO departments (name, slug, description, is_active)
VALUES ('Global', 'global', 'Default department for organization-wide policies', true)
ON CONFLICT (slug) DO NOTHING;
