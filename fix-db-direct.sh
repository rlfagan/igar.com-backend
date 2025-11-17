#!/bin/bash

# Direct database fix by connecting to Railway Postgres service
# Usage: ./fix-db-direct.sh

set -e

echo "🔧 Connecting directly to Railway Postgres to fix database..."
echo ""

# Switch to Postgres service and run SQL commands
echo "Step 1: Dropping schema_migrations table..."
railway run --service=Postgres psql -c "DROP TABLE IF EXISTS schema_migrations CASCADE;"
echo "✅ Migration tracking table dropped"
echo ""

echo "Step 2: Clearing duplicate modification_classes data..."
railway run --service=Postgres psql -c "DELETE FROM modification_classes WHERE class_number IN (0, 1, 2, 3, 4, 5, 6);"
echo "✅ Duplicate data cleared"
echo ""

echo "🎉 Database fixed!"
echo ""
echo "Now Railway backend should be able to restart and run migrations cleanly."
echo "Monitor with: railway logs --environment=production"
