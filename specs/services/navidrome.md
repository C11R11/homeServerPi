# Service Specification: Navidrome

## Target Image
- `deluan/navidrome:latest`

## Networking
- **Port**: `4533`

## Storage Mapping
- **Data**: `${MOUNT_USB_DRIVE}/Music/navidrome/data` -> `/data`
- **Music**: `${MOUNT_USB_DRIVE}/Music` -> `/music:ro`

## Resource Guarding
- **Memory Limit**: `1GB`
- **Restart Policy**: `unless-stopped`

## User Context
- **UID/GID**: `1000:1000` (Should match `${PUID}:${PGID}`)
