# Use Node.js 18 as base
FROM node:18-slim

# Install Python and yt-dlp requirements
RUN apt-get update && \
    apt-get install -y python3 python3-pip curl && \
    curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp && \
    chmod a+rx /usr/local/bin/yt-dlp && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install --production

# Copy the rest of the application
COPY . .

# Set environment variables
ENV PORT=8080
ENV NODE_ENV=production
ENV YTDLP_BIN=/usr/local/bin/yt-dlp

# Expose the port
EXPOSE 8080

# Start the application
CMD ["node", "src/index.js"]
