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
4. **Volume Mapping**: Always map to the SSD via `${MOUNT_USB_DRIVE}` to prevent SD card wear and overflow.
5. **Token Metric Enforcement**: Every agent task must terminate by appending its token consumption metrics (Input, Reasoning, Output) to the local `.telemetry/gemini-gitops.log`.
