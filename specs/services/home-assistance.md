# Service Specification: Home Assistance (Dev)

## Overview
This specification defines the Home Assistance stack for the development environment. It includes Home Assistant for home automation and ESPHome for managing ESP8266/ESP32 devices.

## Service Definitions

### 1. Home Assistant
- **Image**: `ghcr.io/home-assistant/home-assistant:stable`
- **Network Mode**: `host` (Critical for local device discovery)
- **Restart Policy**: `unless-stopped`
- **Resource Limits**: 1.5GB RAM
- **Volumes**:
  - `${HASS_CONFIG_DIR}` -> `/config`
  - `/etc/localtime` -> `/etc/localtime` (Read-only)

### 2. ESPHome
- **Image**: `ghcr.io/esphome/esphome`
- **Network Mode**: `host`
- **Restart Policy**: `unless-stopped`
- **Resource Limits**: 1.5GB RAM
- **Volumes**:
  - `${ESPHOME_CONFIG_DIR}` -> `/config`
  - `/etc/localtime` -> `/etc/localtime` (Read-only)

## Environment Configuration
This specification relies on a `.env` file for path and identity management. All persistent data MUST reside on the configured mount point.

### Mandatory Environment Variables
| Variable | Description | Default (Dev) |
| :--- | :--- | :--- |
| `MOUNT_USB_DRIVE` | Root path for persistent storage | `/tmp/homeServerPi-dev` |
| `HASS_CONFIG_DIR` | Path for Home Assistant configuration | `${MOUNT_USB_DRIVE}/config/homeassistant` |
| `ESPHOME_CONFIG_DIR` | Path for ESPHome configuration | `${MOUNT_USB_DRIVE}/config/esphome` |
| `PUID` | User ID for file permissions | `1000` |
| `PGID` | Group ID for file permissions | `1000` |

## Compliance & Constraints
- **SDD First**: Any changes to the `environments/dev/docker-compose.yml` MUST be reflected here first.
- **Resource Guarding**: Memory limits are strictly enforced to protect the Raspberry Pi environment.
- **Variable-Driven**: No absolute paths are permitted in the blueprint; all must use `${VARIABLE}` syntax.
