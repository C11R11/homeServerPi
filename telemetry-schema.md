# Telemetry Schema: Metrics-Focused (JSON Array)

This schema defines the mandatory metric fields for all agent interactions. All entries are stored in a valid JSON array within `.telemetry/gemini-gitops.json`.

## Mandatory Metric Fields
- `gen_ai.usage.input_tokens`: Count of tokens sent in the prompt.
- `gen_ai.usage.reasoning_tokens`: Count of tokens used for model reasoning. **Note**: This value is 0 for Gemini 1.5 Pro as it does not expose a separate reasoning chain; it is reserved for future reasoning-capable models (e.g., Gemini 2.0 Thinking).
- `gen_ai.usage.output_tokens`: Count of tokens generated in the response.

## Mandatory Auditing Fields
- `gen_ai.request.prompt_file`: Path to the markdown prompt file (if used).
- `gen_ai.request.manual_prompt`: The content of the manual prompt (if no file was used).

## Versioned JSON Array Format
```json
[
  {
    "timestamp": "2026-05-20T23:59:00Z",
    "traceId": "uuid-v4",
    "gen_ai.operation.name": "synthesis|diagnostics|manual",
    "gen_ai.request.prompt_file": "prompts/01. Foundations.md",
    "gen_ai.request.manual_prompt": null,
    "gen_ai.usage.input_tokens": 1200,
    "gen_ai.usage.reasoning_tokens": 400,
    "gen_ai.usage.output_tokens": 800,
    "attributes": {
      "project": "homeServerPi",
      "model": "gemini-1.5-pro"
    }
  }
]
```
