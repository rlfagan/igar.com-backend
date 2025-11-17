# Railway Backend Service Configuration

## Database Connection

**DATABASE_URL:**
```
postgresql://postgres:lOrwJXqrFOkMtusQARjhyLZAOCMAYcyE@caboose.proxy.rlwy.net:59017/railway
```

## Required Environment Variables

Set these in the Railway service Settings → Variables:

| Variable | Value |
|----------|-------|
| `DATABASE_URL` | `postgresql://postgres:lOrwJXqrFOkMtusQARjhyLZAOCMAYcyE@caboose.proxy.rlwy.net:59017/railway` |
| `NODE_ENV` | `production` |
| `FRONTEND_URL` | `https://igar.ai` (or `https://www.igar.ai`) |
| `ANTHROPIC_API_KEY` | Your Claude API key (`sk-ant-...`) |

## Build & Deploy Settings

**Build Command:**
```bash
npm install && npm run build
```

**Start Command:**
```bash
npm run migrate && npm start
```

**Root Directory:**
```
/
```

## What Happens on Deploy

1. ✅ Railway builds the TypeScript code
2. ✅ Runs database migrations (which will skip already-applied migrations)
3. ✅ Starts the Express server on Railway's assigned PORT
4. ✅ Backend connects to existing Postgres database with all data

## Database Status

- ✅ Database is clean and fully restored
- ✅ 7 modification classes loaded
- ✅ 139 AI models in catalog
- ✅ All tables, indexes, and constraints in place
- ✅ Migration tracking table configured

## Code Fixes Applied

- ✅ Fixed database pool error handler (commit `545c0f1`)
- ✅ No more `process.exit(-1)` crashes
- ✅ Pool handles reconnection automatically

## Testing After Deploy

Once deployed, test with:

```bash
# Health check
curl https://your-railway-url.up.railway.app/health

# Should return:
# {"status":"ok","timestamp":"2025-..."}
```

## ✅ Database Restored Successfully

The database has been restored to the new Railway Postgres service:
- ✅ 7 modification classes
- ✅ 139 AI models in ref_models
- ✅ 37 tables created

## Next Steps to Deploy Backend

### 1. Create/Configure Backend Service in Railway

In the Railway dashboard:
1. Create a new service from this GitHub repo (or link existing service)
2. Set the Root Directory to `/` (default)
3. Configure Build & Start commands (see above)

### 2. Link Railway CLI to New Service

```bash
cd /Users/ronanfagan/igar-backend
railway link
# Select: igar-backend project
# Select: production environment
# Select: your backend service
```

### 3. Push Code to Deploy

```bash
git add .
git commit -m "Fix database pool error handler"
git push origin main  # This will trigger Railway deployment
```

Or deploy directly:
```bash
railway up
```

### 4. Verify Deployment

```bash
# Check logs
railway logs

# Test health endpoint
curl https://igarcom-backend-production.up.railway.app/health
```

## Troubleshooting

If the service crashes:
1. Check Railway logs for errors
2. Verify DATABASE_URL is set correctly
3. Ensure all environment variables are present
4. Check that migrations completed successfully
