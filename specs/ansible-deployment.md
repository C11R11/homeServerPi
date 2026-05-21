# Infrastructure Specification: Ansible Deployment

## Overview
This specification defines the declarative deployment process for the homeServerPi stack using Ansible. It ensures the target host is prepared and the Docker Compose blueprint is synchronized and executed.

## Target Configuration
- **Hosts**: all (defined in Ansible inventory)
- **Deployment Root**: /home/cristian/music-stack
- **Source Blueprint**: environments/prod/docker-compose.yml

## Deployment Workflow
1. **Directory Lifecycle**:
   - Ensure the directory /home/cristian/music-stack exists on the target host.
2. **Artifact Synchronization**:
   - Copy the local production Docker Compose file to the target host's deployment root.
   - The destination file MUST be named docker-compose.yml.
3. **Stack Reconciliation**:
   - Execute Docker Compose (V2) on the target host.
   - Action: present (Ensure the stack is running).
   - Policy: pull: always (Ensure the latest images as per the blueprint).

## Compliance & Constraints
- **Gather Facts**: no (Optimization for rapid deployment).
- **Module**: community.docker.docker_compose_v2.
- Adheres to the **Spec-Driven Development** model where the playbook acts as the execution engine for the production state defined in environments/prod/.
- Maintains the path structure required for **System Context** persistence on the Raspberry Pi.
