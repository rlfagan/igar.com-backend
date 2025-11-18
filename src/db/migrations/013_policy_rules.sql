-- Policy Rules System for Automated Workflow
-- Enables conditional auto-approve, auto-deny, and flag-for-review based on submission data

-- Main policy rules table
CREATE TABLE IF NOT EXISTS policy_rules (
  id SERIAL PRIMARY KEY,
  policy_id INTEGER REFERENCES form_policies(id) ON DELETE CASCADE,

  -- Rule identification
  name VARCHAR(255) NOT NULL,
  description TEXT,

  -- Rule configuration
  action VARCHAR(50) NOT NULL CHECK (action IN ('approve', 'deny', 'review')),
  priority INTEGER DEFAULT 0, -- Higher priority rules are evaluated first
  is_active BOOLEAN DEFAULT true,

  -- Conditions (stored as JSONB for flexibility)
  -- Example: [{"field": "risk_score", "operator": ">", "value": 80}]
  conditions JSONB NOT NULL DEFAULT '[]',

  -- Department/Group restrictions
  department_ids INTEGER[] DEFAULT ARRAY[]::INTEGER[], -- Empty array means applies to all

  -- Additional metadata
  stop_on_match BOOLEAN DEFAULT true, -- If true, stop evaluating further rules when this one matches
  custom_message TEXT, -- Optional message to show when rule is triggered

  -- Audit fields
  created_by INTEGER REFERENCES users(id),
  updated_by INTEGER REFERENCES users(id),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index for performance
CREATE INDEX IF NOT EXISTS idx_policy_rules_policy_id ON policy_rules(policy_id);
CREATE INDEX IF NOT EXISTS idx_policy_rules_active ON policy_rules(is_active) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_policy_rules_priority ON policy_rules(priority DESC);

-- Rule execution log table
CREATE TABLE IF NOT EXISTS policy_rule_executions (
  id SERIAL PRIMARY KEY,
  submission_id INTEGER REFERENCES submissions(id) ON DELETE CASCADE,
  rule_id INTEGER REFERENCES policy_rules(id) ON DELETE SET NULL,

  -- Execution results
  matched BOOLEAN NOT NULL,
  action_taken VARCHAR(50), -- The action that was applied (approve/deny/review)

  -- Context
  evaluated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  evaluation_context JSONB -- Store the submission data snapshot at time of evaluation
);

CREATE INDEX IF NOT EXISTS idx_rule_executions_submission ON policy_rule_executions(submission_id);
CREATE INDEX IF NOT EXISTS idx_rule_executions_rule ON policy_rule_executions(rule_id);

-- Add columns to submissions table to track rule-based decisions
ALTER TABLE submissions
  ADD COLUMN IF NOT EXISTS auto_decision VARCHAR(50) CHECK (auto_decision IN ('approved', 'denied', 'flagged_for_review', NULL)),
  ADD COLUMN IF NOT EXISTS auto_decision_rule_id INTEGER REFERENCES policy_rules(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS auto_decision_message TEXT,
  ADD COLUMN IF NOT EXISTS auto_decision_at TIMESTAMP;

-- Comments for documentation
COMMENT ON TABLE policy_rules IS 'Configurable rules for automated submission approval/denial/review workflows';
COMMENT ON COLUMN policy_rules.conditions IS 'JSON array of condition objects with field, operator, and value';
COMMENT ON COLUMN policy_rules.priority IS 'Higher values are evaluated first. Use for rule precedence.';
COMMENT ON COLUMN policy_rules.stop_on_match IS 'If true, stop processing remaining rules when this rule matches';
COMMENT ON COLUMN policy_rules.department_ids IS 'Array of department IDs this rule applies to. Empty = all departments';

COMMENT ON TABLE policy_rule_executions IS 'Audit log of all rule evaluations for submissions';
