FROM node:20-alpine

# Install PostgreSQL and supervisor (to run both postgres and node)
RUN apk add --no-cache postgresql postgresql-contrib supervisor su-exec

WORKDIR /app

# Cache bust to force rebuild with new package.json - 2025-11-17
# Copy package files
COPY package*.json ./

# Install all dependencies (including dev for build)
RUN npm install

# Copy source code
COPY . .

# Build TypeScript
RUN npm run build

# Create uploads directory
RUN mkdir -p /app/uploads

# Create postgres data directory
RUN mkdir -p /var/lib/postgresql/data && \
    chown -R postgres:postgres /var/lib/postgresql

# Copy database dump
COPY igar_clean_database.sql /tmp/igar_clean_database.sql

# Copy supervisor config and entrypoint script
COPY supervisord.conf /etc/supervisord.conf
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose port
EXPOSE 9501

# Set default DATABASE_URL for local postgres
ENV DATABASE_URL=postgresql://aiuser:aipassword@localhost:5432/ai_intake

ENTRYPOINT ["/entrypoint.sh"]
