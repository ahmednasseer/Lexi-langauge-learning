#!/bin/bash
set -e

echo "Pushing Prisma schema to database..."
npx prisma db push --accept-data-loss

echo "Starting Lexi Backend..."
node dist/main.js
