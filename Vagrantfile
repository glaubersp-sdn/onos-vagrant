# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  # config.vm.box = "bento/ubuntu-18.04"
  # config.vm.box = "generic/ubuntu1804"
  # config.vm.box = "ubuntu/bionic64"
  config.vm.box = "peru/ubuntu-18.04-desktop-amd64"
  # config.vm.box_version = "20190801.01"

  config.vm.hostname = "onos"
  
  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
   config.vm.box_check_update = true

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  config.vm.provider "virtualbox" do |vb|
    vb.gui = true
    vb.name = "ONOS Simulator"
    vb.memory = "4096"
    vb.cpus = 2
    vb.customize ["modifyvm", :id, "--vram", "32"]
    vb.customize ["modifyvm", :id, "--cpuexecutioncap", "70"]
    vb.customize ["modifyvm", :id, "--accelerate3d", "on"]
    vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
    vb.customize ["modifyvm", :id, "--audiocontroller", "hda"]
  end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  config.vm.provision "shell", inline: <<-SHELL
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y git openjdk-11-jdk mininet bridge-utils curl vim

    # Install Bazel
    curl -fsSL https://bazel.build/bazel-release.pub.gpg | apt-key add -
    add-apt-repository "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8"
    apt-get install -y bazel

    # Install Docker
    apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    apt-get install -y docker-ce docker-ce-cli containerd.io
    usermod -aG docker vagrant

    # Remove apt packages
    apt-get upgrade -y
    apt-get autoremove --purge -y
    apt-get clean

    snap install intellij-idea-ultimate --classic

    SHELL
  
  config.vm.provision "shell", privileged: false, inline: <<-SHELL
    # Download ONOS
    cd /home/vagrant
    if [[ ! -d "onos" ]]; then
      git clone https://github.com/opennetworkinglab/onos
      chown -R vagrant:vagrant onos
      cat <<-'EOF' > /home/vagrant/.bash_profile
export ONOS_ROOT="/home/vagrant/onos"
source $ONOS_ROOT/tools/dev/bash_profile
EOF
    fi
    source /home/vagrant/.bash_profile
    # Download ODTN
    cd /home/vagrant
    if [[ ! -d "ODTN-emulator" ]]; then
      git clone https://github.com/opennetworkinglab/ODTN-emulator
      chown -R vagrant:vagrant ODTN-emulator
    fi

    # Compile ONOS
    cd $ONOS_ROOT
    bazel build onos &> onos_build.log
    nohup bazel run onos-local -- clean debug &> onos_execution.log &

    # Compile ODTN
    cd /home/vagrant/ODTN-emulator
    docker-compose up -d &> odtc_build.log &

  SHELL
end