require 'yaml'
require 'ipaddr'
require 'json'

config_data = YAML.load_file('config.yaml')
bridge_iface = config_data.dig("network", "bridge_interface")
subnet = IPAddr.new(config_data.dig("network", "private_network_subnet") || "192.168.56.0/24")
vm_prefix = "kube-virtualbox"

control_plane_config = config_data.dig("vms", "control-plane")
worker_config = config_data.dig("vms", "worker")

def configure_vm(node, full_name, ip, resources, bridge_iface, extra_provision = false)
  node.vm.hostname = full_name

  node.vm.network "public_network",
    bridge: bridge_iface,
    use_dhcp_assigned_default_route: true,
    auto_config: true

  node.vm.network "private_network", ip: ip

  node.vm.provider "virtualbox" do |vb|
    vb.name = full_name
    vb.memory = resources["memory"]
    vb.cpus = resources["cpus"]

    disk_size = resources["disk"] || 102400
    disk_path = File.expand_path(".vagrant/disk-#{full_name}.vdi", Dir.pwd)

    unless File.exist?(disk_path)
      vb.customize ['createhd', '--filename', disk_path, '--size', disk_size]
    end

    vb.customize [
      'storageattach', :id,
      '--storagectl', 'SCSI',
      '--port', 2,
      '--device', 0,
      '--type', 'hdd',
      '--medium', disk_path
    ]
  end

  node.vm.provision "shell", path: "scripts/mount-data-disk.sh"
  node.vm.provision "shell", path: "scripts/common.sh"
  node.vm.provision "shell", path: "scripts/setup-bash.sh"
  node.vm.provision "shell", path: "scripts/control-plane-extra.sh" if extra_provision
end

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"

  all_vms = []
  ip_enum = subnet.to_range.to_a[10..-1]
  ip_index = 0

  {
    "control-plane-1" => control_plane_config,
    "worker-1"        => worker_config,
    "worker-2"        => worker_config,
    "worker-3"        => worker_config
  }.each do |name, resources|
    full_name = "#{vm_prefix}-#{name}"
    ip = ip_enum[ip_index].to_s
    ip_index += 1
    all_vms << { name: name, ip: ip }

    config.vm.define name do |node|
      configure_vm(node, full_name, ip, resources, bridge_iface, name.start_with?("control-plane"))
    end
  end

  # Write the VM list to JSON file for Makefile usage
  FileUtils.mkdir_p(".vagrant")
  File.write(".vagrant/vm_list.json", JSON.pretty_generate(all_vms))
end
