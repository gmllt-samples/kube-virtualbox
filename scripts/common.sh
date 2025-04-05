#!/bin/bash
set -e

echo "[Provision] Base setup for $(hostname)"

# Enable root login and copy vagrant key
if ! grep -q "PermitRootLogin yes" /etc/ssh/sshd_config; then
  echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
  systemctl restart ssh
fi

mkdir -p /root/.ssh
cp /home/vagrant/.ssh/authorized_keys /root/.ssh/authorized_keys
chown root:root /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

# Dependencies
apt-get update
apt-get install -y apt-transport-https ca-certificates curl gpg gnupg lsb-release software-properties-common

# Kernel modules and sysctl for kubeadm
modprobe br_netfilter

cat <<EOF > /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sysctl --system

# Containerd
if ! command -v containerd &>/dev/null; then
  apt-get install -y containerd
  mkdir -p /etc/containerd
  containerd config default > /etc/containerd/config.toml
  systemctl restart containerd
  systemctl enable containerd
fi

# crictl
CRICTL_VERSION="v1.29.0"
if ! command -v crictl &>/dev/null; then
  curl -LO https://github.com/kubernetes-sigs/cri-tools/releases/download/$CRICTL_VERSION/crictl-$CRICTL_VERSION-linux-amd64.tar.gz
  tar zxvf crictl-$CRICTL_VERSION-linux-amd64.tar.gz -C /usr/local/bin
  rm crictl-$CRICTL_VERSION-linux-amd64.tar.gz
fi

# kubeadm and kubelet
if [ ! -f /etc/apt/keyrings/kubernetes-apt-keyring.gpg ]; then
  mkdir -p /etc/apt/keyrings
  curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | \
    gpg --dearmor --yes --batch --no-tty -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
fi

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" \
  > /etc/apt/sources.list.d/kubernetes.list

apt-get update
apt-get install -y kubelet kubeadm
apt-mark hold kubelet kubeadm
systemctl enable kubelet