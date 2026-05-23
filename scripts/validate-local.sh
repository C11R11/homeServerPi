#!/bin/bash
# Local Validation Script for homeServerPi SDD

set -e

# Use .env.local if it exists, otherwise use .env.example for a dry-run check
ENV_FILE=".env"
if [ ! -f "$ENV_FILE" ]; then
    echo "[INFO] .env not found, using .env.example for validation..."
    ENV_FILE=".env.example"
fi

# Detect environment context
if [ -f "docker-compose.yml" ]; then
    COMPOSE_FILE="docker-compose.yml"
else
    COMPOSE_FILE="environments/prod/docker-compose.yml"
fi

echo "[$(date)] Validating Docker Compose configuration ($COMPOSE_FILE) using $ENV_FILE..."

# Load env variables and run docker compose config
docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" config

echo "[$(date)] Auditing Telemetry compliance..."
# Run from root to ensure absolute path works for auditor if needed, 
# or use relative path if auditor is smart
ROOT_DIR=$(git rev-parse --show-toplevel)
"$ROOT_DIR/scripts/audit-telemetry.sh"

echo "[SUCCESS] Configuration is valid and SDD-compliant."
