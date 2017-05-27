# -*- mode: ruby -*-
# # vi: set ft=ruby :

# Specify minimum Vagrant version and Vagrant API version
Vagrant.require_version ">= 1.6.0"
VAGRANTFILE_API_VERSION = "2"

# Require YAML module
require 'yaml'

# Read YAML file with box details
servers = YAML.load_file('servers.yaml')

# Create boxes
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Iterate through entries in YAML file
  servers['servers'].each do |servers|

    config.vm.define servers["name"] do |srv|

      srv.vm.hostname = servers["name"]
      srv.vm.box      = servers["box"]

      servers["forward_ports"].each do |port|
        srv.vm.network :forwarded_port, guest: port["guest"], host: port["host"]
      end

      srv.vm.network "private_network", ip: servers["ip"], auto_config: true

      srv.vm.provider :virtualbox do |v|
        v.cpus   = servers["cpu"]
        v.memory = servers["ram"]

        # change the network card hardware for nic 1.
        v.customize ["modifyvm", :id, "--nictype1", "virtio"]
        # change the nat network.
        v.customize ["modifyvm", :id, "--natnet1", "10.10.2.0/24"]

        # change the network card hardware for nic 1.
        v.customize ["modifyvm", :id, "--nictype2", "virtio" ]

        # testing ...
        v.customize ["modifyvm", :id, "--natdnshostresolver2", "off"]
        v.customize ["modifyvm", :id, "--natdnsproxy2", "off"]
      end

      srv.vm.synced_folder "./", "/home/vagrant/#{servers['name']}"

      servers["shell_commands"].each do |sh|
        srv.vm.provision "shell", inline: sh["shell"], name: sh["name"]
      end

      srv.vm.provision :puppet do |puppet|
        puppet.temp_dir = "/tmp"
        puppet.options  = ['--modulepath=/tmp/modules', '--verbose']
        puppet.hiera_config_path = "hiera.yaml"
      end

    end
  end
end
