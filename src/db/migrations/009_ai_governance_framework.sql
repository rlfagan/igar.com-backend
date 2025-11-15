-- AI Governance Framework Migration
-- ISO/IEC 42001 + EU AI Act Compliance

-- Model Modification Classes
CREATE TABLE IF NOT EXISTS modification_classes (
  id SERIAL PRIMARY KEY,
  class_number INTEGER NOT NULL UNIQUE CHECK (class_number >= 0 AND class_number <= 6),
  class_name VARCHAR(100) NOT NULL,
  risk_level VARCHAR(50) NOT NULL CHECK (risk_level IN ('Low', 'Medium', 'Medium-High', 'High', 'Very High')),
  eu_ai_act_category VARCHAR(100),
  iso_42001_focus TEXT,
  description TEXT NOT NULL,
  obligations JSONB NOT NULL,
  approval_requirements JSONB NOT NULL,
  required_evidence TEXT[],
  monitoring_requirements TEXT[],
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert modification classes
INSERT INTO modification_classes (class_number, class_name, risk_level, eu_ai_act_category, iso_42001_focus, description, obligations, approval_requirements, required_evidence, monitoring_requirements) VALUES
(0, 'Pure Base Model (No Modifications)', 'Low', 'Minimal / Limited-risk', 'Transparency + Acceptable Use',
  'Using a pre-trained model without any modifications, including prompts, fine-tuning, or RAG.',
  '{"documentation": ["Model name, vendor, version"], "verification": ["License for commercial use"], "safety": ["Vendor safety guardrails"], "usage": ["Within permitted domain"]}'::jsonb,
  '{"authority": "Model Owner", "reviewers": ["Technical Reviewer"]}'::jsonb,
  ARRAY['Model card', 'Version documentation', 'License agreement', 'Business justification'],
  ARRAY['Access control logs', 'Usage monitoring']
),
(1, 'Prompt Engineering Only', 'Low', 'Non-HRM, minimal-risk', 'Transparency + Change Management',
  'Using system prompts or prompt templates to guide model behavior without changing model weights.',
  '{"documentation": ["Versioned prompt templates", "System prompts"], "safety": ["Prompt safety review"], "data": ["No PII in prompts"]}'::jsonb,
  '{"authority": "Model Owner + Reviewer", "reviewers": ["Technical Reviewer"]}'::jsonb,
  ARRAY['Prompt template version history', 'Safety review results', 'Use case documentation'],
  ARRAY['Prompt version control', 'Behavior consistency analysis']
),
(2, 'RAG (Retrieval-Augmented Generation)', 'Medium', 'Limited or High Risk (context-dependent)', 'Data governance + Monitoring',
  'Augmenting model outputs with retrieved information from a knowledge base or vector database.',
  '{"documentation": ["Corpus sources", "Data lineage"], "legal": ["Licensing", "Copyright validation"], "privacy": ["PII controls", "Data minimization"], "security": ["Access management", "Query logging"]}'::jsonb,
  '{"authority": "AI Reviewer + Data Governance", "reviewers": ["Data Governance Officer", "Security Reviewer"]}'::jsonb,
  ARRAY['Data lineage diagrams', 'Retrieval logs', 'Copyright compliance review', 'PII protection controls', 'Data minimization assessment'],
  ARRAY['Retrieval query logging', 'Data leakage detection', 'Access audit logs']
),
(3, 'LoRA / QLoRA / PEFT (Adapter Fine-Tuning)', 'Medium-High', 'May be High-Risk (domain-dependent)', 'Lifecycle + Training Data Governance',
  'Fine-tuning model using parameter-efficient methods (LoRA, QLoRA, adapters) that update only a small subset of parameters.',
  '{"documentation": ["Training dataset provenance", "Dataset quality controls", "Adapter versioning"], "legal": ["Dataset legality", "Copyright", "Privacy"], "testing": ["Safety tests", "Bias evaluation"], "reproducibility": ["Training logs", "Hyperparameters"]}'::jsonb,
  '{"authority": "AI Risk Committee", "reviewers": ["AI Safety Officer", "Legal", "Security", "Data Governance"]}'::jsonb,
  ARRAY['Training dataset documentation', 'Dataset provenance', 'Safety test results', 'Bias evaluation report', 'Adapter weights versioning', 'Reproducibility documentation', 'Impact assessment'],
  ARRAY['Model performance monitoring', 'Drift detection', 'Bias monitoring', 'Safety incident tracking']
),
(4, 'Full Fine-Tuning (Weight Overwrite)', 'High', 'High-Risk / GPAI with Systemic Risk', 'Full AI Management System Controls',
  'Complete retraining or fine-tuning that modifies all model weights, creating essentially a new model.',
  '{"documentation": ["Full dataset disclosure", "Data governance plan", "Model lineage"], "legal": ["Privacy impact assessment", "Copyright compliance"], "testing": ["Comprehensive safety testing", "Bias testing", "Robustness testing", "Red-team adversarial testing"], "monitoring": ["Drift detection", "Harm detection"], "reproducibility": ["Training pipeline", "Version control"]}'::jsonb,
  '{"authority": "Risk Committee + Legal + Security", "reviewers": ["Chief AI Officer", "Legal Counsel", "CISO", "Data Protection Officer", "Ethics Board"]}'::jsonb,
  ARRAY['Complete training metadata', 'Dataset disclosure', 'Data governance plan', 'Privacy impact assessment', 'Copyright compliance review', 'Safety test suite results', 'Bias evaluation', 'Robustness testing', 'Red-team results', 'Conformity assessment', 'Technical documentation package', 'Post-market monitoring plan'],
  ARRAY['Continuous monitoring', 'Drift detection', 'Harm detection', 'Incident reporting', 'Performance tracking', 'Bias monitoring']
),
(5, 'Safety Alignment Tuning', 'Medium-High', 'Often High-Risk', 'Safety + Monitoring + Evaluation',
  'Fine-tuning specifically to improve safety, reduce harm, or align model behavior with human values (e.g., RLHF, DPO, Constitutional AI).',
  '{"documentation": ["Alignment methods", "Alignment dataset lineage"], "testing": ["Bias assessment", "Safety improvement evidence", "False refusal/compliance rates"]}'::jsonb,
  '{"authority": "AI Risk Committee", "reviewers": ["AI Safety Officer", "Ethics Board", "Security"]}'::jsonb,
  ARRAY['Alignment methodology documentation', 'Alignment dataset provenance', 'Pre/post safety metrics', 'Bias evaluation', 'False refusal analysis', 'Safety test results'],
  ARRAY['Safety monitoring', 'Alignment drift detection', 'Human oversight logs']
),
(6, 'Custom Tokenizer', 'Very High', 'High-Risk / Substantial Modification', 'Full Lifecycle Controls + Extensive Documentation',
  'Modifying or replacing the model tokenizer, which fundamentally changes how the model processes inputs.',
  '{"documentation": ["Tokenizer specification", "Design rationale", "Vocabulary changes"], "testing": ["Full re-evaluation", "Stability testing", "Safety tests", "Bias tests"], "legal": ["Substantial modification declaration"], "reproducibility": ["Tokenizer versioning", "Change control"]}'::jsonb,
  '{"authority": "Risk Committee + Legal + CTO", "reviewers": ["CTO", "Chief AI Officer", "Legal Counsel", "CISO", "AI Safety Officer"]}'::jsonb,
  ARRAY['Tokenizer specification', 'Design rationale', 'Vocabulary documentation', 'Regression test results', 'Stability evaluation', 'Safety test suite', 'Bias evaluation', 'Substantial modification package', 'Technical documentation', 'Conformity assessment'],
  ARRAY['Comprehensive monitoring', 'Stability tracking', 'Safety incident detection', 'Performance regression detection']
);

-- Governance roles
CREATE TABLE IF NOT EXISTS governance_roles (
  id SERIAL PRIMARY KEY,
  role_name VARCHAR(100) NOT NULL UNIQUE,
  role_description TEXT,
  responsibilities TEXT[],
  required_for_classes INTEGER[],
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO governance_roles (role_name, role_description, responsibilities, required_for_classes) VALUES
('Model Owner', 'Business owner responsible for model use case and outcomes',
  ARRAY['Define business requirements', 'Approve use cases', 'Monitor business metrics'],
  ARRAY[0, 1, 2, 3, 4, 5, 6]),
('Technical Reviewer', 'Technical expert reviewing implementation',
  ARRAY['Review technical implementation', 'Validate architecture', 'Approve technical approach'],
  ARRAY[0, 1, 2]),
('AI Safety Officer', 'Responsible for AI safety and ethics',
  ARRAY['Conduct safety reviews', 'Evaluate bias and fairness', 'Approve safety measures'],
  ARRAY[3, 4, 5, 6]),
('Data Governance Officer', 'Oversees data quality and compliance',
  ARRAY['Validate data provenance', 'Ensure data quality', 'Approve data usage'],
  ARRAY[2, 3, 4]),
('Security Reviewer', 'Reviews security and privacy controls',
  ARRAY['Assess security risks', 'Validate controls', 'Approve security measures'],
  ARRAY[2, 3, 4, 5, 6]),
('Legal Counsel', 'Provides legal review and compliance',
  ARRAY['Review legal compliance', 'Assess regulatory requirements', 'Approve legal aspects'],
  ARRAY[4, 6]),
('Data Protection Officer', 'GDPR/privacy compliance',
  ARRAY['Conduct privacy impact assessments', 'Ensure GDPR compliance', 'Approve data processing'],
  ARRAY[4]),
('Chief AI Officer', 'Senior leadership approval for high-risk AI',
  ARRAY['Strategic oversight', 'Final approval for high-risk systems', 'Set AI governance policy'],
  ARRAY[4, 6]),
('CISO', 'Chief Information Security Officer',
  ARRAY['Approve security architecture', 'Final security sign-off', 'Oversee security compliance'],
  ARRAY[4, 6]),
('CTO', 'Chief Technology Officer',
  ARRAY['Approve substantial technical changes', 'Strategic technology decisions', 'Architecture oversight'],
  ARRAY[6]),
('Ethics Board', 'Ethical review committee',
  ARRAY['Conduct ethical reviews', 'Evaluate societal impact', 'Approve ethical considerations'],
  ARRAY[4, 5]);

-- Update submissions table to include governance fields
ALTER TABLE submissions ADD COLUMN IF NOT EXISTS modification_class INTEGER REFERENCES modification_classes(class_number);
ALTER TABLE submissions ADD COLUMN IF NOT EXISTS governance_data JSONB DEFAULT '{}'::jsonb;
ALTER TABLE submissions ADD COLUMN IF NOT EXISTS conformity_status VARCHAR(50) DEFAULT 'pending';
ALTER TABLE submissions ADD COLUMN IF NOT EXISTS iso_42001_compliant BOOLEAN DEFAULT false;
ALTER TABLE submissions ADD COLUMN IF NOT EXISTS eu_ai_act_compliant BOOLEAN DEFAULT false;

-- Governance approvals tracking
CREATE TABLE IF NOT EXISTS governance_approvals (
  id SERIAL PRIMARY KEY,
  submission_id INTEGER REFERENCES submissions(id) ON DELETE CASCADE,
  role_id INTEGER REFERENCES governance_roles(id),
  approver_user_id INTEGER REFERENCES users(id),
  approval_status VARCHAR(50) CHECK (approval_status IN ('pending', 'approved', 'rejected', 'needs_info')),
  approval_date TIMESTAMP,
  comments TEXT,
  evidence_reviewed TEXT[],
  conditions TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Evidence artifacts
CREATE TABLE IF NOT EXISTS governance_evidence (
  id SERIAL PRIMARY KEY,
  submission_id INTEGER REFERENCES submissions(id) ON DELETE CASCADE,
  evidence_type VARCHAR(100) NOT NULL,
  evidence_category VARCHAR(100),
  file_path VARCHAR(500),
  metadata JSONB,
  uploaded_by INTEGER REFERENCES users(id),
  uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Conformity assessments (EU AI Act Annex IV)
CREATE TABLE IF NOT EXISTS conformity_assessments (
  id SERIAL PRIMARY KEY,
  submission_id INTEGER REFERENCES submissions(id) ON DELETE CASCADE,
  assessment_type VARCHAR(50) CHECK (assessment_type IN ('self_assessment', 'third_party', 'notified_body')),
  assessment_date TIMESTAMP,
  assessor_name VARCHAR(255),
  assessor_organization VARCHAR(255),

  -- Annex IV requirements
  general_description TEXT,
  intended_purpose TEXT,
  risk_management_system JSONB,
  data_governance_measures JSONB,
  technical_documentation JSONB,
  transparency_provisions JSONB,
  human_oversight_measures JSONB,
  accuracy_robustness_measures JSONB,

  conformity_status VARCHAR(50) CHECK (conformity_status IN ('conformant', 'non_conformant', 'conditional', 'pending')),
  non_conformities TEXT[],
  remediation_plan TEXT,
  next_assessment_date DATE,

  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Post-market monitoring (ISO 42001 + EU AI Act requirement)
CREATE TABLE IF NOT EXISTS post_market_monitoring (
  id SERIAL PRIMARY KEY,
  submission_id INTEGER REFERENCES submissions(id) ON DELETE CASCADE,
  monitoring_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  monitoring_type VARCHAR(100),

  -- Performance metrics
  performance_metrics JSONB,
  drift_detected BOOLEAN DEFAULT false,
  drift_details TEXT,

  -- Safety incidents
  safety_incidents INTEGER DEFAULT 0,
  incident_details JSONB,

  -- Bias monitoring
  bias_metrics JSONB,
  bias_concerns TEXT,

  -- User feedback
  user_complaints INTEGER DEFAULT 0,
  complaint_summary TEXT,

  -- Actions taken
  actions_required BOOLEAN DEFAULT false,
  actions_taken TEXT,

  reported_by INTEGER REFERENCES users(id),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Incident reporting (EU AI Act Article 62)
CREATE TABLE IF NOT EXISTS ai_incidents (
  id SERIAL PRIMARY KEY,
  submission_id INTEGER REFERENCES submissions(id) ON DELETE CASCADE,
  incident_date TIMESTAMP NOT NULL,
  incident_type VARCHAR(100) NOT NULL,
  severity VARCHAR(50) CHECK (severity IN ('minor', 'major', 'critical')),

  description TEXT NOT NULL,
  affected_users INTEGER,
  harm_caused TEXT,

  -- Investigation
  root_cause TEXT,
  corrective_actions TEXT,
  preventive_actions TEXT,

  -- Reporting
  reported_to_authorities BOOLEAN DEFAULT false,
  authority_notification_date TIMESTAMP,
  authority_response TEXT,

  status VARCHAR(50) CHECK (status IN ('open', 'investigating', 'resolved', 'closed')),

  reported_by INTEGER REFERENCES users(id),
  assigned_to INTEGER REFERENCES users(id),

  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Risk scoring tied to modification classes
CREATE TABLE IF NOT EXISTS modification_risk_scores (
  id SERIAL PRIMARY KEY,
  submission_id INTEGER REFERENCES submissions(id) ON DELETE CASCADE,
  modification_class INTEGER REFERENCES modification_classes(class_number),

  -- Risk dimensions (aligned with modification class)
  licensing_risk INTEGER CHECK (licensing_risk >= 0 AND licensing_risk <= 100),
  data_governance_risk INTEGER CHECK (data_governance_risk >= 0 AND data_governance_risk <= 100),
  safety_alignment_risk INTEGER CHECK (safety_alignment_risk >= 0 AND safety_alignment_risk <= 100),
  transparency_risk INTEGER CHECK (transparency_risk >= 0 AND transparency_risk <= 100),
  security_risk INTEGER CHECK (security_risk >= 0 AND security_risk <= 100),
  compliance_risk INTEGER CHECK (compliance_risk >= 0 AND compliance_risk <= 100),

  overall_risk_score INTEGER CHECK (overall_risk_score >= 0 AND overall_risk_score <= 100),
  risk_factors JSONB,

  calculated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_submissions_modification_class ON submissions(modification_class);
CREATE INDEX idx_submissions_conformity_status ON submissions(conformity_status);
CREATE INDEX idx_governance_approvals_submission ON governance_approvals(submission_id);
CREATE INDEX idx_governance_approvals_status ON governance_approvals(approval_status);
CREATE INDEX idx_governance_evidence_submission ON governance_evidence(submission_id);
CREATE INDEX idx_conformity_assessments_submission ON conformity_assessments(submission_id);
CREATE INDEX idx_post_market_monitoring_submission ON post_market_monitoring(submission_id);
CREATE INDEX idx_ai_incidents_submission ON ai_incidents(submission_id);
CREATE INDEX idx_ai_incidents_severity ON ai_incidents(severity);
CREATE INDEX idx_modification_risk_scores_submission ON modification_risk_scores(submission_id);

-- Comments
COMMENT ON TABLE modification_classes IS 'ISO/IEC 42001 + EU AI Act aligned model modification classification system';
COMMENT ON TABLE governance_approvals IS 'Tracks multi-stakeholder approval workflow based on modification class';
COMMENT ON TABLE conformity_assessments IS 'EU AI Act Annex IV conformity assessment documentation';
COMMENT ON TABLE post_market_monitoring IS 'ISO 42001 + EU AI Act post-deployment monitoring requirements';
COMMENT ON TABLE ai_incidents IS 'EU AI Act Article 62 serious incident reporting';
COMMENT ON TABLE modification_risk_scores IS 'Risk scoring tied to modification class requirements';
