import pool from '../db';

/**
 * AI Governance Risk Scoring Service
 * ISO/IEC 42001 + EU AI Act Aligned
 *
 * Calculates risk scores based on modification class and submission details
 */

interface RiskDimensions {
  licensing_risk: number;
  data_governance_risk: number;
  safety_alignment_risk: number;
  transparency_risk: number;
  security_risk: number;
  compliance_risk: number;
}

interface RiskCalculationResult {
  overall_risk_score: number;
  risk_dimensions: RiskDimensions;
  risk_factors: string[];
  recommended_approval_status: string;
  required_reviewers: string[];
  mandatory_evidence: string[];
}

/**
 * Calculate risk score based on modification class
 */
export async function calculateModificationClassRisk(
  submissionId: number,
  modificationClass: number,
  submissionData: any
): Promise<RiskCalculationResult> {

  // Get modification class details
  const classResult = await pool.query(
    'SELECT * FROM modification_classes WHERE class_number = $1',
    [modificationClass]
  );

  if (classResult.rows.length === 0) {
    throw new Error(`Invalid modification class: ${modificationClass}`);
  }

  const modClass = classResult.rows[0];

  // Calculate risk dimensions based on class
  const riskDimensions = calculateRiskDimensions(modificationClass, submissionData, modClass);

  // Calculate overall risk score (weighted average)
  const overallRisk = calculateOverallRisk(riskDimensions, modificationClass);

  // Identify risk factors
  const riskFactors = identifyRiskFactors(riskDimensions, submissionData, modificationClass);

  // Determine required reviewers based on class
  const requiredReviewers = await getRequiredReviewers(modificationClass);

  // Get mandatory evidence for this class
  const mandatoryEvidence = modClass.required_evidence || [];

  // Determine approval status
  const approvalStatus = determineApprovalStatus(overallRisk, modificationClass);

  // Save risk score to database
  await pool.query(
    `INSERT INTO modification_risk_scores
     (submission_id, modification_class, licensing_risk, data_governance_risk,
      safety_alignment_risk, transparency_risk, security_risk, compliance_risk,
      overall_risk_score, risk_factors)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)`,
    [
      submissionId,
      modificationClass,
      riskDimensions.licensing_risk,
      riskDimensions.data_governance_risk,
      riskDimensions.safety_alignment_risk,
      riskDimensions.transparency_risk,
      riskDimensions.security_risk,
      riskDimensions.compliance_risk,
      overallRisk,
      JSON.stringify(riskFactors)
    ]
  );

  return {
    overall_risk_score: overallRisk,
    risk_dimensions: riskDimensions,
    risk_factors: riskFactors,
    recommended_approval_status: approvalStatus,
    required_reviewers: requiredReviewers,
    mandatory_evidence: mandatoryEvidence
  };
}

/**
 * Calculate individual risk dimensions
 */
function calculateRiskDimensions(
  modificationClass: number,
  submissionData: any,
  modClass: any
): RiskDimensions {

  // Base risk by class (from defined risk levels)
  const baseRiskMap: Record<string, number> = {
    'Low': 10,
    'Medium': 35,
    'Medium-High': 55,
    'High': 75,
    'Very High': 90
  };

  const baseRisk = baseRiskMap[modClass.risk_level] || 50;

  // Initialize dimensions with base risk
  let dimensions: RiskDimensions = {
    licensing_risk: baseRisk,
    data_governance_risk: baseRisk,
    safety_alignment_risk: baseRisk,
    transparency_risk: baseRisk,
    security_risk: baseRisk,
    compliance_risk: baseRisk
  };

  // Adjust based on class-specific factors
  switch (modificationClass) {
    case 0: // Pure Base Model
      dimensions = calculateClass0Risk(submissionData, baseRisk);
      break;
    case 1: // Prompt Engineering
      dimensions = calculateClass1Risk(submissionData, baseRisk);
      break;
    case 2: // RAG
      dimensions = calculateClass2Risk(submissionData, baseRisk);
      break;
    case 3: // LoRA/PEFT
      dimensions = calculateClass3Risk(submissionData, baseRisk);
      break;
    case 4: // Full Fine-Tuning
      dimensions = calculateClass4Risk(submissionData, baseRisk);
      break;
    case 5: // Safety Alignment
      dimensions = calculateClass5Risk(submissionData, baseRisk);
      break;
    case 6: // Custom Tokenizer
      dimensions = calculateClass6Risk(submissionData, baseRisk);
      break;
  }

  // Ensure all dimensions are within bounds
  Object.keys(dimensions).forEach(key => {
    dimensions[key as keyof RiskDimensions] = Math.max(0, Math.min(100, dimensions[key as keyof RiskDimensions]));
  });

  return dimensions;
}

function calculateClass0Risk(data: any, baseRisk: number): RiskDimensions {
  let licensing = baseRisk;
  let dataGov = 5; // Minimal data governance concerns
  let safety = baseRisk;
  let transparency = baseRisk;
  let security = 10; // Low security risk for vendor models
  let compliance = baseRisk;

  // Adjust based on vendor and license
  if (!data.vendor_name) transparency += 15;
  if (!data.model_origin_version) transparency += 10;

  // Check if license is permissive
  const permissiveLicenses = ['apache-2.0', 'mit', 'bsd'];
  // Note: This would need to be checked from model catalog

  return {
    licensing_risk: licensing,
    data_governance_risk: dataGov,
    safety_alignment_risk: safety,
    transparency_risk: transparency,
    security_risk: security,
    compliance_risk: compliance
  };
}

function calculateClass1Risk(data: any, baseRisk: number): RiskDimensions {
  let licensing = baseRisk - 5;
  let dataGov = baseRisk;
  let safety = baseRisk;
  let transparency = baseRisk - 5;
  let security = baseRisk;
  let compliance = baseRisk;

  // Check if prompts are documented
  if (!data.governance_data?.prompt_templates) {
    transparency += 20;
    compliance += 15;
  }

  // Check for PII in prompts
  if (data.contains_customer_data === 'pii') {
    dataGov += 25;
    compliance += 20;
  }

  return {
    licensing_risk: licensing,
    data_governance_risk: dataGov,
    safety_alignment_risk: safety,
    transparency_risk: transparency,
    security_risk: security,
    compliance_risk: compliance
  };
}

function calculateClass2Risk(data: any, baseRisk: number): RiskDimensions {
  let licensing = baseRisk;
  let dataGov = baseRisk;
  let safety = baseRisk;
  let transparency = baseRisk;
  let security = baseRisk;
  let compliance = baseRisk;

  // RAG-specific checks
  if (!data.data_sources || data.data_sources.trim().length === 0) {
    dataGov += 30;
    transparency += 25;
    compliance += 20;
  }

  if (data.contains_customer_data === 'pii') {
    dataGov += 25;
    security += 20;
    compliance += 25;
  }

  // Check if data lineage is documented
  if (!data.governance_data?.data_lineage) {
    dataGov += 20;
    transparency += 15;
  }

  return {
    licensing_risk: licensing,
    data_governance_risk: dataGov,
    safety_alignment_risk: safety,
    transparency_risk: transparency,
    security_risk: security,
    compliance_risk: compliance
  };
}

function calculateClass3Risk(data: any, baseRisk: number): RiskDimensions {
  let licensing = baseRisk;
  let dataGov = baseRisk;
  let safety = baseRisk;
  let transparency = baseRisk;
  let security = baseRisk;
  let compliance = baseRisk;

  // LoRA/PEFT-specific checks
  if (!data.governance_data?.training_dataset_provenance) {
    dataGov += 25;
    transparency += 20;
    compliance += 20;
  }

  if (!data.governance_data?.safety_tests_conducted) {
    safety += 30;
    compliance += 25;
  }

  if (!data.governance_data?.bias_evaluation) {
    safety += 20;
    compliance += 15;
  }

  if (data.contains_customer_data === 'pii') {
    dataGov += 20;
    compliance += 25;
  }

  return {
    licensing_risk: licensing,
    data_governance_risk: dataGov,
    safety_alignment_risk: safety,
    transparency_risk: transparency,
    security_risk: security,
    compliance_risk: compliance
  };
}

function calculateClass4Risk(data: any, baseRisk: number): RiskDimensions {
  let licensing = baseRisk;
  let dataGov = baseRisk;
  let safety = baseRisk;
  let transparency = baseRisk;
  let security = baseRisk;
  let compliance = baseRisk;

  // Full fine-tuning requires comprehensive documentation
  if (!data.governance_data?.full_dataset_disclosure) {
    dataGov += 25;
    transparency += 25;
    compliance += 30;
  }

  if (!data.governance_data?.privacy_impact_assessment) {
    dataGov += 20;
    compliance += 30;
  }

  if (!data.governance_data?.comprehensive_safety_testing) {
    safety += 35;
    compliance += 30;
  }

  if (!data.governance_data?.red_team_testing) {
    safety += 25;
    security += 20;
  }

  if (!data.governance_data?.conformity_assessment) {
    compliance += 35;
  }

  // High-risk use cases
  const highRiskDecisions = ['ecoa', 'ffiec', 'aml_bsa', 'kyc_cip'];
  const hasHighRisk = data.regulated_decisions?.some((d: string) =>
    highRiskDecisions.includes(d.toLowerCase())
  );

  if (hasHighRisk) {
    compliance += 20;
    safety += 15;
  }

  return {
    licensing_risk: licensing,
    data_governance_risk: dataGov,
    safety_alignment_risk: safety,
    transparency_risk: transparency,
    security_risk: security,
    compliance_risk: compliance
  };
}

function calculateClass5Risk(data: any, baseRisk: number): RiskDimensions {
  let licensing = baseRisk;
  let dataGov = baseRisk;
  let safety = baseRisk;
  let transparency = baseRisk;
  let security = baseRisk;
  let compliance = baseRisk;

  // Safety alignment-specific checks
  if (!data.governance_data?.alignment_methodology) {
    safety += 30;
    transparency += 20;
    compliance += 20;
  }

  if (!data.governance_data?.pre_post_safety_metrics) {
    safety += 25;
    compliance += 20;
  }

  if (!data.governance_data?.false_refusal_analysis) {
    safety += 15;
  }

  if (!data.governance_data?.alignment_dataset_provenance) {
    dataGov += 20;
    transparency += 15;
  }

  return {
    licensing_risk: licensing,
    data_governance_risk: dataGov,
    safety_alignment_risk: safety,
    transparency_risk: transparency,
    security_risk: security,
    compliance_risk: compliance
  };
}

function calculateClass6Risk(data: any, baseRisk: number): RiskDimensions {
  let licensing = baseRisk;
  let dataGov = baseRisk;
  let safety = baseRisk;
  let transparency = baseRisk;
  let security = baseRisk;
  let compliance = baseRisk;

  // Custom tokenizer is substantial modification
  if (!data.governance_data?.tokenizer_specification) {
    transparency += 30;
    compliance += 35;
  }

  if (!data.governance_data?.stability_evaluation) {
    safety += 30;
    security += 25;
  }

  if (!data.governance_data?.full_regression_testing) {
    safety += 25;
    compliance += 25;
  }

  if (!data.governance_data?.substantial_modification_declaration) {
    compliance += 40; // Very serious
  }

  // Tokenizer changes can introduce serious security risks
  security += 15;

  return {
    licensing_risk: licensing,
    data_governance_risk: dataGov,
    safety_alignment_risk: safety,
    transparency_risk: transparency,
    security_risk: security,
    compliance_risk: compliance
  };
}

/**
 * Calculate overall risk score with class-specific weighting
 */
function calculateOverallRisk(dimensions: RiskDimensions, modClass: number): number {
  // Different weights for different classes
  const weights = getWeightsForClass(modClass);

  const overallRisk =
    dimensions.licensing_risk * weights.licensing +
    dimensions.data_governance_risk * weights.dataGov +
    dimensions.safety_alignment_risk * weights.safety +
    dimensions.transparency_risk * weights.transparency +
    dimensions.security_risk * weights.security +
    dimensions.compliance_risk * weights.compliance;

  return Math.round(overallRisk);
}

function getWeightsForClass(modClass: number): Record<string, number> {
  switch (modClass) {
    case 0: // Base model - licensing and transparency most important
      return {
        licensing: 0.30,
        dataGov: 0.05,
        safety: 0.20,
        transparency: 0.25,
        security: 0.10,
        compliance: 0.10
      };
    case 1: // Prompt engineering - transparency and compliance
      return {
        licensing: 0.15,
        dataGov: 0.15,
        safety: 0.25,
        transparency: 0.25,
        security: 0.10,
        compliance: 0.10
      };
    case 2: // RAG - data governance critical
      return {
        licensing: 0.10,
        dataGov: 0.35,
        safety: 0.15,
        transparency: 0.15,
        security: 0.15,
        compliance: 0.10
      };
    case 3: // LoRA/PEFT - balanced but heavy on safety
      return {
        licensing: 0.10,
        dataGov: 0.25,
        safety: 0.25,
        transparency: 0.15,
        security: 0.10,
        compliance: 0.15
      };
    case 4: // Full fine-tuning - all dimensions critical
      return {
        licensing: 0.10,
        dataGov: 0.20,
        safety: 0.25,
        transparency: 0.15,
        security: 0.10,
        compliance: 0.20
      };
    case 5: // Safety alignment - safety is paramount
      return {
        licensing: 0.10,
        dataGov: 0.15,
        safety: 0.40,
        transparency: 0.15,
        security: 0.05,
        compliance: 0.15
      };
    case 6: // Custom tokenizer - compliance and security critical
      return {
        licensing: 0.10,
        dataGov: 0.15,
        safety: 0.20,
        transparency: 0.15,
        security: 0.20,
        compliance: 0.20
      };
    default:
      return {
        licensing: 0.15,
        dataGov: 0.20,
        safety: 0.20,
        transparency: 0.15,
        security: 0.15,
        compliance: 0.15
      };
  }
}

/**
 * Identify specific risk factors
 */
function identifyRiskFactors(
  dimensions: RiskDimensions,
  data: any,
  modClass: number
): string[] {
  const factors: string[] = [];

  // Dimension-specific factors
  if (dimensions.licensing_risk > 50) factors.push('HIGH_LICENSING_RISK');
  if (dimensions.data_governance_risk > 60) factors.push('DATA_GOVERNANCE_CONCERNS');
  if (dimensions.safety_alignment_risk > 60) factors.push('SAFETY_TESTING_REQUIRED');
  if (dimensions.transparency_risk > 50) factors.push('DOCUMENTATION_INSUFFICIENT');
  if (dimensions.security_risk > 50) factors.push('SECURITY_REVIEW_REQUIRED');
  if (dimensions.compliance_risk > 60) factors.push('COMPLIANCE_CONCERNS');

  // Class-specific factors
  if (modClass >= 4 && !data.governance_data?.conformity_assessment) {
    factors.push('CONFORMITY_ASSESSMENT_REQUIRED');
  }

  if (modClass >= 3 && data.contains_customer_data === 'pii') {
    factors.push('PII_IN_TRAINING_DATA');
  }

  if (data.regulated_decisions && data.regulated_decisions.length > 0) {
    factors.push('REGULATED_USE_CASE');
  }

  if (modClass >= 4) {
    factors.push('HIGH_RISK_MODIFICATION');
  }

  if (modClass === 6) {
    factors.push('SUBSTANTIAL_MODIFICATION');
  }

  return factors;
}

/**
 * Get required reviewers for modification class
 */
async function getRequiredReviewers(modClass: number): Promise<string[]> {
  const result = await pool.query(
    `SELECT DISTINCT role_name
     FROM governance_roles
     WHERE $1 = ANY(required_for_classes)
     ORDER BY role_name`,
    [modClass]
  );

  return result.rows.map(row => row.role_name);
}

/**
 * Determine approval status based on risk score
 */
function determineApprovalStatus(riskScore: number, modClass: number): string {
  // Class 4+ always requires formal review
  if (modClass >= 4) {
    return 'pending_review';
  }

  // Risk-based determination for lower classes
  if (riskScore <= 25) {
    return 'auto_approved';
  } else if (riskScore <= 50) {
    return 'conditional_approval';
  } else if (riskScore <= 75) {
    return 'pending_review';
  } else {
    return 'requires_risk_mitigation';
  }
}

export default {
  calculateModificationClassRisk,
  calculateRiskDimensions,
  identifyRiskFactors
};
