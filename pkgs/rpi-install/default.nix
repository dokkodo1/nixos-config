#!/usr/bin/env bash
# Deploy to Raspberry Pi 4 using nixos-anywhere

set -euo pipefail

# Configuration
TARGET_HOST="root@192.168.1.100"  # Replace with your Pi's IP
FLAKE_PATH="."
TARGET_SYSTEM="rpi4"

echo "🚀 Deploying NixOS to Raspberry Pi 4..."
echo "Target: $TARGET_HOST"
echo "System: $TARGET_SYSTEM"

# Run nixos-anywhere
nix run github:nix-community/nixos-anywhere -- \
  --flake ".#$TARGET_SYSTEM" \
  --copy-host-keys \
  --no-reboot \
  "$TARGET_HOST"

echo "✅ Deployment complete!"
echo "💡 You can now SSH to dokkodo@[pi-ip-address]"

# ===== Usage Instructions =====
# 1. Flash NixOS minimal ISO to SD card
# 2. Boot Pi, enable SSH, set root password
# 3. Find Pi's IP address
# 4. Update TARGET_HOST in install script
# 5. Add your SSH public key to configuration.nix
# 6. Run: chmod +x install-rpi4.sh && ./install-rpi4.sh
# 7. After install: ssh dokkodo@[pi-ip] to connect