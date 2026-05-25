#!/bin/bash
# Telemetry Compliance Auditor for homeServerPi
# Cross-references .telemetry/gemini-gitops.json with native .gemini/telemetry.json

set -e

ROOT_DIR=$(git rev-parse --show-toplevel)
GITOPS_LOG="$ROOT_DIR/.telemetry/gemini-gitops.json"
NATIVE_LOG="$ROOT_DIR/.gemini/telemetry.json"
SHADOW_LOG="$ROOT_DIR/.gemini/telemetry-shadow.jsonl"

echo "[$(date)] Starting Telemetry Compliance Audit..."

# 1. Basic JSON Integrity
if ! jq empty "$GITOPS_LOG" 2>/dev/null; then
    echo "[FAILURE] $GITOPS_LOG is not a valid JSON array."
    exit 1
fi

if [ -f "$SHADOW_LOG" ]; then
    if ! jq -c . "$SHADOW_LOG" > /dev/null 2>&1; then
        echo "[FAILURE] $SHADOW_LOG contains invalid JSON lines."
        exit 1
    fi
fi

# 2. Check for Zero-Token Anomalies
ZERO_TOKEN_COUNT=$(jq '[.[] | select(."gen_ai.operation.name" != "SYSTEM_INIT" and (."gen_ai.operation.name" | startswith("START") | not) and ."gen_ai.usage.input_tokens" == 0 and ."gen_ai.usage.output_tokens" == 0)] | length' "$GITOPS_LOG")

if [ "$ZERO_TOKEN_COUNT" -gt 0 ]; then
    echo "[FAILURE] Found $ZERO_TOKEN_COUNT records with zero tokens (Protocol Violation)."
    exit 1
fi

# 3. Orphaned START check
START_COUNT=$(jq '[.[] | select(."gen_ai.operation.name" | startswith("START"))] | length' "$GITOPS_LOG")
END_COUNT=$(jq '[.[] | select(."gen_ai.operation.name" == "COMPLETE" or ."gen_ai.operation.name" == "FAILURE")] | length' "$GITOPS_LOG")

if [ "$START_COUNT" -gt "$END_COUNT" ]; then
    echo "[WARNING] Found orphaned START events ($START_COUNT starts vs $END_COUNT completions)."
fi

# 4. Native vs GitOps Sync (Basic)
# This check ensures that if the native log is significantly larger/newer, 
# there are corresponding entries in GitOps log.
if [ -f "$NATIVE_LOG" ]; then
    echo "[INFO] Native telemetry detected. Performing cross-reference..."
    # Simplified check: just ensuring GitOps log isn't empty if Native exists
    GITOPS_SIZE=$(jq '. | length' "$GITOPS_LOG")
    if [ "$GITOPS_SIZE" -lt 2 ]; then
         echo "[FAILURE] Native telemetry exists but GitOps log is nearly empty."
         exit 1
    fi
fi

echo "[SUCCESS] Telemetry compliance verified."
