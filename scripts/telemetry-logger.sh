#!/bin/bash
# Metrics-Focused Telemetry Logger for homeServerPi SDD (JSON Array Format)

set -e

LOG_FILE="$(git rev-parse --show-toplevel)/.telemetry/gemini-gitops.json"
TRACE_ID=$(cat /proc/sys/kernel/random/uuid 2>/dev/null || echo "manual-$(date +%s)")

log_metrics() {
    local operation=$1
    local input_tokens=${2:-0}
    local reasoning_tokens=${3:-0}
    local output_tokens=${4:-0}
    local prompt_file=${5:-null}
    local manual_prompt=${6:-null}
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    mkdir -p "$(dirname "$LOG_FILE")"
    
    # Initialize file as an empty array if it doesn't exist
    if [ ! -f "$LOG_FILE" ] || [ ! -s "$LOG_FILE" ]; then
        echo "[]" > "$LOG_FILE"
    fi

    # Handle null values for prompt_file and manual_prompt
    local p_file_json="null"
    if [ "$prompt_file" != "null" ]; then
        p_file_json="\"$prompt_file\""
    fi

    local m_prompt_json="null"
    if [ "$manual_prompt" != "null" ]; then
        # Escape quotes for JSON
        local escaped_prompt=$(echo "$manual_prompt" | sed 's/"/\\"/g')
        m_prompt_json="\"$escaped_prompt\""
    fi

    # Create the new JSON object
    local new_entry=$(printf '{"timestamp":"%s", "traceId":"%s", "gen_ai.operation.name":"%s", "gen_ai.request.prompt_file":%s, "gen_ai.request.manual_prompt":%s, "gen_ai.usage.input_tokens":%d, "gen_ai.usage.reasoning_tokens":%d, "gen_ai.usage.output_tokens":%d}' \
        "$timestamp" "$TRACE_ID" "$operation" "$p_file_json" "$m_prompt_json" "$input_tokens" "$reasoning_tokens" "$output_tokens")

    # Append to the JSON array
    if [ "$(cat "$LOG_FILE")" == "[]" ]; then
        printf '[\n%s\n]\n' "$new_entry" > "$LOG_FILE"
    else
        sed -i '$d' "$LOG_FILE"
        sed -i '$s/$/,/' "$LOG_FILE"
        printf '%s\n]\n' "$new_entry" >> "$LOG_FILE"
    fi

    rotate_log "$LOG_FILE"
    
    # Also rotate native telemetry if it exists
    NATIVE_LOG="$(git rev-parse --show-toplevel)/.gemini/telemetry.json"
    if [ -f "$NATIVE_LOG" ]; then
        rotate_log "$NATIVE_LOG"
    fi
}

rotate_log() {
    local target_file=$1
    local max_size=52428800 # 50MB
    local current_size=$(stat -c%s "$target_file" 2>/dev/null || echo 0)

    if [ "$current_size" -gt "$max_size" ]; then
        echo "[INFO] Rotating $target_file (Size: $((current_size / 1024 / 1024))MB)..."
        # Shift existing archives (keep up to 5)
        for i in {4..1}; do
            if [ -f "$target_file.$i.gz" ]; then
                mv "$target_file.$i.gz" "$target_file.$((i+1)).gz"
            fi
        done
        
        # Compress current log and reset
        gzip -c "$target_file" > "$target_file.1.gz"
        
        # For GitOps log, reset to empty array. For others, just clear.
        if [[ "$target_file" == *"gemini-gitops.json" ]]; then
            echo "[]" > "$target_file"
        else
            cat /dev/null > "$target_file"
        fi
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
