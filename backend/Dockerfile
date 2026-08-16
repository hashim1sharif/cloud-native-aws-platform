# Install application dependencies
FROM node:22-alpine AS dependencies

# Set the working directory
WORKDIR /app

# Copy dependency files
COPY package.json package-lock.json ./

# Install dependencies
RUN npm ci


# Create the runtime image
FROM node:22-alpine AS runtime

# Set the working directory
WORKDIR /app

# Set Node.js to production mode
ENV NODE_ENV=production

# Copy installed dependencies from the dependencies stage
COPY --from=dependencies /app/node_modules ./node_modules

# Copy package files
COPY package.json package-lock.json ./

# Copy application source code
COPY src ./src

# Run the application as the non-root Node user
USER node

# Expose the backend port
EXPOSE 5000

# Start the backend application
CMD ["node", "src/server.js"]