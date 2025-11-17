#!/bin/sh
set -e

# Create postgres socket directory
mkdir -p /run/postgresql
chown postgres:postgres /run/postgresql

# Initialize postgres if not already done
if [ ! -s /var/lib/postgresql/data/PG_VERSION ]; then
  echo "Initializing PostgreSQL database..."
  su-exec postgres initdb -D /var/lib/postgresql/data

  # Configure PostgreSQL to use port 5432 (not PORT env var from Railway)
  echo "port = 5432" >> /var/lib/postgresql/data/postgresql.conf

  # Start postgres temporarily
  su-exec postgres pg_ctl -D /var/lib/postgresql/data -w start

  # Create database and user
  su-exec postgres psql -c "CREATE DATABASE ai_intake;"
  su-exec postgres psql -c "CREATE USER aiuser WITH PASSWORD 'aipassword';" || true
  su-exec postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE ai_intake TO aiuser;"
  su-exec postgres psql -d ai_intake -c "GRANT ALL ON SCHEMA public TO aiuser;"
  su-exec postgres psql -d ai_intake -c "ALTER SCHEMA public OWNER TO aiuser;"

  # Import data
  su-exec postgres psql ai_intake < /tmp/igar_clean_database.sql

  # Grant permissions to aiuser on all objects
  su-exec postgres psql -d ai_intake -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO aiuser;"
  su-exec postgres psql -d ai_intake -c "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO aiuser;"
  su-exec postgres psql -d ai_intake -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO aiuser;"
  su-exec postgres psql -d ai_intake -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO aiuser;"

  # Stop postgres
  su-exec postgres pg_ctl -D /var/lib/postgresql/data stop

  echo "Database initialized and seeded!"
fi

# Start postgres before running migrations (port 5432)
su-exec postgres pg_ctl -D /var/lib/postgresql/data -o "-p 5432" -w start

# Run migrations and catalog seeding
echo "Running migrations..."
npm run migrate || echo "Migrations completed or already applied"
echo "Seeding catalog..."
npm run seed-catalog || echo "Catalog already seeded"

# Stop postgres cleanly before handing off to supervisord
echo "Stopping postgres to hand off to supervisord..."
su-exec postgres pg_ctl -D /var/lib/postgresql/data stop -w

# Start supervisord
exec /usr/bin/supervisord -c /etc/supervisord.conf
