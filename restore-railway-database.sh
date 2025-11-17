#!/bin/bash

# Script to restore the clean local database to Railway via docker psql
# Usage: ./restore-railway-database.sh

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
DATABASE_URL=$(railway variables --environment=production | grep DATABASE_URL | cut -d'=' -f2-)

if [ -z "$DATABASE_URL" ]; then
  echo "❌ Error: Could not get DATABASE_URL from Railway!"
  exit 1
fi

echo "✅ Database URL retrieved"
echo ""

echo "Step 2: Restoring database via Docker psql..."
echo "This will:"
echo "  - Drop all existing tables"
echo "  - Recreate schema"
echo "  - Import all data (modification classes, ref_models, etc.)"
echo ""

# Use docker to run psql with the SQL file
docker exec -i ai-intake-db psql "$DATABASE_URL" < "$SQL_FILE"

echo ""
echo "✅ Database restore complete!"
echo ""

echo "Step 3: Verifying database state..."
docker exec -i ai-intake-db psql "$DATABASE_URL" -c "SELECT COUNT(*) as table_count FROM information_schema.tables WHERE table_schema = 'public';"

echo ""
echo "Step 4: Checking data counts..."
docker exec -i ai-intake-db psql "$DATABASE_URL" -c "SELECT COUNT(*) as modification_classes FROM modification_classes;"
docker exec -i ai-intake-db psql "$DATABASE_URL" -c "SELECT COUNT(*) as ref_models FROM ref_models;"

echo ""
echo "🎉 Railway database restored successfully!"
echo ""
echo "Next steps:"
echo "  1. Railway backend should restart automatically"
echo "  2. Monitor logs: railway logs --environment=production"
echo "  3. Test health endpoint: curl https://igarcom-backend-production.up.railway.app/health"
