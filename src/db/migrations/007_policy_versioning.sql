-- Policy Versioning System

-- Policy versions table (complete snapshots of policies at points in time)
CREATE TABLE IF NOT EXISTS policy_versions (
  id SERIAL PRIMARY KEY,
  policy_id INTEGER REFERENCES form_policies(id) ON DELETE CASCADE,
  version_number INTEGER NOT NULL,
  version_name VARCHAR(255), -- e.g., "v1.0", "Q4 2024 Update"
  snapshot JSONB NOT NULL, -- Complete policy configuration at this version
  created_by INTEGER REFERENCES users(id),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  is_published BOOLEAN DEFAULT false,
  UNIQUE(policy_id, version_number)
);

-- Version change log (detailed field-level changes)
CREATE TABLE IF NOT EXISTS version_change_log (
  id SERIAL PRIMARY KEY,
  version_id INTEGER REFERENCES policy_versions(id) ON DELETE CASCADE,
  change_type VARCHAR(50) NOT NULL, -- 'section_added', 'field_modified', 'field_removed', etc.
  entity_type VARCHAR(50) NOT NULL, -- 'section', 'field', 'policy_metadata'
  entity_id INTEGER, -- ID of the changed entity
  field_name VARCHAR(100), -- For field changes
  old_value JSONB,
  new_value JSONB,
  description TEXT, -- Human-readable change description
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Active version tracking (which version is currently active for each policy)
CREATE TABLE IF NOT EXISTS policy_active_versions (
  id SERIAL PRIMARY KEY,
  policy_id INTEGER REFERENCES form_policies(id) ON DELETE CASCADE UNIQUE,
  version_id INTEGER REFERENCES policy_versions(id) ON DELETE SET NULL,
  activated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  activated_by INTEGER REFERENCES users(id)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_policy_versions_policy ON policy_versions(policy_id);
CREATE INDEX IF NOT EXISTS idx_version_change_log_version ON version_change_log(version_id);
CREATE INDEX IF NOT EXISTS idx_policy_active_versions_policy ON policy_active_versions(policy_id);

-- Function to create a new version snapshot
CREATE OR REPLACE FUNCTION create_policy_version(
  p_policy_id INTEGER,
  p_version_name VARCHAR(255),
  p_created_by INTEGER
) RETURNS INTEGER AS $$
DECLARE
  v_version_number INTEGER;
  v_version_id INTEGER;
  v_snapshot JSONB;
BEGIN
  -- Get next version number
  SELECT COALESCE(MAX(version_number), 0) + 1
  INTO v_version_number
  FROM policy_versions
  WHERE policy_id = p_policy_id;

  -- Build snapshot (policy + sections + fields)
  SELECT jsonb_build_object(
    'policy', (SELECT row_to_json(p.*) FROM form_policies p WHERE p.id = p_policy_id),
    'sections', (
      SELECT jsonb_agg(
        jsonb_build_object(
          'section', s.*,
          'fields', (
            SELECT jsonb_agg(f.* ORDER BY f.order_index)
            FROM form_fields f
            WHERE f.section_id = s.id
          )
        ) ORDER BY s.order_index
      )
      FROM form_sections s
      WHERE s.policy_id = p_policy_id
    )
  ) INTO v_snapshot;

  -- Insert version
  INSERT INTO policy_versions (policy_id, version_number, version_name, snapshot, created_by)
  VALUES (p_policy_id, v_version_number, p_version_name, v_snapshot, p_created_by)
  RETURNING id INTO v_version_id;

  RETURN v_version_id;
END;
$$ LANGUAGE plpgsql;

-- Function to restore a policy to a previous version
CREATE OR REPLACE FUNCTION restore_policy_version(
  p_version_id INTEGER,
  p_restored_by INTEGER
) RETURNS BOOLEAN AS $$
DECLARE
  v_policy_id INTEGER;
  v_snapshot JSONB;
  v_section JSONB;
  v_field JSONB;
  v_new_section_id INTEGER;
BEGIN
  -- Get version snapshot
  SELECT policy_id, snapshot
  INTO v_policy_id, v_snapshot
  FROM policy_versions
  WHERE id = p_version_id;

  IF v_policy_id IS NULL THEN
    RAISE EXCEPTION 'Version not found';
  END IF;

  -- Delete current sections and fields (CASCADE will handle fields)
  DELETE FROM form_sections WHERE policy_id = v_policy_id;

  -- Restore sections from snapshot
  FOR v_section IN SELECT * FROM jsonb_array_elements(v_snapshot->'sections')
  LOOP
    INSERT INTO form_sections (
      policy_id, section_key, title, description, order_index, is_required, is_enabled
    )
    SELECT
      v_policy_id,
      (v_section->'section'->>'section_key')::VARCHAR,
      (v_section->'section'->>'title')::VARCHAR,
      (v_section->'section'->>'description')::TEXT,
      (v_section->'section'->>'order_index')::INTEGER,
      (v_section->'section'->>'is_required')::BOOLEAN,
      (v_section->'section'->>'is_enabled')::BOOLEAN
    RETURNING id INTO v_new_section_id;

    -- Restore fields for this section
    FOR v_field IN SELECT * FROM jsonb_array_elements(v_section->'fields')
    LOOP
      INSERT INTO form_fields (
        section_id, field_key, label, field_type, placeholder, help_text,
        order_index, is_required, is_enabled, validation_rules, options, default_value
      )
      SELECT
        v_new_section_id,
        (v_field->>'field_key')::VARCHAR,
        (v_field->>'label')::VARCHAR,
        (v_field->>'field_type')::VARCHAR,
        (v_field->>'placeholder')::TEXT,
        (v_field->>'help_text')::TEXT,
        (v_field->>'order_index')::INTEGER,
        (v_field->>'is_required')::BOOLEAN,
        (v_field->>'is_enabled')::BOOLEAN,
        (v_field->'validation_rules')::JSONB,
        (v_field->'options')::JSONB,
        (v_field->>'default_value')::TEXT;
    END LOOP;
  END LOOP;

  -- Update active version
  INSERT INTO policy_active_versions (policy_id, version_id, activated_by)
  VALUES (v_policy_id, p_version_id, p_restored_by)
  ON CONFLICT (policy_id)
  DO UPDATE SET version_id = p_version_id, activated_at = NOW(), activated_by = p_restored_by;

  -- Log the restore action
  INSERT INTO policy_audit_log (policy_id, action, changed_by, changes)
  VALUES (
    v_policy_id,
    'version_restored',
    p_restored_by,
    jsonb_build_object('version_id', p_version_id, 'restored_at', NOW())
  );

  RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Comments
COMMENT ON TABLE policy_versions IS 'Complete snapshots of policy configurations at specific points in time';
COMMENT ON TABLE version_change_log IS 'Detailed log of what changed in each version';
COMMENT ON TABLE policy_active_versions IS 'Tracks which version is currently active for each policy';
COMMENT ON FUNCTION create_policy_version IS 'Creates a new version snapshot of a policy';
COMMENT ON FUNCTION restore_policy_version IS 'Restores a policy to a previous version';
