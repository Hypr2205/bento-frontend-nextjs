FROM node:22-alpine AS base
LABEL author="hypr2205 <procango2003@gmail.com>"
RUN corepack enable && corepack prepare pnpm@latest --activate

FROM base AS deps
LABEL author="hypr2205 <procango2003@gmail.com>"

RUN apk add --no-cache libc6-compat

WORKDIR /app
COPY package.json pnpm-lock.yaml ./

RUN pnpm install --frozen-lockfile 


FROM base AS builder
LABEL author="hypr2205 <procango2003@gmail.com>"

WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
ENV NEXT_TELEMETRY_DISABLED=1

RUN pnpm run build

FROM base AS runner
LABEL author="hypr2205 <procango2003@gmail.com>"

WORKDIR /app
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000

ENV PORT=3000

ENV HOSTNAME="0.0.0.0"
CMD ["node", "server.js"]
