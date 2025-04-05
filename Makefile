# Makefile for kube-virtualbox (fixed VM count)

SSH_KEY = .vagrant/machines
SSH_OPTS = -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null
VM_LIST_FILE = .vagrant/vm_list.json

# VM control
up: ## Start all VMs
	vagrant up --parallel
	@echo ""
	@echo "All VMs are up and running."
	@echo ""
	@echo "To enable make auto-completion:"
	@echo '  eval "$$(make completion)"'
	@echo ""
	@echo "To make it permanent, add this line to your ~/.bashrc:"
	@echo '  eval "$$(make completion)"'

destroy: ## Destroy all VMs
	vagrant destroy -f

reset: ## Destroy and recreate all VMs
	$(MAKE) destroy
	$(MAKE) up

provision: ## Re-run all provisioning scripts
	vagrant provision

status: ## Show list of VMs and their IPs
	@echo "VMs and IPs:"
	@jq -r '.[] | "  \(.name)\t\(.ip)"' $(VM_LIST_FILE)

completion: ## Show make auto-completion code
	@echo 'complete -W "$(grep -E '^[a-zA-Z0-9_.-]+:.*?#' Makefile | cut -d: -f1)" make'

# SSH commands (as root)
ssh-control-plane-1: ## SSH into control-plane-1 as root
	ssh -i $(SSH_KEY)/control-plane-1/virtualbox/private_key $(SSH_OPTS) root@$$(jq -r '.[] | select(.name=="control-plane-1") | .ip' $(VM_LIST_FILE))

ssh-worker-1: ## SSH into worker-1 as root
	ssh -i $(SSH_KEY)/worker-1/virtualbox/private_key $(SSH_OPTS) root@$$(jq -r '.[] | select(.name=="worker-1") | .ip' $(VM_LIST_FILE))

ssh-worker-2: ## SSH into worker-2 as root
	ssh -i $(SSH_KEY)/worker-2/virtualbox/private_key $(SSH_OPTS) root@$$(jq -r '.[] | select(.name=="worker-2") | .ip' $(VM_LIST_FILE))

ssh-worker-3: ## SSH into worker-3 as root
	ssh -i $(SSH_KEY)/worker-3/virtualbox/private_key $(SSH_OPTS) root@$$(jq -r '.[] | select(.name=="worker-3") | .ip' $(VM_LIST_FILE))

# Help
help: ## Show this help message
	@echo "Available make commands:"
	@grep -h -E '^[a-zA-Z0-9_.-]+:.*?# .*$$' Makefile 2>/dev/null | sort | awk 'BEGIN {FS = ":.*?# "}; {printf "  %-20s %s\n", $$1, $$2}'
