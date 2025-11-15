import { Router, Request, Response } from 'express';
import multer from 'multer';
import path from 'path';
import pool from '../db';
import * as fs from 'fs';

const router = Router();

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const uploadDir = path.join(__dirname, '../../uploads');
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
    cb(null, uniqueSuffix + '-' + file.originalname);
  },
});

const upload = multer({
  storage,
  limits: {
    fileSize: 50 * 1024 * 1024, // 50MB limit
  },
  fileFilter: (req, file, cb) => {
    // Allow common document and data formats
    const allowedMimes = [
      'application/pdf',
      'application/json',
      'text/plain',
      'text/csv',
      'application/vnd.ms-excel',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'image/png',
      'image/jpeg',
      'application/zip',
      'application/x-yaml',
      'text/yaml',
    ];

    if (allowedMimes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Invalid file type. Allowed: PDF, JSON, CSV, Excel, images, YAML, ZIP'));
    }
  },
});

// Upload artifact for a submission
router.post('/:submissionId', upload.single('file'), async (req: Request, res: Response) => {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, message: 'No file uploaded' });
    }

    const { submissionId } = req.params;
    const { artifact_type } = req.body;

    // Verify submission exists
    const submissionCheck = await pool.query('SELECT id FROM submissions WHERE id = $1', [submissionId]);
    if (submissionCheck.rows.length === 0) {
      // Clean up uploaded file
      fs.unlinkSync(req.file.path);
      return res.status(404).json({ success: false, message: 'Submission not found' });
    }

    // Save artifact metadata to database
    const query = `
      INSERT INTO artifacts (submission_id, file_name, file_path, file_type, file_size, artifact_type)
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING *
    `;

    const values = [
      submissionId,
      req.file.originalname,
      req.file.path,
      req.file.mimetype,
      req.file.size,
      artifact_type || 'other',
    ];

    const result = await pool.query(query, values);

    res.status(201).json({
      success: true,
      artifact: result.rows[0],
    });
  } catch (error) {
    console.error('Upload error:', error);
    // Clean up file on error
    if (req.file) {
      fs.unlinkSync(req.file.path);
    }
    res.status(500).json({ success: false, message: 'Upload failed' });
  }
});

// Get artifacts for a submission
router.get('/:submissionId', async (req: Request, res: Response) => {
  try {
    const { submissionId } = req.params;

    const query = 'SELECT * FROM artifacts WHERE submission_id = $1 ORDER BY uploaded_at DESC';
    const result = await pool.query(query, [submissionId]);

    res.json({
      success: true,
      artifacts: result.rows,
    });
  } catch (error) {
    console.error('Get artifacts error:', error);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// Delete an artifact
router.delete('/:artifactId', async (req: Request, res: Response) => {
  try {
    const { artifactId } = req.params;

    // Get artifact info
    const getQuery = 'SELECT * FROM artifacts WHERE id = $1';
    const getResult = await pool.query(getQuery, [artifactId]);

    if (getResult.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Artifact not found' });
    }

    const artifact = getResult.rows[0];

    // Delete file from disk
    if (fs.existsSync(artifact.file_path)) {
      fs.unlinkSync(artifact.file_path);
    }

    // Delete from database
    await pool.query('DELETE FROM artifacts WHERE id = $1', [artifactId]);

    res.json({
      success: true,
      message: 'Artifact deleted successfully',
    });
  } catch (error) {
    console.error('Delete artifact error:', error);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

export default router;
