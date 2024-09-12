# Use the official Node.js 18 image as the base image
FROM node:18-alpine AS base

# Set the working directory
WORKDIR /app

# Copy package manager files
COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* ./

# Install pnpm
RUN npm install -g pnpm

# Install dependencies
RUN if [ -f yarn.lock ]; then yarn --frozen-lockfile; \
    elif [ -f package-lock.json ]; then npm ci; \
    elif [ -f pnpm-lock.yaml ]; then pnpm install --frozen-lockfile; \
    else echo "Lockfile not found." && exit 1; \
    fi

# Copy the rest of the application code
COPY . .

# Build the application
RUN yarn build

# Use a smaller base image for the final build
FROM node:18-alpine AS final

# Set the working directory
WORKDIR /app

# Copy the built application from the previous stage
COPY --from=base /app .

# Ensure pnpm is available in the final stage
RUN npm install -g pnpm

# Expose the port the app runs on
EXPOSE 3000

# Start the application
CMD ["yarn", "start"]