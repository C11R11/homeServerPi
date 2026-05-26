---
name: system-context
description: "Hardware parameters, storage maps, and baseline system constraints"
---

# SDD System Context: homeServerPi

## Hardware Baseline
- **Model**: Raspberry Pi 4 Model B (4GB RAM)
- **Primary Storage**: 480GB SSD over USB 3.0.
- **Mount Point**: `${MOUNT_USB_DRIVE}` (Environment Variable mandatory)

## Storage Strategy
All persistent storage MUST use environment variables for the root path.
- **Service Configurations**: `${MOUNT_USB_DRIVE}/config/<service>`
- **Service Data/Media**: `${MOUNT_USB_DRIVE}/data/<service>` (or specialized subfolders like `/Music`)

## Strict Architectural Constraints
1. **Memory Limits**: Every container MUST feature a memory limit. Default cap is 1.5GB unless specified in the service spec.
2. **Zero-Secrets Policy**: No hardcoded passwords, tokens, or private keys. Use `${VARIABLE}` exclusively.
3. **Deterministic Restarts**: All services must have `restart: unless-stopped`.
## Volume Mapping: Always map to the SSD via `${MOUNT_USB_DRIVE}` to prevent SD card wear and overflow.
5. **Token Metric Enforcement**: Every agent response MUST terminate with a tool call updating the local `.telemetry/gemini-gitops.json`. Failure to do so is a system state error.
6. **Execution Wrapper**: All CLI operations must be wrapped in `scripts/telemetry-logger.sh` to guarantee a log entry even in cases of process-level failure.

## Environments and State
- **Production (`environments/prod/`)**:
  - State: **Immutable**.
  - Sync: Automated via GitOps or `scripts/gitops-sync.sh`.
  - Goal: 1:1 match with `specs/`.
- **Development (`environments/dev/`)**:
  - State: **Mutable**.
  - Sync: Manual, human-driven.
  - Goal: Sandbox for testing `docker-compose.yml` logic and Ansible playbooks before promoting to `prod`.

