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

RUN npm --version && node -e "const major = Number(process.versions.npm.split('.')[0]); if (major < 11) { throw new Error('npm >= 11 is required for min-release-age support'); }"
RUN test "$(npm config get min-release-age)" = "90"
RUN npm ci
COPY . .

# Command to run the application
CMD ["npm", "run","cjs_test"]