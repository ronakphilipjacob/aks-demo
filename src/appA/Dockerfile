# Use the official Node.js runtime as the base image
FROM node:18-alpine

# Accept build argument for Application Insights instrumentation key
ARG APPINSIGHTS_INSTRUMENTATION_KEY
ENV APPINSIGHTS_INSTRUMENTATION_KEY=${APPINSIGHTS_INSTRUMENTATION_KEY}

# Set the working directory in the container
WORKDIR /app

# Copy package.json
COPY package.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Create a non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001

# Change ownership of the app directory to the nodejs user
RUN chown -R nodejs:nodejs /app
USER nodejs

# Expose the port the app runs on
EXPOSE 3000

# Define the command to run the application
CMD ["npm", "start"]