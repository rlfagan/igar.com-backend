-- Form Configuration System for Multi-tenant Customization

-- Organizations table (for multi-tenancy)
CREATE TABLE IF NOT EXISTS organizations (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  slug VARCHAR(100) UNIQUE NOT NULL,
  industry VARCHAR(100), -- 'fintech', 'healthcare', 'retail', 'general'
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Policy Templates (industry-specific or use-case specific)
CREATE TABLE IF NOT EXISTS form_policies (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  slug VARCHAR(100) UNIQUE NOT NULL,
  description TEXT,
  industry VARCHAR(100),
  is_default BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,
  created_by INTEGER REFERENCES users(id),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Form Sections Configuration
CREATE TABLE IF NOT EXISTS form_sections (
  id SERIAL PRIMARY KEY,
  policy_id INTEGER REFERENCES form_policies(id) ON DELETE CASCADE,
  section_key VARCHAR(100) NOT NULL, -- 'section1', 'section2', etc.
  title VARCHAR(255) NOT NULL,
  description TEXT,
  order_index INTEGER NOT NULL,
  is_required BOOLEAN DEFAULT true,
  is_enabled BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(policy_id, section_key)
);

-- Form Fields Configuration
CREATE TABLE IF NOT EXISTS form_fields (
  id SERIAL PRIMARY KEY,
  section_id INTEGER REFERENCES form_sections(id) ON DELETE CASCADE,
  field_key VARCHAR(100) NOT NULL, -- 'project_name', 'model_name', etc.
  label VARCHAR(255) NOT NULL,
  field_type VARCHAR(50) NOT NULL, -- 'text', 'textarea', 'select', 'multiselect', 'checkbox', 'radio', 'file'
  placeholder TEXT,
  help_text TEXT,
  order_index INTEGER NOT NULL,
  is_required BOOLEAN DEFAULT false,
  is_enabled BOOLEAN DEFAULT true,
  validation_rules JSONB, -- { "min": 1, "max": 500, "pattern": "regex", "custom": "..." }
  options JSONB, -- For select/multiselect/radio: [{"value": "...", "label": "..."}]
  default_value TEXT,
  conditional_logic JSONB, -- Show/hide based on other field values
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(section_id, field_key)
);

-- Organization Policy Assignments (which policy each org uses)
CREATE TABLE IF NOT EXISTS organization_policies (
  id SERIAL PRIMARY KEY,
  organization_id INTEGER REFERENCES organizations(id) ON DELETE CASCADE,
  policy_id INTEGER REFERENCES form_policies(id) ON DELETE CASCADE,
  is_active BOOLEAN DEFAULT true,
  customizations JSONB, -- Organization-specific overrides
  activated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(organization_id, policy_id)
);

-- Policy Customizations (organization-specific field overrides)
CREATE TABLE IF NOT EXISTS policy_customizations (
  id SERIAL PRIMARY KEY,
  organization_id INTEGER REFERENCES organizations(id) ON DELETE CASCADE,
  field_id INTEGER REFERENCES form_fields(id) ON DELETE CASCADE,
  custom_label VARCHAR(255),
  custom_help_text TEXT,
  custom_options JSONB,
  custom_validation_rules JSONB,
  is_enabled BOOLEAN,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(organization_id, field_id)
);

-- Audit log for policy changes
CREATE TABLE IF NOT EXISTS policy_audit_log (
  id SERIAL PRIMARY KEY,
  organization_id INTEGER REFERENCES organizations(id),
  policy_id INTEGER REFERENCES form_policies(id),
  action VARCHAR(50) NOT NULL, -- 'created', 'updated', 'activated', 'deactivated'
  changed_by INTEGER REFERENCES users(id),
  changes JSONB, -- What was changed
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_form_sections_policy ON form_sections(policy_id);
CREATE INDEX IF NOT EXISTS idx_form_fields_section ON form_fields(section_id);
CREATE INDEX IF NOT EXISTS idx_org_policies_org ON organization_policies(organization_id);
CREATE INDEX IF NOT EXISTS idx_policy_customizations_org ON policy_customizations(organization_id);
CREATE INDEX IF NOT EXISTS idx_policy_audit_org ON policy_audit_log(organization_id);

-- Comments
COMMENT ON TABLE form_policies IS 'Reusable form templates for different industries or use cases';
COMMENT ON TABLE form_sections IS 'Configurable sections within each policy';
COMMENT ON TABLE form_fields IS 'Individual fields with full configuration';
COMMENT ON TABLE organization_policies IS 'Maps organizations to their active policies';
COMMENT ON TABLE policy_customizations IS 'Organization-specific overrides to policy fields';
