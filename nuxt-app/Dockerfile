# ---- Base Stage ----
    # Use a specific Node version for reproducibility
    FROM node:18-alpine AS base
    WORKDIR /app
    # Install dependencies first, leveraging Docker cache
    COPY package*.json ./
    RUN npm install
    
    # ---- Build Stage ----
    FROM base AS build
    WORKDIR /app
    COPY . .
    # Build the Nuxt application for production
    RUN npm run build
    
    # ---- Production Stage ----
    FROM node:18-alpine AS production
    WORKDIR /app
    
    # Copy built assets and necessary files from the build stage
    COPY --from=build /app/.output ./.output
    COPY --from=build /app/node_modules ./node_modules
    COPY --from=build /app/package.json ./package.json
    
    # Set environment variables for Nuxt server
    ENV HOST=0.0.0.0
    ENV PORT=3000
    
    # Expose the port the app runs on
    EXPOSE 3000
    
    # Command to run the Nuxt server
    CMD [ "node", ".output/server/index.mjs" ]