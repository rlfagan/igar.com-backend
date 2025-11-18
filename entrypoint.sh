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
  echo "Creating database and user..."
  su-exec postgres psql -c "CREATE DATABASE ai_intake;" 2>&1
  echo "Database created!"
  su-exec postgres psql -c "CREATE USER aiuser WITH PASSWORD 'aipassword';" 2>&1 || true
  echo "User created!"
  su-exec postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE ai_intake TO aiuser;" 2>&1
  su-exec postgres psql -d ai_intake -c "GRANT ALL ON SCHEMA public TO aiuser;" 2>&1
  su-exec postgres psql -d ai_intake -c "ALTER SCHEMA public OWNER TO aiuser;" 2>&1
  echo "Permissions granted!"

  # Import data
  echo "Importing database dump..."
  su-exec postgres psql ai_intake < /tmp/igar_clean_database.sql 2>&1
  echo "Database dump imported successfully!"

  # Grant permissions to aiuser on all objects
  su-exec postgres psql -d ai_intake -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO aiuser;"
  su-exec postgres psql -d ai_intake -c "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO aiuser;"
  su-exec postgres psql -d ai_intake -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO aiuser;"
  su-exec postgres psql -d ai_intake -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO aiuser;"

  # Stop postgres cleanly
  su-exec postgres pg_ctl -D /var/lib/postgresql/data stop -w

  echo "Database initialized and seeded!"
fi

# Database is already fully seeded from the SQL dump
# No need to run migrations or seeding scripts
echo "Database loaded from pre-seeded dump - ready to start!"

# Start supervisord
exec /usr/bin/supervisord -c /etc/supervisord.conf
