# Harness Specification: Staging Environment

## Overview
This specification defines the Staging Environment for the homeServerPi project. This environment is designed to be a high-fidelity replica of the production stack, running within a Docker container to validate infrastructure changes before deployment.

## Target Environment
- **Host Location**: `environments/staging/`
- **Runtime**: Ubuntu 24.04 Docker Container
- **Purpose**: Pre-production validation of the "Productive Stack".

## Infrastructure Components

### 1. Staging Sandbox Container
- **Image**: `jrei/systemd-ubuntu:24.04`
- **Privileged**: `true`
- **Restart Policy**: `no` (Ephemeral: manually started, never automatically restarted)
- **Resource Limits**: 2GB RAM
- **Volumes**:
  - `${MOUNT_USB_DRIVE}/staging/data` -> `/data`
  - `${MOUNT_USB_DRIVE}/staging/config` -> `/config`
  - `/var/run/docker.sock` -> `/var/run/docker.sock`
  - `${PWD}` -> `/repo:ro`

### 2. Networking (Virtual IP Strategy)
- **Network Driver**: `macvlan`
- **Access Model**: The sandbox MUST NOT use `localhost`. It requires a dedicated **Virtual IP** on the local network.
- **Mandatory Variables**:
  - `STAGING_IP`: The static IP assigned to the sandbox.
  - `STAGING_GATEWAY`: The local network gateway.
  - `STAGING_SUBNET`: The CIDR block of the local network.
- **Connectivity**: Outbound access required for `apt` and `docker pull` during provisioning.

### 3. Management Workflow: `/implement-staging`
This command, implemented in the DevOps Engineer agent, performs the following:
1. **Synthesis**: Generates a consolidated `docker-compose.yml` and `.env.example` mock for staging.
2. **Provisioning**: Executes an Ansible playbook to start the ephemeral sandbox with the MACVLAN config.
3. **Artifact Injection**: Copies production-ready artifacts into the container.
4. **Validation Run**: Executes a test deployment inside the sandbox using the `STAGING_IP`.

## Compliance & Constraints
- **SSD Simulation**: All persistent data MUST be scoped to `${MOUNT_USB_DRIVE}/staging`.
- **Variable-Driven**: Staging must use `environments/staging/.env`.
- **Zero-Secrets**: Use mock data for testing.
- **Traceability**: All operations must report telemetry.
