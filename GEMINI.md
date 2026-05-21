# homeServerPi Instructions

This project manages a media-focused home server stack for a Raspberry Pi using Docker Compose and automated deployment via Ansible and GitHub Actions.

## Project Overview

The stack consists of two primary services:
- **Navidrome**: A music streaming server.
- **Yubal**: A specialized downloader service.

### Technologies
- **Docker Compose**: Orchestrates the services.
- **Ansible**: Manages the deployment of the Compose file to the target server.
- **GitHub Actions**: Provides a CI/CD pipeline for automated updates on every push to the `main` branch.
- **Tmux/Bash**: Local scripts for managing development sessions.

## Infrastructure Details

### Storage Strategy
The services are configured to use an external USB drive for mass storage:
- **Mount Point**: `/media/usb-media`
- **Music Library**: `/media/usb-media/Music`
- **Service Data**: `/media/usb-media/Music/navidrome/data`

### Permissions
Services are generally configured to run as the user `cristian` (UID/GID 1000) to ensure consistent file ownership on the shared storage.

## Building and Running

### Local Management
To start the stack manually on the target machine:
```bash
docker compose up -d
```

To view logs for a specific service:
```bash
docker compose logs -f navidrome
```

### Automated Deployment
Deployment is handled automatically via GitHub Actions:
1.  **Trigger**: Push to the `main` branch.
2.  **Process**:
    - Checkout code.
    - Setup Ansible.
    - Run the `deploy-ansible.md` playbook using secrets (`SSH_PRIVATE_KEY`, `SERVER_IP`).

### Development Environment
A helper script `start-terminal-tmux.sh` is provided to quickly launch a development session with pre-configured SSH connections to the server in a tmux layout.

## Key Files
- `docker-compose.yml`: The primary service definitions and volume mappings.
- `deploy-ansible.md`: The Ansible playbook (in Markdown format) used for remote deployment.
- `.github/workflows/deploy.yml`: The CI/CD pipeline configuration.
- `start-terminal-tmux.sh`: Local development automation script.

## Development Conventions
- **Secrets**: Sensitive information (IPs, Keys) is managed via GitHub Secrets. Never commit these to the repository.
- **Consistency**: Ensure volume paths in `docker-compose.yml` match the physical layout of the Raspberry Pi's external storage.
