#!/bin/bash
set -e

echo "Running Prisma migrations..."
npx prisma migrate deploy

echo "Starting Lexi Backend..."
node dist/main.js
