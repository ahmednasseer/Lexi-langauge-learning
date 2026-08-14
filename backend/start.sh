#!/bin/bash
set -e

echo "Running Prisma migrations..."
export DIRECT_URL="${DIRECT_URL}?pgbouncer=true"
npx prisma migrate deploy

echo "Starting Lexi Backend..."
node dist/main.js
