# IGAR Backend

Express + TypeScript backend API for the IGAR (Intelligent Governance, Assurance & Risk) platform.

## Tech Stack

- **Framework**: Express.js
- **Language**: TypeScript
- **Database**: PostgreSQL
- **ORM**: Sequelize
- **AI Integration**: Anthropic Claude API
- **File Upload**: Multer

## Getting Started

### Prerequisites

- Node.js 20.x or higher
- PostgreSQL 14+
- npm

### Installation

```bash
npm install
```

### Database Setup

1. Create a PostgreSQL database
2. Copy `.env.example` to `.env`
3. Update database credentials in `.env`

### Run Migrations

```bash
npm run migrate
```

### Seed Database (Optional)

```bash
npm run seed
```

### Development

```bash
npm run dev
```

Server runs on `http://localhost:3001`

### Build

```bash
npm run build
npm start
```

## Environment Variables

Create a `.env` file:

```env
NODE_ENV=development
PORT=3001

# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=ai_intake
DB_USER=postgres
DB_PASSWORD=your_password

# AI
ANTHROPIC_API_KEY=your_anthropic_api_key

# Frontend URL for CORS
FRONTEND_URL=http://localhost:3000
```

## Deployment

This backend is designed to deploy on Railway.

### Railway Deployment

1. Create a new Railway project
2. Add PostgreSQL service
3. Connect this repository
4. Add environment variables (see above)
5. Deploy

Railway will automatically use the `Dockerfile` for deployment.

## API Endpoints

### Submissions
- `POST /api/submissions` - Create new intake submission
- `GET /api/submissions` - List all submissions
- `GET /api/submissions/:id` - Get submission by ID
- `PUT /api/submissions/:id` - Update submission
- `DELETE /api/submissions/:id` - Delete submission

### AI Review
- `POST /api/ai-review` - Get automated AI review for submission

### AI Chat
- `POST /api/ai-chat` - Chat with AI governance assistant

### File Upload
- `POST /api/upload` - Upload artifact files
- `GET /api/files/:filename` - Download uploaded file

### Governance Policies
- `GET /api/policies` - List governance policies
- `POST /api/policies` - Create new policy
- `PUT /api/policies/:id` - Update policy
- `DELETE /api/policies/:id` - Delete policy

## Project Structure

```
src/
├── index.ts          # App entry point
├── models/           # Sequelize models
│   └── submission.ts
├── routes/           # API route handlers
│   ├── submissions.ts
│   ├── ai-review.ts
│   ├── ai-chat.ts
│   ├── upload.ts
│   └── policies.ts
└── migrations/       # Database migrations
```

## License

See LICENSE file in repository root.
