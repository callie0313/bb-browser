FROM node:22-bookworm-slim

# Chrome runtime dependencies (full Chrome for Testing needs these)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl unzip fonts-noto-cjk fonts-noto-color-emoji \
    libnss3 libxss1 libasound2 libatk-bridge2.0-0 libgtk-3-0 libdrm2 \
    libgbm1 libx11-xcb1 libxcomposite1 libxdamage1 libxrandr2 \
    libpango-1.0-0 libcairo2 libcups2 libdbus-1-3 libexpat1 \
    libxext6 libxfixes3 libxkbcommon0 libatspi2.0-0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy bb-viewer binary (statically linked libvpx + libturbojpeg)
COPY bin/bb-viewer-linux-amd64 /usr/local/bin/bb-viewer
RUN chmod +x /usr/local/bin/bb-viewer

# Copy built daemon and install runtime deps
COPY dist/ ./dist/
COPY web/ ./web/
COPY package.json ./
RUN npm install --omit=dev --ignore-scripts 2>/dev/null || true

# Daemon auto-downloads Chrome for Testing (full browser) on first start.
# Profile persists in /data/chrome-data across restarts.

ENV NODE_ENV=production
ENV BB_BROWSER_HOME=/data

EXPOSE 19824

ENTRYPOINT ["node", "dist/daemon.js"]
