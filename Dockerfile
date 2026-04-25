# Hugging Face Docker Space — NestJS API (see README app_port)
# Official node image already includes user `node` (UID 1000); do not useradd (conflicts on HF builders).
FROM node:20-bookworm-slim AS builder

WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci

COPY . .
RUN npm run build

FROM node:20-bookworm-slim AS runner

WORKDIR /app

# Swagger (/api-docs) is off in production unless ENABLE_SWAGGER=true (set in Space Settings → Variables).
ENV NODE_ENV=production \
  PORT=7860

COPY --chown=node:node package.json package-lock.json ./
RUN npm ci --omit=dev && npm cache clean --force

COPY --chown=node:node --from=builder /app/dist ./dist

# WORKDIR /app is root-owned; npm ci ran as root. `node` must own /app to create FILE_STORAGE_PATH (e.g. ./uploads).
RUN mkdir -p /app/uploads/files && chown -R node:node /app

USER node
EXPOSE 7860

CMD ["node", "dist/main.js"]
