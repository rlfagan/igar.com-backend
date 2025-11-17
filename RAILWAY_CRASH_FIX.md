# Railway Crash Fix Guide

## Problem

Railway is crashing with a 502 error. The backend cannot start due to a database migration error:

```
❌ Migration failed: error: duplicate key value violates unique constraint "modification_classes_class_number_key"
Detail: Key (class_number)=(0) already exists.
```

## Root Cause

1. Both `schema.sql` and migration `009_ai_governance_framework.sql` were inserting data into the `modification_classes` table
2. The migration script was running on every startup attempt
3. This caused duplicate key constraint violations
4. Railway entered a crash loop, repeatedly trying and failing to start

## Solution

The fix involves two parts:

### Part 1: Fix the Migration Script (ALREADY DONE ✅)

I've already updated `/Users/ronanfagan/igar-backend/src/db/migrate.ts` to be idempotent:
- Created a `schema_migrations` tracking table
- Only runs each migration once
- Skips already-applied migrations
- Committed in: `0743f13 Make migrations idempotent with tracking table`

### Part 2: Clean the Database (YOU NEED TO DO THIS)

Since the database already has duplicate data from previous failed attempts, we need to reset it:

```bash
cd /Users/ronanfagan/igar-backend

# Run the database fix script
./fix-railway-database.sh
```

This script will:
1. Drop the `schema_migrations` table (if it exists)
2. Delete duplicate entries from `modification_classes`
3. Allow Railway to restart with a clean slate

### Part 3: Run Setup (AFTER DATABASE IS FIXED)

Once Railway is stable (no more crashes), run the complete setup:

```bash
cd /Users/ronanfagan/igar-backend

# Run migrations and seed all data
./run-all-railway-setup.sh
```

Or run individually:
```bash
./run-railway-migrate.sh              # Step 1: Run migrations
./run-railway-seed-departments.sh     # Step 2: Seed departments
./run-railway-seed-catalog.sh         # Step 3: Seed AI catalog
```

## Verification

After running the fix, verify Railway is working:

```bash
# Check if backend responds
curl https://igarcom-backend-production.up.railway.app/health

# Should return:
# {"status":"ok"}
```

## Scripts Created

- `fix-railway-database.sh` - Clears duplicate data (run this first)
- `run-all-railway-setup.sh` - Complete setup (migrations + seeds)
- `run-railway-migrate.sh` - Just migrations
- `run-railway-seed-departments.sh` - Just departments
- `run-railway-seed-catalog.sh` - Just catalog

## Timeline

1. ✅ Fixed migration script to be idempotent (commit `0743f13`)
2. ✅ Created fix and setup scripts
3. ⏳ **YOU ARE HERE** - Need to run `./fix-railway-database.sh`
4. ⏳ Wait for Railway to stabilize
5. ⏳ Run `./run-all-railway-setup.sh` to seed data
6. ⏳ Test policy creation at https://igar.ai/admin/policies/create
