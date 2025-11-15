-- AI Intake System Database Schema

-- Users table (for authentication)
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    role VARCHAR(50) DEFAULT 'user',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Intake submissions
CREATE TABLE IF NOT EXISTS submissions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),

    -- Section 1: Project & Model Overview
    project_name VARCHAR(255) NOT NULL,
    model_name VARCHAR(255) NOT NULL,
    model_type VARCHAR(100) NOT NULL,
    model_type_other VARCHAR(255),
    model_origin VARCHAR(50) NOT NULL,
    model_origin_name VARCHAR(255),
    model_origin_version VARCHAR(100),
    model_origin_url TEXT,
    vendor_name VARCHAR(255),

    -- Section 2: Intended Use & Scope
    intended_purpose TEXT NOT NULL,
    business_impact_category VARCHAR(50) NOT NULL,
    regulated_decisions JSONB DEFAULT '[]',
    human_in_loop BOOLEAN NOT NULL,

    -- Section 3: Data Used
    data_sources TEXT NOT NULL,
    contains_customer_data VARCHAR(20),
    labels_modified BOOLEAN,
    labels_description TEXT,

    -- Section 4: Model Modifications
    modifications JSONB DEFAULT '[]',
    training_config_location TEXT,

    -- Section 5: Operational Deployment
    deployment_location VARCHAR(100) NOT NULL,
    deployment_location_other VARCHAR(255),
    access_teams TEXT,
    input_format VARCHAR(255),
    output_format VARCHAR(255),

    -- Section 6: Risk & Safety
    sees_sensitive_data VARCHAR(20),
    safety_features JSONB DEFAULT '[]',
    known_risks TEXT,

    -- Metadata
    status VARCHAR(50) DEFAULT 'submitted',
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reviewed_at TIMESTAMP,
    reviewer_id INTEGER REFERENCES users(id),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Artifacts/attachments
CREATE TABLE IF NOT EXISTS artifacts (
    id SERIAL PRIMARY KEY,
    submission_id INTEGER REFERENCES submissions(id) ON DELETE CASCADE,
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_type VARCHAR(100),
    file_size INTEGER,
    artifact_type VARCHAR(100),
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- AI Review results
CREATE TABLE IF NOT EXISTS ai_reviews (
    id SERIAL PRIMARY KEY,
    submission_id INTEGER REFERENCES submissions(id) ON DELETE CASCADE,
    review_type VARCHAR(50) NOT NULL,

    -- Overall assessment
    risk_score INTEGER,
    risk_level VARCHAR(20),
    approval_recommendation VARCHAR(50),

    -- Detailed findings
    findings JSONB NOT NULL,
    regulatory_concerns JSONB,
    security_concerns JSONB,
    data_privacy_concerns JSONB,
    bias_concerns JSONB,

    -- Recommendations
    recommendations JSONB,
    required_actions JSONB,

    -- PII Detection results
    pii_detected BOOLEAN,
    pii_details JSONB,

    -- Vendor evaluation (if COTS)
    vendor_evaluation JSONB,

    -- Full AI response
    full_review TEXT,

    reviewed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Audit log
CREATE TABLE IF NOT EXISTS audit_log (
    id SERIAL PRIMARY KEY,
    submission_id INTEGER REFERENCES submissions(id) ON DELETE SET NULL,
    user_id INTEGER REFERENCES users(id),
    action VARCHAR(100) NOT NULL,
    details JSONB,
    ip_address VARCHAR(45),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Comments/notes
CREATE TABLE IF NOT EXISTS comments (
    id SERIAL PRIMARY KEY,
    submission_id INTEGER REFERENCES submissions(id) ON DELETE CASCADE,
    user_id INTEGER REFERENCES users(id),
    comment TEXT NOT NULL,
    is_internal BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_submissions_user_id ON submissions(user_id);
CREATE INDEX IF NOT EXISTS idx_submissions_status ON submissions(status);
CREATE INDEX IF NOT EXISTS idx_submissions_created_at ON submissions(created_at);
CREATE INDEX IF NOT EXISTS idx_artifacts_submission_id ON artifacts(submission_id);
CREATE INDEX IF NOT EXISTS idx_ai_reviews_submission_id ON ai_reviews(submission_id);
CREATE INDEX IF NOT EXISTS idx_audit_log_submission_id ON audit_log(submission_id);
CREATE INDEX IF NOT EXISTS idx_comments_submission_id ON comments(submission_id);
