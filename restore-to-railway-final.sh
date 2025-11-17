#!/bin/bash

# Final script to restore local clean database to Railway
# Uses the ai-intake-db container's psql to connect to Railway

set -e

echo "🔄 Restoring clean database to Railway..."
echo ""

SQL_FILE="igar_clean_database.sql"

if [ ! -f "$SQL_FILE" ]; then
  echo "❌ Error: $SQL_FILE not found!"
  exit 1
fi

echo "📦 Database dump file: $SQL_FILE ($(ls -lh $SQL_FILE | awk '{print $5}'))"
echo ""

echo "Step 1: Getting Railway DATABASE_URL..."
DATABASE_URL=$(railway variables --environment=production 2>/dev/null | grep ^DATABASE_URL | cut -d'=' -f2-)

if [ -z "$DATABASE_URL" ]; then
  echo "❌ Error: Could not get DATABASE_URL from Railway!"
  echo "   Make sure Railway CLI is logged in and linked to the project"
  exit 1
fi

echo "✅ Database URL retrieved"
echo ""

echo "Step 2: Copying SQL file into Docker container..."
docker cp "$SQL_FILE" ai-intake-db:/tmp/restore.sql
echo "✅ SQL file copied to container"
echo ""

echo "Step 3: Restoring database..."
echo "This will:"
echo "  - Drop all existing tables on Railway"
echo "  - Recreate schema"
echo "  - Import all data (modification classes, ref_models, etc.)"
echo ""

# Run psql inside the container with the Railway DATABASE_URL
docker exec -i ai-intake-db bash -c "PGPASSWORD=\$(echo '$DATABASE_URL' | sed -n 's/.*:\([^@]*\)@.*/\1/p') psql '$DATABASE_URL' < /tmp/restore.sql" 2>&1 | tail -30

echo ""
echo "✅ Database restore complete!"
echo ""

echo "Step 4: Verifying database state..."
docker exec ai-intake-db bash -c "psql '$DATABASE_URL' -c 'SELECT COUNT(*) as table_count FROM information_schema.tables WHERE table_schema = '\''public'\'';'" 2>&1 | grep -A 2 "table_count"

echo ""
echo "Step 5: Checking data counts..."
docker exec ai-intake-db bash -c "psql '$DATABASE_URL' -c 'SELECT COUNT(*) as modification_classes FROM modification_classes;'" 2>&1 | grep -A 2 "modification_classes"
docker exec ai-intake-db bash -c "psql '$DATABASE_URL' -c 'SELECT COUNT(*) as ref_models FROM ref_models;'" 2>&1 | grep -A 2 "ref_models"

echo ""
echo "Step 6: Cleaning up..."
docker exec ai-intake-db rm /tmp/restore.sql
echo "✅ Cleanup complete"
echo ""

echo "🎉 Railway database restored successfully!"
echo ""
echo "Next steps:"
echo "  1. Railway backend should restart automatically"
echo "  2. Monitor logs: railway logs --environment=production"
echo "  3. Test health endpoint: curl https://igarcom-backend-production.up.railway.app/health"
