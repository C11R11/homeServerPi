You#!/bin/bash
# GitOps Sync Script for homeServerPi
# Reconciles host state with the production specification in the repository.

set -e

REPO_ROOT=$(git rev-parse --show-toplevel)
PROD_DIR="$REPO_ROOT/environments/prod"
ANSIBLE_PLAYBOOK="$REPO_ROOT/scripts/deploy-ansible.yml"

echo "[$(date)] Starting GitOps Sync..."

# 1. Validation Step
echo "[$(date)] Phase 1: Validating production configuration..."
if [ ! -f "$PROD_DIR/.env" ]; then
    echo "[ERROR] Production .env file not found at $PROD_DIR/.env"
    echo "Please ensure the production environment is properly configured before syncing."
    exit 1
fi

# Run the local validation script (wrapped in telemetry)
cd "$PROD_DIR"
../../scripts/validate-local.sh

# 2. Deployment Step
echo "[$(date)] Phase 2: Reconciling host state via Ansible..."
# Note: We assume the target host is 'localhost' or defined in a default inventory.
# In a real Pi setup, this might point to the Pi's IP.
ansible-playbook -i localhost, -c local "$ANSIBLE_PLAYBOOK"

echo "[SUCCESS] GitOps Sync complete. Host is now aligned with specs."
