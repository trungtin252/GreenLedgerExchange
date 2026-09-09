FROM node:22.12.0-alpine AS build
WORKDIR /workspace
COPY package.json pnpm-workspace.yaml pnpm-lock.yaml ./
COPY apps/web-portal/package.json apps/web-portal/package.json
COPY contracts/package.json contracts/package.json
RUN npx --yes --package=pnpm@10.28.2 pnpm install --frozen-lockfile
COPY apps/web-portal apps/web-portal
RUN npx --yes --package=pnpm@10.28.2 pnpm --filter @glx/web-portal build

FROM nginxinc/nginx-unprivileged:1.29.1-alpine
LABEL org.opencontainers.image.title="glx-web-portal"
COPY --from=build /workspace/apps/web-portal/dist /usr/share/nginx/html
USER 101
EXPOSE 8080
HEALTHCHECK --interval=10s --timeout=3s --retries=20 CMD wget -q -O /dev/null http://127.0.0.1:8080/
