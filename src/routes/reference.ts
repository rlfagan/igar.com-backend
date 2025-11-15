import { Router, Request, Response } from 'express';
import pool from '../db';

const router = Router();

// Get all reference data
router.get('/all', async (req: Request, res: Response) => {
  try {
    const [models, vendors, useCases, dataSources, platforms, safety, regulatory] = await Promise.all([
      pool.query('SELECT * FROM ref_models ORDER BY name'),
      pool.query('SELECT * FROM ref_vendors ORDER BY name'),
      pool.query('SELECT * FROM ref_use_cases ORDER BY name'),
      pool.query('SELECT * FROM ref_data_sources ORDER BY name'),
      pool.query('SELECT * FROM ref_deployment_platforms ORDER BY name'),
      pool.query('SELECT * FROM ref_safety_features ORDER BY name'),
      pool.query('SELECT * FROM ref_regulatory_frameworks ORDER BY name'),
    ]);

    res.json({
      success: true,
      data: {
        models: models.rows,
        vendors: vendors.rows,
        useCases: useCases.rows,
        dataSources: dataSources.rows,
        deploymentPlatforms: platforms.rows,
        safetyFeatures: safety.rows,
        regulatoryFrameworks: regulatory.rows,
      },
    });
  } catch (error) {
    console.error('Get reference data error:', error);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// Get models by type (for cascading dropdowns)
router.get('/models', async (req: Request, res: Response) => {
  try {
    const { type, category } = req.query;
    let query = 'SELECT * FROM ref_models WHERE 1=1';
    const params: any[] = [];
    let paramIndex = 1;

    if (type) {
      query += ` AND type = $${paramIndex}`;
      params.push(type);
      paramIndex++;
    }

    if (category) {
      query += ` AND category = $${paramIndex}`;
      params.push(category);
      paramIndex++;
    }

    query += ' ORDER BY name';

    const result = await pool.query(query, params);

    res.json({
      success: true,
      models: result.rows,
    });
  } catch (error) {
    console.error('Get models error:', error);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// Get models by vendor
router.get('/models/:vendor', async (req: Request, res: Response) => {
  try {
    const { vendor } = req.params;
    const result = await pool.query(
      'SELECT * FROM ref_models WHERE vendor = $1 ORDER BY name',
      [vendor]
    );

    res.json({
      success: true,
      models: result.rows,
    });
  } catch (error) {
    console.error('Get models by vendor error:', error);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// Get vendors
router.get('/vendors', async (req: Request, res: Response) => {
  try {
    const result = await pool.query('SELECT * FROM ref_vendors ORDER BY name');

    res.json({
      success: true,
      vendors: result.rows,
    });
  } catch (error) {
    console.error('Get vendors error:', error);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

export default router;
