# Specification: Bare-Metal Layer 0 Provisioning

## Target Host
- OS: Debian/Ubuntu (ARM64)
- User: `pi` (with passwordless sudo)

## Provisioning Requirements (Ansible Tasks)
1. **System Updates**: Ensure `apt` packages are fully updated and upgraded.
2. **Storage**: 
   - Identify the 480GB USB SSD by its **UUID** for idempotency.
   - Ensure the SSD is formatted as `${SSD_FORMAT}`.
   - Ensure the directory defined by `${MOUNT_USB_DRIVE}` is created.
   - Mount the SSD permanently via `/etc/fstab` to `${MOUNT_USB_DRIVE}`.
3. **Dependencies**: Install `curl`, `git`, `htop`, and `ufw`.
4. **Docker Engine**: Install the official Docker Engine and Docker Compose V2 plugin. Add the `pi` user to the `docker` group.
5. **Security**:
   - **Firewall (UFW)**: Allow ports 22 (SSH), 80 (HTTP), 443 (HTTPS), 4533 (Navidrome), 4000 (Yubal), 8123 (Home Assistant), and 6052 (ESPHome).
   - **SSH Hardening**:
     - Ensure the `pi` user's authorized keys are synchronized (using `authorized_key` module with the key provided in `${SSH_PUBLIC_KEY_PATH}`).
     - Disable password-based authentication (`PasswordAuthentication no`).
     - Disable root login via SSH (`PermitRootLogin no`).

## Required Variables
The provisioning playbook MUST utilize the following variables (passed via `--extra-vars` or environment):
- `MOUNT_USB_DRIVE`: Target mount point for the SSD.
- `SSD_UUID`: The unique identifier of the hardware drive.
- `SSD_FORMAT`: The filesystem type (e.g., ext4, xfs).
- `SSH_PUBLIC_KEY_PATH`: Path to the public key file on the local machine to be added to the `pi` user.
Yo
# Output
* Generate an ansible file in `environments/prod/setup.yml` with all the requirements. 
* Update the system context documentation if needed.