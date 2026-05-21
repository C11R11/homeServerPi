# GEMINI.md: SDD & GitOps Code of Conduct

This repository operates under a **Spec-Driven Development (SDD)** and **GitOps** philosophy. All changes to the production environment MUST originate from a specification change.

## 1. The Core Directives
- **Specs are the Source of Truth**: The files in `specs/` define the desired state. No manual edits to `environments/prod/docker-compose.yml` are permitted.
- **Agentic Separation of Concerns**:
    - **DevOps Engineer**: Responsible for *Synthesis*. It transforms specs into code.
    - **SRE Diagnostician**: Responsible for *Analysis*. It identifies failures against specs but never modifies code.
- **Metrics-First Telemetry**: Every agent interaction MUST record token consumption metrics and auditing metadata. Every entry in `.telemetry/` must include:
    - **Prompt Tokens** (Input)
    - **Reasoning Tokens** (Internal computation)
    - **Output Tokens** (Generated response)
    - **Prompt File Path** (if applicable)
    - **Manual Prompt Content** (if applicable)
- **No Metrics, No Deployment**: Synthesis or SRE tasks are considered incomplete and "unverified" if they fail to record these metrics in the versioned `.telemetry/` directory.

## 2. Operational Workflow
1.  **Propose**: Update or create a Markdown file in `specs/` defining the service or infra change.
2.  **Synthesize**: The **DevOps Engineer** agent reads the spec and updates the `environments/prod/docker-compose.yml`.
3.  **Validate**: Run syntax and compliance checks (see `.gemini/agentic-skills.md`).
4.  **Sync**: Execute `scripts/gitops-sync.sh` to reconcile the host state with the repository.
5.  **Observe**: If a failure occurs, the **SRE Diagnostician** provides an RCA report.

## 3. Implementation Constraints
All implementations MUST adhere to the rules in `.gemini/system-context.md`:
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
