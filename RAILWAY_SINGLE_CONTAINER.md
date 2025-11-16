# Railway Single-Container Deployment

This configuration runs PostgreSQL and Node.js in the **same container**, eliminating the need for a separate database service.

## What's Inside

- ✅ PostgreSQL 16 running alongside Node.js
- ✅ Supervisor managing both processes
- ✅ Database automatically initialized with all seed data on first run
- ✅ Single container = simpler deployment, no service linking

## How It Works

1. **Entrypoint script** (`/entrypoint.sh`):
   - Checks if PostgreSQL is initialized
   - If not, initializes DB and imports `igar_clean_database.sql`
   - Starts supervisor to run both postgres and node

2. **Supervisor** manages two processes:
   - `postgres`: PostgreSQL server on localhost:5432
   - `app`: Node.js backend (waits 5s for postgres, runs migrations, starts server)

3. **Database persists** in `/var/lib/postgresql/data` (Railway provides persistent storage)

## Environment Variables

Only need to set in Railway:

| Variable | Value |
|----------|-------|
| `NODE_ENV` | `production` |
| `FRONTEND_URL` | `https://igar.ai` |
| `ANTHROPIC_API_KEY` | Your Claude API key |
| `PORT` | `9501` (Railway sets this automatically) |

**DATABASE_URL is set automatically** in the Dockerfile to `postgresql://aiuser:aipassword@localhost:5432/ai_intake`

## Deployment Steps

### 1. Test Build Locally (Optional)

```bash
cd /Users/ronanfagan/igar-backend

# Build the image
docker build -t igar-backend-test .

# Run it
docker run -p 9501:9501 \
  -e NODE_ENV=production \
  -e FRONTEND_URL=http://localhost:9500 \
  igar-backend-test

# Test
curl http://localhost:9501/health
```

### 2. Deploy to Railway

```bash
# Make sure code is committed
git add .
git commit -m "Single-container deployment with embedded PostgreSQL"
git push origin main

# Deploy to Railway
railway up
```

Or link to GitHub and Railway will auto-deploy on push.

### 3. Configure Environment Variables

In Railway dashboard:
1. Go to your service settings
2. Add environment variables (see table above)
3. Redeploy if needed

### 4. Verify

```bash
# Check logs
railway logs

# Test health endpoint
curl https://igarcom-backend-production.up.railway.app/health
```

## Benefits

- ✅ No separate database service to manage
- ✅ No DATABASE_URL configuration needed
- ✅ Database is automatically seeded on first run
- ✅ Simpler deployment and troubleshooting
- ✅ All data persists between deploys

## Important Notes

⚠️ **Data Persistence**: Railway provides persistent storage for `/var/lib/postgresql/data`. Your data will survive container restarts and redeployments.

⚠️ **First Deploy**: The first deployment will take slightly longer (~30s extra) because PostgreSQL needs to initialize and import the database dump.

⚠️ **Backups**: Consider adding a backup strategy for production use. You can `railway ssh` into the container and use `pg_dump` to create backups.

## Troubleshooting

If the container fails to start:

1. **Check logs**: `railway logs`
2. **Common issues**:
   - Port conflict: Railway should automatically assign PORT
   - Database init failed: Check if `/var/lib/postgresql/data` has proper permissions
   - App starts before postgres: Supervisor waits 5s, increase if needed in Dockerfile

3. **SSH into container**: `railway ssh` then check:
   ```bash
   # Check if postgres is running
   ps aux | grep postgres

   # Check if app is running
   ps aux | grep node

   # Check database
   psql postgresql://aiuser:aipassword@localhost:5432/ai_intake -c "SELECT COUNT(*) FROM modification_classes;"
   ```
