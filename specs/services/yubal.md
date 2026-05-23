# Service Specification: Yubal

## Target Image
- `ghcr.io/guillevc/yubal:latest`

## Networking
- **Port mapping**: `4000:8000`

## Storage Mapping
- **App Data**: `${MOUNT_USB_DRIVE}/Music` -> `/app/data`
- **Config**: `${MOUNT_USB_DRIVE}/config/yubal` -> `/app/config`

## Environment Variables
- `YUBAL_SCHEDULER_CRON`: "0 0 * * *"
- `YUBAL_TZ`: "UTC"
- `PUID`: "1000"
- `PGID`: "1000"

## Resource Guarding
- **Memory Limit**: `1GB`
- **Restart Policy**: `unless-stopped`
