#!/bin/bash

# Script to run database migrations on Railway
# Usage: ./run-railway-migrate.sh

set -e

echo "🔄 Running database migrations on Railway..."
echo ""

railway ssh --environment=production npm run migrate

echo ""
echo "✅ Migration complete!"
