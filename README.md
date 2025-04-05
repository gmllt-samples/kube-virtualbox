# kube-virtualbox

This project helps you create a local multi-node Kubernetes cluster using Vagrant and VirtualBox.

## Features

- 1 control-plane VM and 3 worker VMs
- Ubuntu 22.04 (jammy64)
- Static IP configuration
- SSH access as root
- containerd + crictl + kubelet + kubeadm installed
- oh-my-bash installed on all VMs (for root)
- Bash aliases and completions for Kubernetes tools
- kubectl only on the control-plane
- Cilium compatible kubeadm init support
- Simple and powerful Makefile for all operations

## Requirements

- Vagrant
- VirtualBox
- Make (for Linux/Mac users)

## Quick Start

### 1. Start the VMs

#### Using Make (Linux/Mac)
```bash
make up
```

#### Using Vagrant (Windows)
```bash
vagrant up --parallel
```

### 2. SSH into the nodes

#### Using Make (Linux/Mac)
```bash
make ssh-control-plane-1
make ssh-worker-1
make ssh-worker-2
make ssh-worker-3
```

#### Using Vagrant (Windows)
```bash
vagrant ssh control-plane-1 -c 'sudo -i'
vagrant ssh worker-1 -c 'sudo -i'
vagrant ssh worker-2 -c 'sudo -i'
vagrant ssh worker-3 -c 'sudo -i'
```

### 3. Show VM status

#### Using Make (Linux/Mac)
```bash
make status
```

#### Using Vagrant (Windows)
```bash
vagrant status
```

### 4. Destroy or reset the cluster

#### Using Make (Linux/Mac)
```bash
make destroy     # Stop and delete all VMs
make reset       # Destroy and recreate all VMs
```

#### Using Vagrant (Windows)
```bash
vagrant destroy -f     # Stop and delete all VMs
vagrant up --parallel   # Recreate VMs
```

## Shell enhancements

All VMs come with:
- oh-my-bash for root
- Bash completions for: `kubectl`, `kubeadm`, `kubelet`, `crictl`
- Aliases:
  - `k` for `kubectl`
  - `kubens` for `kubectl config set-context --current --namespace`
  - `ll`, `la`, `l`, `..` for common shell usage

The control-plane prompt is yellow, workers are green.

## Auto-completion (host side)

To enable auto-completion for Makefile commands, the completion command is removed due to compatibility issues.
You can manually enable auto-completion with:
```bash
eval "$(make completion)"
```
To make it permanent, add this to your `~/.bashrc`:
```bash
eval "$(make completion)"
```

## Project structure

- `Vagrantfile` — VM definitions and provisioning
- `config.yaml` — resource and network configuration
- `scripts/common.sh` — provisioning shared by all VMs
- `scripts/setup-bash.sh` — setup shell environment for root
- `scripts/control-plane-extra.sh` — control-plane specific provisioning
- `Makefile` — automation for cluster lifecycle