# GEMINI.md: SDD & GitOps Code of Conduct

This repository operates under a **Spec-Driven Development (SDD)** and **GitOps** philosophy. All changes to the production environment MUST originate from a specification change.

## 1. The Core Directives
- **Specs are the Source of Truth**: The files in `specs/` define the desired state. No manual edits to `environments/prod/docker-compose.yml` are permitted.
- **Agentic Separation of Concerns**:
    - **DevOps Engineer** (`agents/devops-engineer.md`): Responsible for *Synthesis*. It transforms specs into code and refactors legacy configurations to comply with SDD standards.
    - **SRE Diagnostician** (`agents/sre-diagnostician.md`): Responsible for *Analysis*. It identifies failures against specs by analyzing logs and system state in a passive, read-only mode.
- **Metrics-First Telemetry**: Every agent interaction MUST record token consumption metrics and auditing metadata.
    - **Protocol**: Adhere to `specs/telemetry-protocol.md`.
    - **CLI Configuration**: Project-level telemetry is enabled via `.gemini/settings.json`.
    - **Extraction**: Every `COMPLETE`/`FAILURE` event MUST use the `scripts/telemetry-logger.sh` wrapper with environment variables (`GEN_AI_INPUT_TOKENS`, `GEN_AI_OUTPUT_TOKENS`) to prevent zero-token anomalies.
    - **Fields**: Every entry in `.telemetry/gemini-gitops.json` must include Prompt, Reasoning (if applicable), and Output tokens, plus auditing metadata (Prompt File Path or Manual Prompt content).
- **Absolute Telemetry Mandate**: Every single agent response MUST include a tool call (e.g., `write_file` or `run_shell_command`) that appends the interaction's metrics to `.telemetry/gemini-gitops.json`. A text-only response is a critical protocol violation.
- **Resilience**: This mandate applies even if the task is cancelled, fails, or hits a quota. The `scripts/telemetry-logger.sh` wrapper MUST be used for all CLI invocations to ensure a "FAILURE" record is created even if the agent cannot respond.

## 2. Operational Workflow
1.  **Propose**: Update or create a Markdown file in `specs/` defining the service or infra change.
2.  **Synthesize**: The **DevOps Engineer** agent reads the spec and updates the `environments/prod/docker-compose.yml`.
3.  **Validate Locally**: Execute `scripts/validate-local.sh` to verify the generated configuration against a local `.env` or `.env.example`.
4.  **Validate SDD Compliance**: Run compliance checks (see `agents/agentic-skills.md`).
5.  **Sync**: Execute `scripts/gitops-sync.sh` to reconcile the host state with the repository.
6.  **Observe**: If a failure occurs, the **SRE Diagnostician** provides an RCA report.

## 3. Implementation Constraints
All implementations MUST adhere to the rules in `agents/system-context.md`:
- **SSD First**: All persistent data and configs MUST reside on the USB SSD (`$MOUNT_USB_DRIVE`).
- **No Hardcoded Secrets**: Use `${VARIABLE}` syntax and define values in `.env` (ignored by git).
- **Resource Guarding**: Every container must have memory limits (default max 1.5GB) to protect the Raspberry Pi's RAM.
- **Persistence**: Use `restart: unless-stopped` for all services.

## 4. Agent Interaction Policy
Agents must provide high-signal output. When performing a task:
- State which **Spec** is being addressed.
- Confirm adherence to **System Context** rules.
- **Mandatory Reporting**: Every response MUST conclude with the **Telemetry Trace ID** generated for that interaction. Failure to report the Trace ID is a protocol violation.

---
*This file is the foundational constraint layer for Gemini agents. Deviations from these protocols are considered system failures.*
