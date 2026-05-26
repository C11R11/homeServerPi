# Global Specification: Agentic Telemetry Protocol (v2.0)

## Overview
This specification defines a mandatory, "Metrics-First" and "Self-Reconciling" telemetry protocol for all agentic interactions. It ensures that every response, regardless of success or failure, records high-fidelity usage data that is independently verified against native system logs. 

**Note**: Telemetry is a development and deployment-time lifecycle concern. Configuration files (e.g., `.env.telemetry`) reside at the project root and are not part of the service runtime environments (`environments/`).

## Mandatory Components

### 1. Dual-Stream Telemetry Storage
All projects MUST maintain two distinct telemetry streams for reconciliation:
- **GitOps Stream (`.telemetry/gemini-gitops.json`)**: A versioned, manually-appended JSON array for auditing and PR reviews.
- **Native Stream (`.gemini/telemetry.json`)**: A machine-generated, high-fidelity trace file produced by the Gemini CLI engine.
- **Shadow Stream (`.gemini/telemetry-shadow.jsonl`)**: A redundant, JSON-Lines formatted fallback stream maintained by the agent wrapper to ensure continuity if the native engine stalls.

### 2. The Execution Wrapper (The Logger)
Every CLI command MUST be wrapped in a telemetry logger (e.g., `scripts/telemetry-logger.sh`).
- **Trace Continuity**: Must maintain a consistent `traceId` across `START`, `COMPLETE`, and `FAILURE` events for a single interaction.
- **Metric Extraction**: Must inject token metrics from environment variables (`GEN_AI_INPUT_TOKENS`, `GEN_AI_OUTPUT_TOKENS`) into the GitOps and Shadow Streams.
- **Stall Prevention**: To prevent the 100MB native log stall, the logger MUST initialize rotated native logs with a valid JSON object (`{}`).

### 3. Automated Auditing & Verification
Every implementation MUST provide a validation script (e.g., `scripts/audit-telemetry.sh`) that performs the following checks:
- **Integrity**: Validates the JSON structure of both streams.
- **Protocol Compliance**: Identifies "Dark Interactions" (native traces without corresponding GitOps entries).
- **Metric Accuracy**: Flags "Zero-Token Anomalies" where non-init operations report 0 tokens.
- **Orphanage**: Detects `START` events that never reached `COMPLETE` or `FAILURE` states.

### 4. Reconciliation Agent Requirement
All SDD systems MUST define a dedicated **Telemetry Auditor** agent role responsible for:
- **Passive Verification**: Regularly executing the auditing tools.
- **Reconciliation Reports**: Generating a discrepancy report if the GitOps stream diverges from the Native stream.
- **Contract Enforcement**: Blocking deployment or synthesis if the Telemetry Mandate is violated.

### 4. Log Retention & Compression
To ensure the telemetry storage does not exceed the 100MB system limit:
- **Scope**: This policy applies to both the GitOps Stream (`.telemetry/gemini-gitops.json`) and the Native Stream (`.gemini/telemetry.json`).
- **Rotation Threshold**: Any telemetry file MUST be rotated when it exceeds 50MB.
- **Compression**: Rotated logs MUST be compressed using `gzip` to minimize disk footprint.
- **Retention Policy**: Maintain up to 5 compressed archives (`.json.1.gz` to `.json.5.gz`) per stream.
- **Git Mandate**: The Native Stream (`.gemini/telemetry.json`) and its archives MUST NOT be tracked by git to prevent repository bloat.
- **Implementation**: The `telemetry-logger.sh` wrapper is responsible for triggering rotation checks for both streams.

## Agent Mandates
- **Absolute Telemetry Mandate**: No text-only responses. Every interaction MUST include a side-effect tool call to the telemetry logger.
- **Trace ID Reporting**: Every final response MUST cite the `traceId` generated for that specific interaction.
- **Audit-First Validation**: Agents MUST run the telemetry audit as part of any local validation or pre-flight check.

## Global Implementation Pattern
1. **Initialize Streams**: Configure `.gemini/settings.json` for native tracing and create `.telemetry/gemini-gitops.json`.
2. **Deploy Logger**: Install `scripts/telemetry-logger.sh`.
3. **Deploy Auditor**: Install `scripts/audit-telemetry.sh` and integrate into `scripts/validate-local.sh`.
4. **Agent Profile**: Update agent profiles (e.g., `.gemini/agents/sre-diagnostician.md`) to include the **Protocol Auditor** responsibility.
