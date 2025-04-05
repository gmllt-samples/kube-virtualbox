#!/bin/bash
set -e

echo "[Provision] Installing kubectl on $(hostname)"

apt-get install -y kubectl
apt-mark hold kubectl
