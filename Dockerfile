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
RUN node -e "const fs = require('node:fs'); const content = fs.readFileSync('.npmrc', 'utf8'); if (!/^min-release-age=90\\s*$/m.test(content)) { throw new Error('.npmrc must contain min-release-age=90'); }"
RUN node -e "const { execSync } = require('node:child_process'); const before = execSync('npm config get before', { encoding: 'utf8' }).trim(); if (!before || before === 'null') { throw new Error('npm min-release-age policy is not active (before is null)'); }"
RUN npm ci
COPY . .

# Command to run the application
CMD ["npm", "run","cjs_test"]