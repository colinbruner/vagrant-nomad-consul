# -*- mode: ruby -*-
# vi: set ft=ruby :

# Specify minimum Vagrant version and Vagrant API version
Vagrant.require_version ">= 1.6.0"
VAGRANTFILE_API_VERSION = "2"

# Require YAML module
require 'yaml'

# Read YAML file with box details
nodes = YAML.load_file("config.yml")

def configure_network(server, node)
	server.vm.network "private_network", ip: node["ip"]
	# Sync up local certs folder to VMs
	server.vm.synced_folder "certs", "/opt/certs"
end

def configure_vm(server, node)
	server.vm.provider :virtualbox do |vb|
		vb.name   = node["hostname"]
		vb.memory = node["ram"]
	end
end

# Create boxes
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
	config.vm.box = "bento/ubuntu-20.04"

	config.vm.define "nomad" do |server|
		# Single Nomad Node
		nomad = nodes["nomad"]

		# Set Hostname
		server.vm.hostname = nomad["hostname"]

		###
		# Network
		###
		# Configure Network for Servers
		configure_network server, nomad

		# Enable access to Nomad UI.
		server.vm.network "forwarded_port", guest: 4646, host: 4646, auto_correct: true, host_ip: "127.0.0.1"
		# Enable access to Docker hello world app.
		(8000...8100).each do |port|
			server.vm.network "forwarded_port", guest: port, host: port, auto_correct: true, host_ip: "127.0.0.1"
		end

		###
		# Install Nomad / Consul
		###
		server.vm.provision "shell", name: "nomad-install", path: "scripts/nomad/install.sh", env: {"DEBIAN_FRONTEND" => "noninteractive" }
		server.vm.provision "shell", name: "cni", path: "scripts/nomad/drivers/cni.sh"
		server.vm.provision "shell", name: "consul-install", path: "scripts/consul/install.sh", env: {"DEBIAN_FRONTEND" => "noninteractive" }

		###
		# Configure Nomad / Consul
		###
		server.vm.provision "shell", path: "scripts/nomad/server/configure.sh"
		# Grab the Consul Server's IP to inject into the retry-join array of Consul's config
		server.vm.provision "shell" do | s|
			s.path = "scripts/consul/client/configure.sh"
			s.args = "#{nodes['consul']['ip']}"
		end

		###
		# VM Resources
		###
		configure_vm server, nomad
	end

	config.vm.define "consul" do |server|
		# Single Consul Server
		consul = nodes["consul"]

		# Set Hostname
		server.vm.hostname = consul["hostname"]

		###
		# Network
		###
		# Configure Network for Servers
		configure_network server, consul

		## Enable access to Consul UI.
		server.vm.network "forwarded_port", guest: 8500, host: 8500, auto_correct: true, host_ip: "127.0.0.1"

		####
		## Install & Configure Consul Server
		####
		server.vm.provision "shell", path: "scripts/consul/install.sh", env: {"DEBIAN_FRONTEND" => "noninteractive" }
		server.vm.provision "shell", path: "scripts/consul/server/configure.sh"

		###
		# VM Resources
		###
		configure_vm server, consul
	end
end
