-- Use Case Restrictions for AI Resources
-- Allows fine-grained control: "This model is approved, but only for specific use cases"

CREATE TABLE IF NOT EXISTS policy_resource_restrictions (
  id SERIAL PRIMARY KEY,
  policy_id INTEGER REFERENCES ai_catalog_policies(id) ON DELETE CASCADE,

  -- The AI resource (model/tool/oss/dataset)
  resource_id VARCHAR(255) NOT NULL, -- e.g., "anthropic:claude-3.5-sonnet"
  resource_category VARCHAR(50) NOT NULL CHECK (resource_category IN ('model', 'tool', 'oss', 'dataset')),

  -- Approval status
  approval_status VARCHAR(50) NOT NULL CHECK (approval_status IN ('approved', 'denied', 'review')),

  -- Use case restrictions
  allowed_use_cases TEXT[], -- NULL or empty = all use cases allowed
  denied_use_cases TEXT[],  -- Explicitly denied use cases (takes precedence)

  -- Scope restriction
  use_case_restriction_mode VARCHAR(50) DEFAULT 'all' CHECK (use_case_restriction_mode IN ('all', 'whitelist', 'blacklist')),
  -- 'all' = no restrictions, all use cases allowed
  -- 'whitelist' = only allowed_use_cases are permitted
  -- 'blacklist' = all use cases except denied_use_cases

  -- Additional context
  restriction_reason TEXT,

  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  UNIQUE(policy_id, resource_id)
);

-- Index for lookups
CREATE INDEX idx_policy_resource_restrictions_policy ON policy_resource_restrictions(policy_id);
CREATE INDEX idx_policy_resource_restrictions_resource ON policy_resource_restrictions(resource_id);
CREATE INDEX idx_policy_resource_restrictions_status ON policy_resource_restrictions(approval_status);

-- Comments
COMMENT ON TABLE policy_resource_restrictions IS 'Fine-grained use case restrictions for approved AI resources';
COMMENT ON COLUMN policy_resource_restrictions.use_case_restriction_mode IS 'all=no restrictions, whitelist=only specific use cases, blacklist=all except specific';

-- Example queries:
-- Check if Claude 3.5 Sonnet can be used for fraud-detection:
-- SELECT * FROM policy_resource_restrictions
-- WHERE resource_id = 'anthropic:claude-3.5-sonnet'
-- AND (use_case_restriction_mode = 'all'
--      OR (use_case_restriction_mode = 'whitelist' AND 'fraud-detection' = ANY(allowed_use_cases))
--      OR (use_case_restriction_mode = 'blacklist' AND NOT 'fraud-detection' = ANY(denied_use_cases)));
