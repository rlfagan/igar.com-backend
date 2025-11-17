# Railway Database Restore Instructions

## Option 1: Use the Restore Script (Recommended)

We've exported your clean local database to `igar_clean_database.sql` (148KB).

To restore it to Railway, run:

```bash
cd /Users/ronanfagan/igar-backend

# Get Railway DATABASE_URL
DATABASE_URL=$(railway variables --environment=production | grep ^DATABASE_URL | cut -d'=' -f2-)

# Restore using local psql (if you have PostgreSQL installed)
psql "$DATABASE_URL" < igar_clean_database.sql

# Verify
psql "$DATABASE_URL" -c "SELECT COUNT(*) FROM modification_classes;"
psql "$DATABASE_URL" -c "SELECT COUNT(*) FROM ref_models;"
```

## Option 2: Via Railway CLI with Docker

If you don't have PostgreSQL installed locally, use Docker:

```bash
cd /Users/ronanfagan/igar-backend

# Get Railway DATABASE_URL
DATABASE_URL=$(railway variables --environment=production | grep ^DATABASE_URL | cut -d'=' -f2-)

# Use docker with the postgres image to run psql
docker run --rm -i -v "$(pwd):/sql" postgres:16-alpine psql "$DATABASE_URL" < /sql/igar_clean_database.sql
```

## Option 3: Manual Copy/Paste (if above methods fail)

If the file is too large for Railway's psql terminal, split the restore into parts:

1. Connect to Railway Postgres:
   ```bash
   railway run --service=Postgres psql
   ```

2. Run these commands in order:
   ```sql
   -- Drop all existing tables
   DROP SCHEMA public CASCADE;
   CREATE SCHEMA public;
   ```

3. Then manually run the schema.sql and seed scripts:
   ```bash
   # From your local terminal
   railway run --service=backend npm run migrate
   railway run --service=backend npm run seed-catalog
   ```

## What's in the Database Dump?

The `igar_clean_database.sql` file contains:
- ✅ Full schema (21 tables)
- ✅ 7 modification classes
- ✅ 139 AI models in ref_models
- ✅ All reference data (vendors, use cases, frameworks, etc.)
- ✅ Proper indexes and constraints
- ✅ No migration conflicts

## After Restore

Once restored, Railway should:
1. Detect the database changes
2. Restart the backend automatically
3. Backend should start successfully (no migration errors!)

Verify with:
```bash
curl https://igarcom-backend-production.up.railway.app/health
# Should return: {"status":"ok"}
```
