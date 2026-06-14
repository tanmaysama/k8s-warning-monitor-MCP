# Use a lightweight Node image
FROM node:20-alpine

WORKDIR /app

# Copy package files and install dependencies
COPY package.json ./
RUN npm install

# Copy your source code
COPY src/ ./src/

# Run the MCP server using tsx
CMD ["npx", "tsx", "src/index.ts"]
