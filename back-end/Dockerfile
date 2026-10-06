# Build stage: install production dependencies
FROM node:20-alpine AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev
COPY server.js ./

# Runtime stage: minimal image, non-root user
FROM node:20-alpine
WORKDIR /app
RUN addgroup -S app && adduser -S app -G app
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/package.json /app/server.js ./
USER app
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://127.0.0.1:3000/healthz || exit 1
CMD ["node", "server.js"]
