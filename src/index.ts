import express, { Request, Response } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import dotenv from 'dotenv';
import rateLimit from 'express-rate-limit';
import submissionsRouter from './routes/submissions';
import uploadsRouter from './routes/uploads';
import referenceRouter from './routes/reference';
import policiesRouter from './routes/policies';
import governanceRouter from './routes/governance';
import modelsRouter from './routes/models';
import aiChatRouter from './routes/ai-chat';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 9501;

// Security middleware
app.use(helmet());
app.use(cors({
  origin: (origin, callback) => {
    // Allow requests from various sources
    const allowedOrigins = [
      'http://localhost:9500',
      'http://localhost:3000',
      /^http:\/\/10\.\d+\.\d+\.\d+:9500$/,  // Local network IPs
      /^http:\/\/192\.168\.\d+\.\d+:9500$/,  // Common local network
      /^http:\/\/172\.\d+\.\d+\.\d+:9500$/,  // Docker network
      /^https:\/\/.*\.vercel\.app$/,  // All Vercel deployments
    ];

    // Add production frontend URL from environment variable
    if (process.env.FRONTEND_URL) {
      allowedOrigins.push(process.env.FRONTEND_URL);
    }

    if (!origin || allowedOrigins.some(allowed =>
      typeof allowed === 'string' ? allowed === origin : allowed.test(origin)
    )) {
      callback(null, true);
    } else {
      console.warn(`CORS blocked origin: ${origin}`);
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true,
}));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP, please try again later.',
});
app.use('/api/', limiter);

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Health check
app.get('/health', (req: Request, res: Response) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// API routes
app.use('/api/submissions', submissionsRouter);
app.use('/api/uploads', uploadsRouter);
app.use('/api/reference', referenceRouter);
app.use('/api/policies', policiesRouter);
app.use('/api/governance', governanceRouter);
app.use('/api/models', modelsRouter);
app.use('/api', aiChatRouter);

// Error handling middleware
app.use((err: any, req: Request, res: Response, next: any) => {
  console.error('Error:', err);
  res.status(err.status || 500).json({
    success: false,
    message: err.message || 'Internal server error',
  });
});

// 404 handler
app.use((req: Request, res: Response) => {
  res.status(404).json({
    success: false,
    message: 'Route not found',
  });
});

app.listen(PORT, () => {
  console.log(`🚀 AI Intake API running on port ${PORT}`);
  console.log(`📊 Environment: ${process.env.NODE_ENV || 'development'}`);
});
