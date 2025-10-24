# Use Node.js LTS version
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install --production

# Copy server files
COPY server.js ./

# Expose port
EXPOSE 3001

# Set environment variable
ENV PORT=3001

# Start the server
CMD ["node", "server.js"]
