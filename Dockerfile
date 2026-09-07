FROM node:22-slim

WORKDIR /app

RUN corepack enable pnpm

COPY . .

RUN pnpm install --reporter=silent || true
RUN pnpm approve-builds --all
RUN pnpm install
RUN pnpm run build

CMD ["pnpm", "run", "start:prod"]
