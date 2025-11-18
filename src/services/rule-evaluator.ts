import pool from '../db';

interface Condition {
  field: string;
  operator: string;
  value: any;
  logic?: 'AND' | 'OR'; // Logic operator for combining with next condition
}

interface PolicyRule {
  id: number;
  policy_id: number;
  name: string;
  action: 'approve' | 'deny' | 'review';
  priority: number;
  is_active: boolean;
  conditions: Condition[];
  department_ids: number[];
  stop_on_match: boolean;
  custom_message?: string;
}

interface RuleEvaluationResult {
  matched: boolean;
  rule?: PolicyRule;
  action?: 'approve' | 'deny' | 'review';
  message?: string;
}

/**
 * Evaluate a single condition against submission data
 */
function evaluateCondition(condition: Condition, submissionData: any): boolean {
  const { field, operator, value } = condition;

  // Get the field value from submission data
  // Supports nested fields with dot notation (e.g., "risk_analysis.score")
  const fieldValue = getNestedValue(submissionData, field);

  switch (operator) {
    case '==':
    case 'equals':
      return fieldValue == value;

    case '===':
    case 'strict_equals':
      return fieldValue === value;

    case '!=':
    case 'not_equals':
      return fieldValue != value;

    case '>':
    case 'greater_than':
      return Number(fieldValue) > Number(value);

    case '>=':
    case 'greater_than_or_equal':
      return Number(fieldValue) >= Number(value);

    case '<':
    case 'less_than':
      return Number(fieldValue) < Number(value);

    case '<=':
    case 'less_than_or_equal':
      return Number(fieldValue) <= Number(value);

    case 'contains':
      if (Array.isArray(fieldValue)) {
        return fieldValue.includes(value);
      }
      return String(fieldValue).toLowerCase().includes(String(value).toLowerCase());

    case 'not_contains':
      if (Array.isArray(fieldValue)) {
        return !fieldValue.includes(value);
      }
      return !String(fieldValue).toLowerCase().includes(String(value).toLowerCase());

    case 'starts_with':
      return String(fieldValue).toLowerCase().startsWith(String(value).toLowerCase());

    case 'ends_with':
      return String(fieldValue).toLowerCase().endsWith(String(value).toLowerCase());

    case 'in':
      if (!Array.isArray(value)) {
        console.warn(`Operator 'in' expects array value, got ${typeof value}`);
        return false;
      }
      return value.includes(fieldValue);

    case 'not_in':
      if (!Array.isArray(value)) {
        console.warn(`Operator 'not_in' expects array value, got ${typeof value}`);
        return false;
      }
      return !value.includes(fieldValue);

    case 'is_empty':
      return fieldValue === null || fieldValue === undefined || fieldValue === '' ||
             (Array.isArray(fieldValue) && fieldValue.length === 0);

    case 'is_not_empty':
      return fieldValue !== null && fieldValue !== undefined && fieldValue !== '' &&
             (!Array.isArray(fieldValue) || fieldValue.length > 0);

    case 'regex':
      try {
        const regex = new RegExp(value);
        return regex.test(String(fieldValue));
      } catch (error) {
        console.error(`Invalid regex pattern: ${value}`, error);
        return false;
      }

    default:
      console.warn(`Unknown operator: ${operator}`);
      return false;
  }
}

/**
 * Get nested value from object using dot notation
 */
function getNestedValue(obj: any, path: string): any {
  if (!path) return obj;

  const keys = path.split('.');
  let value = obj;

  for (const key of keys) {
    if (value === null || value === undefined) {
      return undefined;
    }
    value = value[key];
  }

  return value;
}

/**
 * Evaluate all conditions in a rule
 */
function evaluateConditions(conditions: Condition[], submissionData: any): boolean {
  if (!conditions || conditions.length === 0) {
    return true; // No conditions means always match
  }

  let result = evaluateCondition(conditions[0], submissionData);

  for (let i = 1; i < conditions.length; i++) {
    const condition = conditions[i];
    const conditionResult = evaluateCondition(condition, submissionData);

    // Use logic operator from previous condition (defaults to AND)
    const prevLogic = conditions[i - 1].logic || 'AND';

    if (prevLogic === 'OR') {
      result = result || conditionResult;
    } else {
      result = result && conditionResult;
    }
  }

  return result;
}

/**
 * Evaluate policy rules against submission data
 *
 * @param policyId - The policy ID
 * @param submissionData - The submission data to evaluate
 * @param departmentId - Optional department ID to filter rules
 * @returns The first matching rule's action or null if no rules match
 */
export async function evaluateRules(
  policyId: number,
  submissionData: any,
  departmentId?: number
): Promise<RuleEvaluationResult> {
  try {
    // Fetch active rules for this policy, ordered by priority
    const result = await pool.query<PolicyRule>(
      `SELECT * FROM policy_rules
       WHERE policy_id = $1 AND is_active = true
       ORDER BY priority DESC, created_at ASC`,
      [policyId]
    );

    const rules = result.rows;

    if (rules.length === 0) {
      return { matched: false };
    }

    // Evaluate each rule
    for (const rule of rules) {
      // Check if rule applies to this department
      if (departmentId && rule.department_ids && rule.department_ids.length > 0) {
        if (!rule.department_ids.includes(departmentId)) {
          continue; // Skip this rule, it doesn't apply to this department
        }
      }

      // Evaluate conditions
      const conditionsMatch = evaluateConditions(rule.conditions, submissionData);

      if (conditionsMatch) {
        return {
          matched: true,
          rule,
          action: rule.action,
          message: rule.custom_message,
        };
      }

      // If stop_on_match is false, continue evaluating more rules
      // (but we still return the first match, as per typical rule engine behavior)
    }

    return { matched: false };
  } catch (error) {
    console.error('Error evaluating rules:', error);
    throw error;
  }
}

/**
 * Log rule execution for audit purposes
 */
export async function logRuleExecution(
  submissionId: number,
  ruleId: number | null,
  matched: boolean,
  actionTaken: string | null,
  evaluationContext: any
): Promise<void> {
  try {
    await pool.query(
      `INSERT INTO policy_rule_executions (submission_id, rule_id, matched, action_taken, evaluation_context)
       VALUES ($1, $2, $3, $4, $5)`,
      [submissionId, ruleId, matched, actionTaken, JSON.stringify(evaluationContext)]
    );
  } catch (error) {
    console.error('Error logging rule execution:', error);
    // Don't throw - logging failure shouldn't block the submission process
  }
}

/**
 * Apply rule evaluation result to a submission
 */
export async function applyRuleDecision(
  submissionId: number,
  result: RuleEvaluationResult
): Promise<void> {
  if (!result.matched || !result.rule) {
    return;
  }

  try {
    await pool.query(
      `UPDATE submissions
       SET auto_decision = $1,
           auto_decision_rule_id = $2,
           auto_decision_message = $3,
           auto_decision_at = CURRENT_TIMESTAMP
       WHERE id = $4`,
      [
        result.action === 'approve' ? 'approved' :
        result.action === 'deny' ? 'denied' :
        'flagged_for_review',
        result.rule.id,
        result.message,
        submissionId,
      ]
    );
  } catch (error) {
    console.error('Error applying rule decision:', error);
    throw error;
  }
}

/**
 * Get supported operators for UI display
 */
export function getSupportedOperators(): Array<{ value: string; label: string; types: string[] }> {
  return [
    { value: '==', label: 'Equals', types: ['string', 'number', 'boolean'] },
    { value: '!=', label: 'Not Equals', types: ['string', 'number', 'boolean'] },
    { value: '>', label: 'Greater Than', types: ['number'] },
    { value: '>=', label: 'Greater Than or Equal', types: ['number'] },
    { value: '<', label: 'Less Than', types: ['number'] },
    { value: '<=', label: 'Less Than or Equal', types: ['number'] },
    { value: 'contains', label: 'Contains', types: ['string', 'array'] },
    { value: 'not_contains', label: 'Does Not Contain', types: ['string', 'array'] },
    { value: 'starts_with', label: 'Starts With', types: ['string'] },
    { value: 'ends_with', label: 'Ends With', types: ['string'] },
    { value: 'in', label: 'In List', types: ['string', 'number'] },
    { value: 'not_in', label: 'Not In List', types: ['string', 'number'] },
    { value: 'is_empty', label: 'Is Empty', types: ['string', 'array'] },
    { value: 'is_not_empty', label: 'Is Not Empty', types: ['string', 'array'] },
    { value: 'regex', label: 'Matches Regex', types: ['string'] },
  ];
}
