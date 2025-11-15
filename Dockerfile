FROM node:20-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install all dependencies (including dev for build)
RUN npm install

# Copy source code
COPY . .

# Build TypeScript
RUN npm run build

# Don't remove tsx as it's needed for migrations
# RUN npm prune --omit=dev

# Create uploads directory
RUN mkdir -p /app/uploads

# Expose port
EXPOSE 9501

# Run migrations and start
CMD ["sh", "-c", "npm run migrate && npm start"]
