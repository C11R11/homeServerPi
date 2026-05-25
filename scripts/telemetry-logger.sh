#!/bin/bash
# Metrics-Focused Telemetry Logger for homeServerPi SDD (Dual-Stream + Shadow Fallback)

set -e

REPO_ROOT=$(git rev-parse --show-toplevel)
GITOPS_LOG="$REPO_ROOT/.telemetry/gemini-gitops.json"
NATIVE_LOG="$REPO_ROOT/.gemini/telemetry.json"
SHADOW_LOG="$REPO_ROOT/.gemini/telemetry-shadow.jsonl"
TRACE_ID=$(cat /proc/sys/kernel/random/uuid 2>/dev/null || echo "manual-$(date +%s)")

log_metrics() {
    local operation=$1
    local input_tokens=${2:-0}
    local reasoning_tokens=${3:-0}
    local output_tokens=${4:-0}
    local prompt_file=${5:-null}
    local manual_prompt=${6:-null}
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    mkdir -p "$(dirname "$GITOPS_LOG")"
    mkdir -p "$(dirname "$SHADOW_LOG")"
    
    # --- 1. GitOps Stream Update (JSON Array) ---
    if [ ! -f "$GITOPS_LOG" ] || [ ! -s "$GITOPS_LOG" ]; then
        echo "[]" > "$GITOPS_LOG"
    fi

    local p_file_json="null"
    if [ "$prompt_file" != "null" ]; then p_file_json="\"$prompt_file\""; fi

    local m_prompt_json="null"
    if [ "$manual_prompt" != "null" ]; then
        local escaped_prompt=$(echo "$manual_prompt" | sed 's/"/\\"/g')
        m_prompt_json="\"$escaped_prompt\""
    fi

    local new_entry=$(printf '{"timestamp":"%s", "traceId":"%s", "gen_ai.operation.name":"%s", "gen_ai.request.prompt_file":%s, "gen_ai.request.manual_prompt":%s, "gen_ai.usage.input_tokens":%d, "gen_ai.usage.reasoning_tokens":%d, "gen_ai.usage.output_tokens":%d}' \
        "$timestamp" "$TRACE_ID" "$operation" "$p_file_json" "$m_prompt_json" "$input_tokens" "$reasoning_tokens" "$output_tokens")

    if [ "$(cat "$GITOPS_LOG")" == "[]" ]; then
        printf '[\n%s\n]\n' "$new_entry" > "$GITOPS_LOG"
    else
        sed -i '$d' "$GITOPS_LOG"
        sed -i '$s/$/,/' "$GITOPS_LOG"
        printf '%s\n]\n' "$new_entry" >> "$GITOPS_LOG"
    fi

    # --- 2. Shadow Stream Update (JSON Lines fallback) ---
    echo "$new_entry" >> "$SHADOW_LOG"

    # --- 3. Rotation Management ---
    rotate_log "$GITOPS_LOG" "[]"
    rotate_log "$NATIVE_LOG" "{}"
    rotate_log "$SHADOW_LOG" ""
}

rotate_log() {
    local target_file=$1
    local init_content=$2
    local max_size=52428800 # 50MB
    
    if [ ! -f "$target_file" ]; then return; fi
    
    local current_size=$(stat -c%s "$target_file" 2>/dev/null || echo 0)

    if [ "$current_size" -gt "$max_size" ]; then
        # Shift existing archives
        for i in {4..1}; do
            if [ -f "$target_file.$i.gz" ]; then
                mv "$target_file.$i.gz" "$target_file.$((i+1)).gz"
            fi
        done
        
        # Compress current log
        gzip -c "$target_file" > "$target_file.1.gz"
        
        # Reset file with initial content to keep JSON valid or engine happy
        echo "$init_content" > "$target_file"
    fi
}

# Initial START event
log_metrics "START: $*" 0 0 0 "null" "null"

# Execute the wrapped command
"$@"
EXIT_CODE=$?

# End event
if [ $EXIT_CODE -eq 0 ]; then
    log_metrics "COMPLETE" "${GEN_AI_INPUT_TOKENS:-0}" "${GEN_AI_REASONING_TOKENS:-0}" "${GEN_AI_OUTPUT_TOKENS:-0}" "${GEN_AI_PROMPT_FILE:-null}" "${GEN_AI_MANUAL_PROMPT:-null}"
else
    log_metrics "FAILURE" "${GEN_AI_INPUT_TOKENS:-0}" "${GEN_AI_REASONING_TOKENS:-0}" "${GEN_AI_OUTPUT_TOKENS:-0}" "${GEN_AI_PROMPT_FILE:-null}" "${GEN_AI_MANUAL_PROMPT:-null}"
fi

exit $EXIT_CODE
