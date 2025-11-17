#!/bin/bash

# Script to seed AI catalog data on Railway
# Usage: ./run-railway-seed-catalog.sh

set -e

echo "🌱 Seeding AI catalog on Railway..."
echo ""

railway ssh --environment=production npm run seed-catalog

echo ""
echo "✅ Catalog seeded!"
