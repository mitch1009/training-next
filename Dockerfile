##### DEPENDENCIES

FROM --platform=linux/amd64 node:20-alpine AS deps
RUN apk add --no-cache libc6-compat openssl git curl 
WORKDIR /app
RUN apk add --no-cache \
    libc6-compat \
    openssl \
    openssl-dev \
    git \
    curl
ENV NEXT_TELEMETRY_DISABLED=true
COPY prisma ./

COPY package.json pnpm-lock.yaml\* ./
RUN corepack enable
RUN corepack prepare yarn@stable --activate
RUN corepack prepare pnpm@9.1.4 --activate

COPY package.json pnpm-lock.yaml* ./
RUN pnpm i --no-frozen-lockfile

##### BUILDER

FROM --platform=linux/amd64 node:20-alpine AS builder
ARG DATABASE_URL
ARG NEXT_PUBLIC_CLIENTVAR
ARG AUTH_SECRET
ARG NEXT_PUBLIC_URL
ARG AUTH_URL
ARG AUTH_GITHUB_ID
ARG AUTH_GITHUB_SECRET
ARG AUTH_GOOGLE_ID
ARG AUTH_GOOGLE_SECRET
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .



COPY package.json pnpm-lock.yaml\* ./
RUN corepack enable
RUN corepack prepare yarn@stable --activate
RUN corepack prepare pnpm@9.1.4 --activate

# Generate Prisma Client here
RUN npx prisma generate
RUN SKIP_ENV_VALIDATION=1 pnpm run build

##### RUNNER

FROM --platform=linux/amd64 node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production

# Install only production dependencies
COPY package.json pnpm-lock.yaml* ./
RUN corepack enable && corepack prepare pnpm@9.1.4 --activate
RUN pnpm i --prod --frozen-lockfile
RUN apk add --no-cache \
    openssl \
    openssl-dev
# Copy only necessary Prisma files
COPY --from=builder /app/node_modules/@prisma ./node_modules/@prisma
COPY --from=builder /app/prisma ./prisma

COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./package.json

COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static

ENV PORT=3000
ENV AUTH_TRUST_HOST=1

EXPOSE 3000

# Create and use startup script
COPY start.sh ./
RUN chmod +x /app/start.sh

CMD ["./start.sh"]