import pool from './index';

/**
 * Seed Policy Templates for Different Industries
 *
 * This creates pre-configured form templates that organizations can use
 * based on their industry and regulatory requirements.
 */

async function seedPolicyTemplates() {
  console.log('🔧 Seeding policy templates...');

  // 1. Financial Services Policy (Default - what we currently have)
  const fintechPolicy = await pool.query(`
    INSERT INTO form_policies (name, slug, description, industry, is_default, is_active)
    VALUES ($1, $2, $3, $4, $5, $6)
    RETURNING id
  `, [
    'Financial Services AI Governance',
    'fintech-governance',
    'Comprehensive intake form for financial institutions with focus on ECOA/Reg B, FFIEC, AML/BSA, KYC/CIP compliance',
    'fintech',
    true,
    true
  ]);

  // 2. Healthcare Policy
  const healthcarePolicy = await pool.query(`
    INSERT INTO form_policies (name, slug, description, industry, is_default, is_active)
    VALUES ($1, $2, $3, $4, $5, $6)
    RETURNING id
  `, [
    'Healthcare AI Compliance',
    'healthcare-compliance',
    'Healthcare-specific intake form focused on HIPAA, PHI protection, clinical decision support standards',
    'healthcare',
    false,
    true
  ]);

  // 3. Retail/E-commerce Policy
  const retailPolicy = await pool.query(`
    INSERT INTO form_policies (name, slug, description, industry, is_default, is_active)
    VALUES ($1, $2, $3, $4, $5, $6)
    RETURNING id
  `, [
    'Retail & E-commerce AI',
    'retail-ai',
    'Streamlined intake for retail AI focusing on customer experience, personalization, and data privacy',
    'retail',
    false,
    true
  ]);

  // 4. General Enterprise Policy
  const enterprisePolicy = await pool.query(`
    INSERT INTO form_policies (name, slug, description, industry, is_default, is_active)
    VALUES ($1, $2, $3, $4, $5, $6)
    RETURNING id
  `, [
    'General Enterprise AI',
    'enterprise-general',
    'General-purpose AI intake form suitable for most enterprise use cases',
    'general',
    false,
    true
  ]);

  console.log('✅ Policies created');

  // Seed sections and fields for Financial Services (current form)
  await seedFinancialServicesPolicy(fintechPolicy.rows[0].id);

  // Seed sections and fields for Healthcare
  await seedHealthcarePolicy(healthcarePolicy.rows[0].id);

  // Seed sections and fields for Retail
  await seedRetailPolicy(retailPolicy.rows[0].id);

  // Seed sections and fields for General Enterprise
  await seedEnterprisePolicy(enterprisePolicy.rows[0].id);

  console.log('✅ All policy templates seeded successfully');
}

async function seedFinancialServicesPolicy(policyId: number) {
  console.log('  📋 Seeding Financial Services sections...');

  // Section 1: Project & Model Overview
  const section1 = await pool.query(`
    INSERT INTO form_sections (policy_id, section_key, title, description, order_index, is_required, is_enabled)
    VALUES ($1, $2, $3, $4, $5, $6, $7)
    RETURNING id
  `, [policyId, 'section1', 'Project & Model Overview', 'Basic information about the AI model', 1, true, true]);

  await pool.query(`
    INSERT INTO form_fields (section_id, field_key, label, field_type, placeholder, help_text, order_index, is_required, validation_rules, options)
    VALUES
      ($1, 'project_name', 'Project Name', 'text', 'Enter project name', 'Internal project identifier', 1, true, '{"min": 1, "max": 255}'::jsonb, null),
      ($1, 'model_origin', 'Model Origin', 'select', null, 'Where did this model come from?', 2, true, null, '[{"value":"cots","label":"Commercial Off-The-Shelf (COTS)"},{"value":"open_source","label":"Open Source"},{"value":"homegrown","label":"Homegrown/Custom Built"}]'::jsonb),
      ($1, 'vendor_name', 'Vendor Name', 'text', 'Enter vendor name', 'For COTS models only', 3, false, null, null)
  `, [section1.rows[0].id]);

  // Section 2: Intended Use & Regulatory Scope
  const section2 = await pool.query(`
    INSERT INTO form_sections (policy_id, section_key, title, description, order_index, is_required, is_enabled)
    VALUES ($1, $2, $3, $4, $5, $6, $7)
    RETURNING id
  `, [policyId, 'section2', 'Intended Use & Regulatory Scope', 'How will the model be used and what regulations apply', 2, true, true]);

  await pool.query(`
    INSERT INTO form_fields (section_id, field_key, label, field_type, placeholder, help_text, order_index, is_required, validation_rules, options)
    VALUES
      ($1, 'intended_purpose', 'Intended Purpose', 'textarea', 'Describe the intended use', 'What business problem does this solve?', 1, true, '{"min": 10}'::jsonb, null),
      ($1, 'regulated_decisions', 'System Used For', 'multiselect', null, 'Select all that apply', 2, false, null, '[{"value":"credit","label":"Credit decisions (ECOA/Reg B)"},{"value":"fraud","label":"Fraud decisions (FFIEC, AML/BSA)"},{"value":"kyc","label":"Identity verification (KYC, CIP)"},{"value":"none","label":"None of the above"}]'::jsonb),
      ($1, 'human_in_loop', 'Human in the Loop?', 'radio', null, 'Is there human oversight?', 3, true, null, '[{"value":"true","label":"Yes"},{"value":"false","label":"No"}]'::jsonb)
  `, [section2.rows[0].id]);

  console.log('  ✅ Financial Services policy configured');
}

async function seedHealthcarePolicy(policyId: number) {
  console.log('  📋 Seeding Healthcare sections...');

  // Section 1: Clinical Context
  const section1 = await pool.query(`
    INSERT INTO form_sections (policy_id, section_key, title, description, order_index, is_required, is_enabled)
    VALUES ($1, $2, $3, $4, $5, $6, $7)
    RETURNING id
  `, [policyId, 'section1', 'Clinical Context', 'Clinical application and patient impact', 1, true, true]);

  await pool.query(`
    INSERT INTO form_fields (section_id, field_key, label, field_type, placeholder, help_text, order_index, is_required, validation_rules, options)
    VALUES
      ($1, 'project_name', 'Project Name', 'text', 'Enter project name', null, 1, true, '{"min": 1}'::jsonb, null),
      ($1, 'clinical_use_case', 'Clinical Use Case', 'select', null, 'Primary clinical application', 2, true, null, '[{"value":"diagnosis","label":"Diagnosis Support"},{"value":"treatment","label":"Treatment Planning"},{"value":"monitoring","label":"Patient Monitoring"},{"value":"administrative","label":"Administrative/Operational"}]'::jsonb),
      ($1, 'patient_impact', 'Patient Impact Level', 'select', null, 'Direct impact on patient care decisions', 3, true, null, '[{"value":"high","label":"High - Direct clinical decisions"},{"value":"medium","label":"Medium - Indirect clinical support"},{"value":"low","label":"Low - Administrative only"}]'::jsonb)
  `, [section1.rows[0].id]);

  // Section 2: PHI & Data Privacy
  const section2 = await pool.query(`
    INSERT INTO form_sections (policy_id, section_key, title, description, order_index, is_required, is_enabled)
    VALUES ($1, $2, $3, $4, $5, $6, $7)
    RETURNING id
  `, [policyId, 'section2', 'PHI & Data Privacy', 'Protected Health Information handling', 2, true, true]);

  await pool.query(`
    INSERT INTO form_fields (section_id, field_key, label, field_type, placeholder, help_text, order_index, is_required, validation_rules, options)
    VALUES
      ($1, 'uses_phi', 'Uses Protected Health Information (PHI)?', 'radio', null, 'Does this system process PHI?', 1, true, null, '[{"value":"true","label":"Yes"},{"value":"false","label":"No"}]'::jsonb),
      ($1, 'phi_types', 'PHI Data Types', 'multiselect', null, 'Select all that apply', 2, false, null, '[{"value":"demographic","label":"Demographic Information"},{"value":"diagnosis","label":"Diagnosis Codes"},{"value":"treatment","label":"Treatment Records"},{"value":"lab","label":"Lab Results"},{"value":"imaging","label":"Medical Imaging"}]'::jsonb),
      ($1, 'hipaa_compliance', 'HIPAA Compliance Controls', 'textarea', 'Describe HIPAA safeguards', 'What technical and administrative controls are in place?', 3, true, '{"min": 20}'::jsonb, null)
  `, [section2.rows[0].id]);

  console.log('  ✅ Healthcare policy configured');
}

async function seedRetailPolicy(policyId: number) {
  console.log('  📋 Seeding Retail sections...');

  // Section 1: Customer Experience
  const section1 = await pool.query(`
    INSERT INTO form_sections (policy_id, section_key, title, description, order_index, is_required, is_enabled)
    VALUES ($1, $2, $3, $4, $5, $6, $7)
    RETURNING id
  `, [policyId, 'section1', 'Customer Experience Use Case', 'How this AI enhances customer experience', 1, true, true]);

  await pool.query(`
    INSERT INTO form_fields (section_id, field_key, label, field_type, placeholder, help_text, order_index, is_required, validation_rules, options)
    VALUES
      ($1, 'project_name', 'Project Name', 'text', 'Enter project name', null, 1, true, '{"min": 1}'::jsonb, null),
      ($1, 'use_case_category', 'Use Case Category', 'select', null, 'Primary application area', 2, true, null, '[{"value":"personalization","label":"Personalization & Recommendations"},{"value":"search","label":"Search & Discovery"},{"value":"pricing","label":"Dynamic Pricing"},{"value":"inventory","label":"Inventory Optimization"},{"value":"support","label":"Customer Support"}]'::jsonb),
      ($1, 'customer_facing', 'Customer-Facing?', 'radio', null, 'Is this visible to customers?', 3, true, null, '[{"value":"true","label":"Yes - Customer-facing"},{"value":"false","label":"No - Internal only"}]'::jsonb)
  `, [section1.rows[0].id]);

  // Section 2: Data & Privacy
  const section2 = await pool.query(`
    INSERT INTO form_sections (policy_id, section_key, title, description, order_index, is_required, is_enabled)
    VALUES ($1, $2, $3, $4, $5, $6, $7)
    RETURNING id
  `, [policyId, 'section2', 'Data & Privacy', 'Customer data usage and privacy compliance', 2, true, true]);

  await pool.query(`
    INSERT INTO form_fields (section_id, field_key, label, field_type, placeholder, help_text, order_index, is_required, validation_rules, options)
    VALUES
      ($1, 'customer_data_types', 'Customer Data Types Used', 'multiselect', null, 'What customer data is used?', 1, true, null, '[{"value":"behavioral","label":"Behavioral/Clickstream"},{"value":"purchase","label":"Purchase History"},{"value":"demographic","label":"Demographics"},{"value":"preferences","label":"Stated Preferences"},{"value":"location","label":"Location Data"}]'::jsonb),
      ($1, 'gdpr_compliant', 'GDPR Compliance', 'radio', null, 'For EU customers', 2, true, null, '[{"value":"yes","label":"Yes - GDPR controls in place"},{"value":"no","label":"No - No EU customers"},{"value":"planned","label":"Implementation planned"}]'::jsonb),
      ($1, 'opt_out_mechanism', 'Customer Opt-Out Mechanism', 'text', 'Describe opt-out process', 'How can customers opt out of AI personalization?', 3, false, null, null)
  `, [section2.rows[0].id]);

  console.log('  ✅ Retail policy configured');
}

async function seedEnterprisePolicy(policyId: number) {
  console.log('  📋 Seeding General Enterprise sections...');

  // Simplified general enterprise form
  const section1 = await pool.query(`
    INSERT INTO form_sections (policy_id, section_key, title, description, order_index, is_required, is_enabled)
    VALUES ($1, $2, $3, $4, $5, $6, $7)
    RETURNING id
  `, [policyId, 'section1', 'AI System Overview', 'Basic information about the AI system', 1, true, true]);

  await pool.query(`
    INSERT INTO form_fields (section_id, field_key, label, field_type, placeholder, help_text, order_index, is_required, validation_rules, options)
    VALUES
      ($1, 'project_name', 'Project Name', 'text', 'Enter project name', null, 1, true, '{"min": 1}'::jsonb, null),
      ($1, 'business_function', 'Business Function', 'select', null, 'Which department/function?', 2, true, null, '[{"value":"hr","label":"Human Resources"},{"value":"finance","label":"Finance"},{"value":"operations","label":"Operations"},{"value":"sales","label":"Sales & Marketing"},{"value":"it","label":"IT & Engineering"}]'::jsonb),
      ($1, 'intended_purpose', 'Intended Purpose', 'textarea', 'Describe the purpose', 'What problem does this solve?', 3, true, '{"min": 10}'::jsonb, null),
      ($1, 'risk_level', 'Risk Assessment', 'select', null, 'Initial risk categorization', 4, true, null, '[{"value":"low","label":"Low - Internal tooling"},{"value":"medium","label":"Medium - Business impact"},{"value":"high","label":"High - Critical decisions"}]'::jsonb)
  `, [section1.rows[0].id]);

  console.log('  ✅ General Enterprise policy configured');
}

// Run the seed
seedPolicyTemplates()
  .then(() => {
    console.log('✅ Policy seeding completed');
    process.exit(0);
  })
  .catch((error) => {
    console.error('❌ Policy seeding failed:', error);
    process.exit(1);
  });
