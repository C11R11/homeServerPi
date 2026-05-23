# Specification: Bare-Metal Layer 0 Provisioning

## Target Host
- OS: Debian/Ubuntu (ARM64)
- User: `pi` (with passwordless sudo)

## Provisioning Requirements (Ansible Tasks)
1. **System Updates**: Ensure `apt` packages are fully updated and upgraded.
2. **Storage**: 
   - Identify the 480GB USB SSD by its **UUID** for idempotency.
   - Ensure the SSD is formatted (ext4).
   - Ensure the directory defined by `${MOUNT_USB_DRIVE}` is created.
   - Mount the SSD permanently via `/etc/fstab` to `${MOUNT_USB_DRIVE}`.
3. **Dependencies**: Install `curl`, `git`, `htop`, and `ufw`.
4. **Docker Engine**: Install the official Docker Engine and Docker Compose V2 plugin. Add the `pi` user to the `docker` group.
5. **Security**: Configure UFW to allow only SSH (Port 22) and standard HTTP/HTTPS traffic. (Minimalist Layer 0 scope).

## Required Variables
The provisioning playbook MUST utilize the following variables (passed via `--extra-vars` or environment):
- `MOUNT_USB_DRIVE`: Target mount point for the SSD.
- `SSD_UUID`: The unique identifier of the hardware drive.

# Output
* Generate an ansible file in `environments/prod/setup.yml` with all the requirements. 
* Update the system context documentation if needed.