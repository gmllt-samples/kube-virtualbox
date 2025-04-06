#!/bin/bash
set -e

DEVICE="/dev/sdc"
PART="${DEVICE}1"
MOUNT_POINT="/mnt/data"

echo "[Provision] Mounting secondary data disk..."

# Skip if already mounted
if mountpoint -q "$MOUNT_POINT"; then
  echo "[Provision] $MOUNT_POINT already mounted. Skipping."
  exit 0
fi

# Create partition if missing
if ! lsblk -no NAME "$DEVICE" | grep -q "$(basename $PART)"; then
  echo "[Provision] Partitioning $DEVICE..."
  dd if=/dev/zero of=$DEVICE bs=1M count=10
  echo -e "o\nn\np\n1\n\n\nw" | fdisk $DEVICE
  partprobe $DEVICE || true
  udevadm settle
  sleep 2
fi

# Try mount
mkdir -p "$MOUNT_POINT"
if mount "$PART" "$MOUNT_POINT"; then
  echo "[Provision] Mounted $PART on $MOUNT_POINT"
  exit 0
else
  echo "[Provision] Mount failed, reformatting $PART..."
  mkfs.ext4 "$PART"
  sleep 1
  mount "$PART" "$MOUNT_POINT"
  echo "[Provision] Mounted $PART on $MOUNT_POINT after formatting"
fi
