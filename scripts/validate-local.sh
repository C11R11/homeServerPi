#!/bin/bash
# Local Validation Script for homeServerPi SDD

set -e

# Use .env.local if it exists, otherwise use .env.example for a dry-run check
ENV_FILE=".env"
if [ ! -f "$ENV_FILE" ]; then
    echo "[INFO] .env not found, using .env.example for validation..."
    ENV_FILE=".env.example"
fi

echo "[$(date)] Validating Docker Compose configuration using $ENV_FILE..."

# Load env variables and run docker compose config
docker compose --env-file "$ENV_FILE" -f environments/prod/docker-compose.yml config

echo "[$(date)] Auditing Telemetry compliance..."
./scripts/audit-telemetry.sh

echo "[SUCCESS] Configuration is valid and SDD-compliant."
