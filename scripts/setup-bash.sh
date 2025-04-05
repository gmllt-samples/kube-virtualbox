#!/bin/bash
set -e

ROOT_HOME="/root"
BASHRC_FILE="$ROOT_HOME/.bashrc"

# Install oh-my-bash
if [ ! -d "$ROOT_HOME/.oh-my-bash" ]; then
  echo "Installing oh-my-bash..."
  git clone --depth=1 https://github.com/ohmybash/oh-my-bash.git "$ROOT_HOME/.oh-my-bash"
  cp "$ROOT_HOME/.oh-my-bash/templates/bashrc.osh-template" "$BASHRC_FILE"
  chown -R root:root "$ROOT_HOME/.oh-my-bash"
fi

# Clean previous custom blocks if any
sed -i '/# Custom Kubernetes shell enhancements/,$d' "$BASHRC_FILE"

# Determine prompt color and format
if hostname | grep -q control-plane; then
  PROMPT_COLOR="33" # yellow
  BANNER_MSG="Welcome to CONTROL PLANE NODE"
else
  PROMPT_COLOR="32" # green
  BANNER_MSG="Welcome to WORKER NODE"
fi

# Apply configuration
cat <<EOF >> "$BASHRC_FILE"

# Custom Kubernetes shell enhancements
export KUBECONFIG=/etc/kubernetes/admin.conf

# Enable completion if available
for cmd in kubectl kubeadm kubelet crictl; do
  if command -v \$cmd &>/dev/null; then
    source <(\$cmd completion bash 2>/dev/null || true)
  fi
done

# Aliases
alias k=kubectl
alias kubens='kubectl config set-context --current --namespace'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'

# Custom banner
echo -e "\033[1;\${PROMPT_COLOR}m\$BANNER_MSG\033[0m"

# Powerline-style prompt with color
export PS1='\[\e[0;38;5;10m\]\\u@\\h:\\w\\[\e[0m\]\\$ '
EOF

# Ensure root has ownership
chown root:root "$BASHRC_FILE"

# Reload .bashrc on login
if ! grep -q ".bashrc" "$ROOT_HOME/.profile"; then
  echo "source ~/.bashrc" >> "$ROOT_HOME/.profile"
fi