# Build the React application
FROM node:22-alpine AS build

WORKDIR /app

# Copy dependency files first to make better use of Docker layer caching
COPY --chown=node:node package.json package-lock.json ./

# Build the application as a non-root user
USER node

RUN npm ci

# Copy the application source code
COPY --chown=node:node . .

RUN npm run build


# Serve the production build with unprivileged Nginx
FROM nginxinc/nginx-unprivileged:alpine AS runtime

# Copy only the built frontend files into the runtime image
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]