#!/bin/bash

# Script to fix Railway database by clearing migration state
# This allows the idempotent migration script to run fresh
# Usage: ./fix-railway-database.sh

set -e

echo "🔧 Fixing Railway database migration state..."
echo ""

echo "Step 1: Connecting to Railway database..."
echo "This will clear the schema_migrations table so migrations can run fresh."
echo ""

# Use railway run to execute psql commands via DATABASE_URL
railway run --environment=production bash -c 'psql $DATABASE_URL -c "DROP TABLE IF EXISTS schema_migrations CASCADE;"'

echo "✅ Migration tracking table dropped"
echo ""

echo "Step 2: Clearing duplicate modification_classes data..."
railway run --environment=production bash -c 'psql $DATABASE_URL -c "DELETE FROM modification_classes WHERE class_number IN (0, 1, 2, 3, 4, 5, 6);"'

echo "✅ Duplicate data cleared"
echo ""

echo "🎉 Database is ready for fresh migrations!"
echo ""
echo "Next steps:"
echo "  1. Railway should automatically restart and run migrations"
echo "  2. If not, run: railway logs --environment=production"
echo "  3. Once stable, run: ./run-all-railway-setup.sh"
