#!/bin/bash

# Complete Railway database setup script
# Runs migrations and seeds all data
# Usage: ./run-all-railway-setup.sh

set -e

echo "🚀 Starting complete Railway database setup..."
echo ""

echo "Step 1/3: Running migrations..."
railway ssh --environment=production npm run migrate
echo "✅ Migrations complete!"
echo ""

echo "Step 2/3: Seeding departments..."
railway ssh --environment=production npm run seed-departments
echo "✅ Departments seeded!"
echo ""

echo "Step 3/3: Seeding AI catalog..."
railway ssh --environment=production npm run seed-catalog
echo "✅ Catalog seeded!"
echo ""

echo "🎉 Railway database setup complete!"
echo ""
echo "You can now:"
echo "  - Test the API at https://igarcom-backend-production.up.railway.app"
echo "  - Create policies at https://igar.ai/admin/policies/create"
