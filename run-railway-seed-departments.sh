#!/bin/bash

# Script to seed departments data on Railway
# Usage: ./run-railway-seed-departments.sh

set -e

echo "🏢 Seeding departments on Railway..."
echo ""

railway ssh --environment=production npm run seed-departments

echo ""
echo "✅ Departments seeded!"
