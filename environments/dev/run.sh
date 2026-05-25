#!/bin/bash
# Local execution script for Development environment
# Usage: ./run.sh [setup|up|down|restart|logs]

COMMAND=${1:-up}
ENV_FILE=".env"

if [ ! -f "$ENV_FILE" ]; then
    echo "[WARN] $ENV_FILE not found, using .env.example..."
    ENV_FILE=".env.example"
fi

# Load variables from the selected env file for Ansible
export $(grep -v '^#' "$ENV_FILE" | xargs)

if [ "$COMMAND" == "setup" ]; then
    echo "[$(date)] Provisioning Bare-Metal Layer 0 via Ansible using $ENV_FILE..."
    ansible-playbook -i localhost, setup.yml
elif [ "$COMMAND" == "up" ]; then
    echo "[$(date)] Deploying Development environment via Ansible using $ENV_FILE..."
    ansible-playbook -i localhost, deploy.yml
else
    echo "[$(date)] Executing '$COMMAND' on Development environment via Docker Compose..."
    docker compose --env-file "$ENV_FILE" "$COMMAND"
fi
