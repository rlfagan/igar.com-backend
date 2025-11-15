import { Router, Request, Response } from 'express';
import pool from '../db';
import { z } from 'zod';

const router = Router();

/**
 * GET /api/policies
 * Get all available form policies
 */
router.get('/', async (req: Request, res: Response) => {
  try {
    const { industry } = req.query;

    let query = 'SELECT * FROM form_policies WHERE is_active = true';
    const values: any[] = [];

    if (industry) {
      query += ' AND industry = $1';
      values.push(industry);
    }

    query += ' ORDER BY is_default DESC, name ASC';

    const result = await pool.query(query, values);

    res.json({
      success: true,
      policies: result.rows,
    });
  } catch (error) {
    console.error('Get policies error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch policies' });
  }
});

/**
 * GET /api/policies/:policyId/form
 * Get complete form configuration for a policy
 */
router.get('/:policyId/form', async (req: Request, res: Response) => {
  try {
    const { policyId } = req.params;
    const { organizationId } = req.query;

    // Get policy info
    const policyResult = await pool.query(
      'SELECT * FROM form_policies WHERE id = $1 AND is_active = true',
      [policyId]
    );

    if (policyResult.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Policy not found' });
    }

    const policy = policyResult.rows[0];

    // Get sections
    const sectionsResult = await pool.query(
      `SELECT * FROM form_sections
       WHERE policy_id = $1 AND is_enabled = true
       ORDER BY order_index ASC`,
      [policyId]
    );

    // Get fields for each section
    const sections = await Promise.all(
      sectionsResult.rows.map(async (section) => {
        const fieldsResult = await pool.query(
          `SELECT * FROM form_fields
           WHERE section_id = $1 AND is_enabled = true
           ORDER BY order_index ASC`,
          [section.id]
        );

        // Apply organization-specific customizations if provided
        let fields = fieldsResult.rows;
        if (organizationId) {
          fields = await applyOrganizationCustomizations(
            parseInt(organizationId as string),
            fields
          );
        }

        return {
          ...section,
          fields,
        };
      })
    );

    res.json({
      success: true,
      policy,
      sections,
    });
  } catch (error) {
    console.error('Get form configuration error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch form configuration' });
  }
});

/**
 * GET /api/policies/default
 * Get the default policy form
 */
router.get('/default/form', async (req: Request, res: Response) => {
  try {
    const { organizationId } = req.query;

    // Get default policy
    const policyResult = await pool.query(
      'SELECT * FROM form_policies WHERE is_default = true AND is_active = true LIMIT 1'
    );

    if (policyResult.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'No default policy found' });
    }

    const policy = policyResult.rows[0];
    const policyId = policy.id;

    // Get sections
    const sectionsResult = await pool.query(
      `SELECT * FROM form_sections
       WHERE policy_id = $1 AND is_enabled = true
       ORDER BY order_index ASC`,
      [policyId]
    );

    // Get fields for each section
    const sections = await Promise.all(
      sectionsResult.rows.map(async (section) => {
        const fieldsResult = await pool.query(
          `SELECT * FROM form_fields
           WHERE section_id = $1 AND is_enabled = true
           ORDER BY order_index ASC`,
          [section.id]
        );

        // Apply organization-specific customizations if provided
        let fields = fieldsResult.rows;
        if (organizationId) {
          fields = await applyOrganizationCustomizations(
            parseInt(organizationId as string),
            fields
          );
        }

        return {
          ...section,
          fields,
        };
      })
    );

    res.json({
      success: true,
      policy,
      sections,
    });
  } catch (error) {
    console.error('Get default policy error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch default policy' });
  }
});

/**
 * POST /api/policies
 * Create a new form policy (Admin only)
 */
router.post('/', async (req: Request, res: Response) => {
  try {
    const schema = z.object({
      name: z.string().min(1),
      slug: z.string().min(1),
      description: z.string().optional(),
      industry: z.string().optional(),
      is_default: z.boolean().optional(),
    });

    const data = schema.parse(req.body);

    const result = await pool.query(
      `INSERT INTO form_policies (name, slug, description, industry, is_default, created_by)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING *`,
      [
        data.name,
        data.slug,
        data.description,
        data.industry,
        data.is_default || false,
        (req as any).user?.id || 1,
      ]
    );

    res.status(201).json({
      success: true,
      policy: result.rows[0],
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ success: false, errors: error.errors });
    }
    console.error('Create policy error:', error);
    res.status(500).json({ success: false, message: 'Failed to create policy' });
  }
});

/**
 * POST /api/policies/:policyId/sections
 * Add a section to a policy (Admin only)
 */
router.post('/:policyId/sections', async (req: Request, res: Response) => {
  try {
    const { policyId } = req.params;
    const schema = z.object({
      section_key: z.string().min(1),
      title: z.string().min(1),
      description: z.string().optional(),
      order_index: z.number().int(),
      is_required: z.boolean().optional(),
    });

    const data = schema.parse(req.body);

    const result = await pool.query(
      `INSERT INTO form_sections (policy_id, section_key, title, description, order_index, is_required)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING *`,
      [policyId, data.section_key, data.title, data.description, data.order_index, data.is_required ?? true]
    );

    res.status(201).json({
      success: true,
      section: result.rows[0],
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ success: false, errors: error.errors });
    }
    console.error('Create section error:', error);
    res.status(500).json({ success: false, message: 'Failed to create section' });
  }
});

/**
 * POST /api/policies/sections/:sectionId/fields
 * Add a field to a section (Admin only)
 */
router.post('/sections/:sectionId/fields', async (req: Request, res: Response) => {
  try {
    const { sectionId } = req.params;
    const schema = z.object({
      field_key: z.string().min(1),
      label: z.string().min(1),
      field_type: z.enum(['text', 'textarea', 'select', 'multiselect', 'checkbox', 'radio', 'file']),
      placeholder: z.string().optional(),
      help_text: z.string().optional(),
      order_index: z.number().int(),
      is_required: z.boolean().optional(),
      validation_rules: z.any().optional(),
      options: z.any().optional(),
      default_value: z.string().optional(),
    });

    const data = schema.parse(req.body);

    const result = await pool.query(
      `INSERT INTO form_fields
       (section_id, field_key, label, field_type, placeholder, help_text, order_index,
        is_required, validation_rules, options, default_value)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
       RETURNING *`,
      [
        sectionId,
        data.field_key,
        data.label,
        data.field_type,
        data.placeholder,
        data.help_text,
        data.order_index,
        data.is_required ?? false,
        data.validation_rules ? JSON.stringify(data.validation_rules) : null,
        data.options ? JSON.stringify(data.options) : null,
        data.default_value,
      ]
    );

    res.status(201).json({
      success: true,
      field: result.rows[0],
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ success: false, errors: error.errors });
    }
    console.error('Create field error:', error);
    res.status(500).json({ success: false, message: 'Failed to create field' });
  }
});

/**
 * PUT /api/policies/customizations/:organizationId/:fieldId
 * Customize a field for a specific organization
 */
router.put('/customizations/:organizationId/:fieldId', async (req: Request, res: Response) => {
  try {
    const { organizationId, fieldId } = req.params;
    const schema = z.object({
      custom_label: z.string().optional(),
      custom_help_text: z.string().optional(),
      custom_options: z.any().optional(),
      custom_validation_rules: z.any().optional(),
      is_enabled: z.boolean().optional(),
    });

    const data = schema.parse(req.body);

    const result = await pool.query(
      `INSERT INTO policy_customizations
       (organization_id, field_id, custom_label, custom_help_text, custom_options, custom_validation_rules, is_enabled)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       ON CONFLICT (organization_id, field_id)
       DO UPDATE SET
         custom_label = EXCLUDED.custom_label,
         custom_help_text = EXCLUDED.custom_help_text,
         custom_options = EXCLUDED.custom_options,
         custom_validation_rules = EXCLUDED.custom_validation_rules,
         is_enabled = EXCLUDED.is_enabled,
         updated_at = CURRENT_TIMESTAMP
       RETURNING *`,
      [
        organizationId,
        fieldId,
        data.custom_label,
        data.custom_help_text,
        data.custom_options ? JSON.stringify(data.custom_options) : null,
        data.custom_validation_rules ? JSON.stringify(data.custom_validation_rules) : null,
        data.is_enabled,
      ]
    );

    res.json({
      success: true,
      customization: result.rows[0],
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ success: false, errors: error.errors });
    }
    console.error('Customize field error:', error);
    res.status(500).json({ success: false, message: 'Failed to customize field' });
  }
});

/**
 * Helper: Apply organization customizations to fields
 */
async function applyOrganizationCustomizations(organizationId: number, fields: any[]) {
  const customizationsResult = await pool.query(
    'SELECT * FROM policy_customizations WHERE organization_id = $1',
    [organizationId]
  );

  const customizationsMap = new Map(
    customizationsResult.rows.map((c) => [c.field_id, c])
  );

  return fields.map((field) => {
    const customization = customizationsMap.get(field.id);
    if (!customization) return field;

    return {
      ...field,
      label: customization.custom_label || field.label,
      help_text: customization.custom_help_text || field.help_text,
      options: customization.custom_options || field.options,
      validation_rules: customization.custom_validation_rules || field.validation_rules,
      is_enabled: customization.is_enabled !== null ? customization.is_enabled : field.is_enabled,
    };
  });
}

/**
 * POST /api/policies/:policyId/versions
 * Create a new version snapshot of a policy (Admin only)
 */
router.post('/:policyId/versions', async (req: Request, res: Response) => {
  try {
    const { policyId } = req.params;
    const schema = z.object({
      version_name: z.string().optional(),
    });

    const data = schema.parse(req.body);

    const result = await pool.query(
      'SELECT create_policy_version($1, $2, $3) as version_id',
      [policyId, data.version_name, (req as any).user?.id || 1]
    );

    const versionId = result.rows[0].version_id;

    res.status(201).json({
      success: true,
      version_id: versionId,
      message: 'Version created successfully',
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ success: false, errors: error.errors });
    }
    console.error('Create version error:', error);
    res.status(500).json({ success: false, message: 'Failed to create version' });
  }
});

/**
 * GET /api/policies/:policyId/versions
 * Get version history for a policy
 */
router.get('/:policyId/versions', async (req: Request, res: Response) => {
  try {
    const { policyId } = req.params;

    const result = await pool.query(
      `SELECT v.*, u.full_name as created_by_name
       FROM policy_versions v
       LEFT JOIN users u ON v.created_by = u.id
       WHERE v.policy_id = $1
       ORDER BY v.version_number DESC`,
      [policyId]
    );

    res.json({
      success: true,
      versions: result.rows,
    });
  } catch (error) {
    console.error('Get versions error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch versions' });
  }
});

/**
 * POST /api/policies/versions/:versionId/restore
 * Restore a policy to a previous version (Admin only)
 */
router.post('/versions/:versionId/restore', async (req: Request, res: Response) => {
  try {
    const { versionId } = req.params;

    const result = await pool.query(
      'SELECT restore_policy_version($1, $2) as success',
      [versionId, (req as any).user?.id || 1]
    );

    if (result.rows[0].success) {
      res.json({
        success: true,
        message: 'Policy restored successfully',
      });
    } else {
      res.status(500).json({
        success: false,
        message: 'Failed to restore policy',
      });
    }
  } catch (error) {
    console.error('Restore version error:', error);
    res.status(500).json({ success: false, message: 'Failed to restore version' });
  }
});

export default router;
