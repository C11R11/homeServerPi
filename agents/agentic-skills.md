# Agentic Skills: homeServerPi

### 1. `validate_compose_syntax`
- **Command**: `docker compose -f environments/prod/docker-compose.yml config`
- **Goal**: Verifies the synthesized configuration is valid.

### 2. `fetch_container_logs`
- **Command**: `docker logs --tail 100 <service_name>`
- **Goal**: Provides the SRE Diagnostician with targeted troubleshooting data.

### 3. `check_env_compliance`
- **Command**: Custom parsing of `.env` to verify all required `${VARIABLE}` keys exist.
- **Goal**: Prevents runtime failures due to missing configuration.

### 4. `check_ssd_mount`
- **Command**: `mount | grep "${MOUNT_USB_DRIVE}"`
- **Goal**: Ensures safety of the physical storage layer.

### 5. `audit_telemetry`
- **Command**: `./scripts/audit-telemetry.sh`
- **Goal**: Cross-references GitOps telemetry with native CLI traces to identify protocol violations.
