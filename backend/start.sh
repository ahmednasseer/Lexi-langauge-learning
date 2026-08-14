#!/bin/bash
set -e

echo "Running Prisma migrations..."
export DIRECT_URL="${DIRECT_URL}?pgbouncer=true"
npx prisma migrate deploy

echo "Seeding curriculum data..."
npm run seed

echo "Starting Lexi Backend..."
node dist/main.js
