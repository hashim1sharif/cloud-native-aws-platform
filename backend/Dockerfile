# Install the backend dependencies
FROM node:22-alpine AS dependencies

WORKDIR /app

# Copy dependency files first to make better use of Docker layer caching
COPY package.json package-lock.json ./

# Install only production dependencies
RUN npm ci --omit=dev


# Create the production runtime image
FROM node:22-alpine AS runtime

WORKDIR /app

# Run Node.js in production mode
ENV NODE_ENV=production

# Copy installed dependencies from the previous stage
COPY --from=dependencies /app/node_modules ./node_modules

# Copy the backend source code
COPY src ./src

# Run the application as the non-root Node user
USER node

EXPOSE 5000

CMD ["node", "src/server.js"]