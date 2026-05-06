FROM node:24.14.1-bookworm-slim

RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    ca-certificates \
    apt-transport-https \
    chromium \
    chromium-driver \
    xvfb \
    && rm -rf /var/lib/apt/lists/*

ENV CHROME_BIN=/usr/bin/chromium

WORKDIR /app

COPY .npmrc package*.json ./

RUN npm --version && node -e "const { execSync } = require('node:child_process'); const [major, minor] = execSync('npm --version', { encoding: 'utf8' }).trim().split('.').map(Number); const supported = Number.isFinite(major) && Number.isFinite(minor) && (major > 11 || (major === 11 && minor >= 10)); if (!supported) { throw new Error('npm >= 11.10.0 is required for min-release-age support'); }"
RUN test "$(npm config get min-release-age)" = "90"
RUN npm ci
COPY . .

# Command to run the application
CMD ["npm", "run","cjs_test"]