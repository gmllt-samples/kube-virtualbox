#!/bin/bash
set -e

echo "[Provision] Mounting secondary data disk..."

DEVICE="/dev/sdc"
PART="${DEVICE}1"
MOUNT_POINT="/mnt/data"

# Skip if already mounted
if mountpoint -q "$MOUNT_POINT"; then
  echo "[Provision] $MOUNT_POINT already mounted. Skipping."
  exit 0
fi

# Skip if already partitioned
if lsblk -no NAME "$DEVICE" | grep -q "$(basename $PART)"; then
  echo "[Provision] $DEVICE already partitioned. Skipping partitioning."
else
  echo "[Provision] Partitioning $DEVICE..."
  dd if=/dev/zero of=$DEVICE bs=1M count=10
  echo -e "o\nn\np\n1\n\n\nw" | fdisk $DEVICE
  partprobe $DEVICE
  sleep 1
fi

# Format only if needed
if ! blkid "$PART" &>/dev/null; then
  echo "[Provision] Formatting $PART..."
  mkfs.ext4 "$PART"
fi

# Create mount point if not exists
mkdir -p "$MOUNT_POINT"

# Mount
mount "$PART" "$MOUNT_POINT"

# Add to fstab if not already there
if ! grep -qs "$MOUNT_POINT" /etc/fstab; then
  echo "$PART $MOUNT_POINT ext4 defaults 0 0" >> /etc/fstab
fi

echo "[Provision] $PART mounted to $MOUNT_POINT."
