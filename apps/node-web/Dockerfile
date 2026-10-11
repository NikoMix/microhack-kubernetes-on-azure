# build
FROM node:25-trixie-slim AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY tsconfig.json ./
COPY src ./src
RUN npm run build && npm prune --omit=dev

# runtime — distroless Node 24, non-root (uid 65532)
FROM gcr.io/distroless/nodejs24-debian13:nonroot
WORKDIR /app
ENV NODE_ENV=production PORT=8080 OTEL_SERVICE_NAME=node-web
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
COPY package.json ./
EXPOSE 8080
# The distroless nodejs image sets ENTRYPOINT ["node"], so the array below is
# passed as arguments to node (i.e. `node dist/healthcheck.js`).
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 CMD ["dist/healthcheck.js"]
CMD ["dist/server.js"]
