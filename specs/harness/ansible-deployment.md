# Infrastructure Specification: Ansible Deployment

## Overview
This specification defines the declarative deployment process for the homeServerPi stack using Ansible. It ensures the target host is prepared and the Docker Compose blueprint is synchronized and executed.

## Target Configuration
- **Hosts**: all (defined in Ansible inventory)
- **Deployment Root**:
  - Defined via `${DEPLOY_PATH}` environment variable in the environment's `.env` file.
- **Source Blueprints**:
  - Production: `environments/prod/docker-compose.yml`
  - Development: `environments/dev/docker-compose.yml`
- **Environment Context**:
  - Each environment MUST have its own `.env` file (based on `.env.example`) in its respective directory.
  - The deployment process MUST synchronize the `.env` file to the target host.

## Deployment Workflow
1. **Ansible-First Strategy**:
   - All environment deployments (bringing the stack "up") MUST be performed via Ansible playbooks.
   - Manual `docker compose up` is discouraged to ensure consistency between local testing and remote deployment.
   - Local environments (e.g., `dev`) utilize a `run.sh` wrapper that invokes `ansible-playbook` against `localhost`.

2. **Directory Lifecycle**:
   - Ensure the relevant deployment root exists on the target host.
2. **Artifact Synchronization**:
   - Copy the chosen Docker Compose blueprint to the target host's deployment root as `docker-compose.yml`.
   - Copy the environment-specific `.env` file to the target host's deployment root.
3. **Stack Reconciliation**:
   - Execute Docker Compose (V2) on the target host using the synchronized `.env` file.
   - Action: present (Ensure the stack is running).
   - Policy: pull: always (Ensure the latest images as per the blueprint).

## Compliance & Constraints
- **Gather Facts**: no (Optimization for rapid deployment).
- **Module**: community.docker.docker_compose_v2.
- Adheres to the **Spec-Driven Development** model for `prod` and allows human experimentation in `dev`.
- Maintains the path structure required for **System Context** persistence on the Raspberry Pi.
