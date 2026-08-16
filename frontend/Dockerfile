# Build the frontend application
FROM node:22-alpine AS build

# Set the working directory
WORKDIR /app

# Copy dependency files
COPY package.json package-lock.json ./

# Install dependencies
RUN npm ci

# Copy the frontend source code
COPY . .

# Configure the API URL used during the build
ARG VITE_API_URL=""
ENV VITE_API_URL=${VITE_API_URL}

# Build the production-ready frontend
RUN npm run build


# Use unprivileged Nginx to serve the frontend
FROM nginxinc/nginx-unprivileged:alpine AS runtime

# Copy the built application into the Nginx web directory
COPY --from=build /app/dist /usr/share/nginx/html

# Expose the Nginx application port
EXPOSE 8080

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]