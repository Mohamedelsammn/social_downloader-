# Use Node.js 18 as base
FROM node:18-slim

# Install system dependencies (including python and pip)
RUN apt-get update && apt-get install -y \
    curl \
    ffmpeg \
    python3 \
    python3-pip \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Install latest yt-dlp via pip for better compatibility
# We use --break-system-packages because Railway uses Debian Bookworm
RUN pip3 install --no-cache-dir --break-system-packages yt-dlp

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
