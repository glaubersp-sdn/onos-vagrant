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
  config.vm.box = "bento/ubuntu-18.04"
  # config.vm.box = "generic/ubuntu1804"
  # config.vm.box = "ubuntu/bionic64"
  # config.vm.box = "peru/ubuntu-18.04-desktop-amd64"

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
  config.vm.network "forwarded_port", guest: 8181, host: 8181, host_ip: "127.0.0.1"
  config.vm.network "forwarded_port", guest: 8101, host: 8101, host_ip: "127.0.0.1"

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
  config.vm.synced_folder "src/", "/home/vagrant/src"

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
    vb.name = "ONOS Simulator"
    vb.gui = false
    vb.memory = "4096"
    vb.cpus = 2
    vb.customize ["modifyvm", :id, "--vram", "32"]
    # vb.customize ["modifyvm", :id, "--cpuexecutioncap", "70"]
    # vb.customize ["modifyvm", :id, "--accelerate3d", "on"]
    vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
    vb.customize ["modifyvm", :id, "--audiocontroller", "hda"]
  end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  config.vm.provision "shell", inline: <<-SHELL
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y git openjdk-11-jdk mininet bridge-utils curl vim python-pip

    # Install Docker
    apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    apt-get install -y docker-ce docker-ce-cli containerd.io
    usermod -aG docker vagrant

    systemctl enable docker
    systemctl start docker

    curl -L https://github.com/docker/compose/releases/download/1.18.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose

    # Remove apt packages
    apt-get dist-upgrade -y
    apt-get autoremove --purge -y
    apt-get clean

    # Install ONOS
    sudo adduser onos --system --group

    rm -fr /opt/onos
    tar xvzf /home/vagrant/src/onos.tar.gz -C /opt/
    cd /opt
    ln -s onos-2.2.0-SNAPSHOT onos

    cat <<-'EOF' > /opt/onos/options
ONOS_USER=onos
ONOS_APPS=odtn-service,roadm,gui2,optical-rest
EOF
    cp /opt/onos/init/onos.initd /etc/init.d/onos
    cp /opt/onos/init/onos.service /etc/systemd/system/

    sudo chown -R onos:onos /opt/onos*

    systemctl daemon-reload
    systemctl enable onos
    systemctl restart onos

    pip install requests

  SHELL

  config.vm.provision "shell", privileged: false, inline: <<-SHELL
    cat <<-'EOF' > ~/.bash_profile
PATH=$PATH:/opt/onos/bin:/home/vagrant/src/scenarios-bin
EOF

    source ~/.bash_profile

    # Run docker images
    cd ~/src
    docker-compose up -d

  SHELL
end