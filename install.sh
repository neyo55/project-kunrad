#!/bin/bash

# create a shared directory called "shared" in the project directory
mkdir -p shared

# create a vagrant file
touch Vagrantfile

# edit the vagrant file
cat <<EOF > Vagrantfile
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure ("2") do |config|
  config.vm.box = "bento/ubuntu-20.04"
  config.vm.synced_folder "shared", "/home/vagrant/shared"
  config.vm.define "master" do |master|
    master.vm.network "private_network", ip: "192.168.56.10"
    master.vm.hostname = "master"
    master.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = "1"
    end

    # Provisioning script for the master node
    master.vm.provision "shell", inline: <<-SHELL
      sudo apt-get -y update

      # Create a new group called 'admin', add users into this group
      sudo groupadd admin
      sudo useradd -m -G sudo -s /bin/bash altschool
      echo "altschool:53669" | sudo chpasswd
      sudo usermod -aG admin altschool
      sudo usermod -aG admin vagrant

      # Grant 'altschool' user root privileges
      echo "altschool ALL=(ALL:ALL) ALL" | sudo tee -a /etc/sudoers

      # set up permissions so that we can use sudo without entering our password each time
      echo "%admin ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/admin

      # generate an ssh key for the altschool user(without a passphrase)
      sudo -u altschool ssh-keygen -t ed25519 -N "" -f /home/altschool/.ssh/id_ed25519 -C "altschool" -q

      # permission for the .ssh directory
      chmod 600 /home/altschool/.ssh/id_ed25519
      chmod 664 /home/altschool/.ssh/id_ed25519.pub

      # sleep 05 seconds before copying the keys
      sudo sleep 05 || true

      # copy the public key to the shared directory
      sudo cp /home/altschool/.ssh/id_ed25519.pub /home/vagrant/shared/id_ed25519.pub || true

      # install lamp stack
      DEBIAN_FRONTEND=noninteractive sudo apt-get install -y apache2 mysql-server php libapache2-mod-php php-mysql 

      # enable lamp stack
      sudo systemctl enable apache2 || true
      sudo systemctl enable mysql || true

      # start lamp stack
      sudo systemctl start apache2 || true
      sudo systemctl start mysql || true

      # secure mysql installation automatically
      sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password 53669'
      sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password 53669'

      # create a test php page to render lamp stack
      sudo echo "<?php phpinfo(); ?>" > /var/www/html/index.php

      # create a /mnt/altschool directory
      sudo mkdir -p /mnt/altschool

      # sleep 05 seconds before creating .txt
      sudo sleep 05 || true

      # create a test.txt file in /mnt/altschool
      sudo touch /mnt/altschool/master_data.txt

      # sleep 3 seconds before copying the keys
      sudo sleep 03 || true

      #create a test content in master_data.txt
      sudo echo "I am Adeniyi, my prayer to make it to the final of this course and be one of the formidable DevOps Engineer. See you at the slave node" > /mnt/altschool/master_data.txt

      # sleep 05 seconds before copying the keys
      sudo sleep 05 || true

      #copy the content of the /mnt/altschool to the shared folder
      sudo cp -r /mnt/altschool/* /home/vagrant/shared || true

      # Use the touch command to create the .txt file
      touch "/home/vagrant/shared/ps_master.txt"

      # Change the permissions for the .txt file
      chmod 644 /home/vagrant/shared/ps_master.txt 

      # Change the ownership of a directory and its contents
      chown -R altschool:admin /home/vagrant/shared/ps_master.txt

      # create a cronjob to run ps -aux at every boot
      echo "@reboot altschool ps -aux > /home/vagrant/shared/ps_master.txt" | sudo tee /etc/cron.d/ps_master
    SHELL
  end

  config.vm.define "slave" do |slave|
  config.vm.box = "bento/ubuntu-20.04"
  config.vm.synced_folder "shared", "/home/vagrant/shared"
    slave.vm.network "private_network", ip: "192.168.56.11"
    slave.vm.hostname = "slave"
    slave.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = "1"
    end

    # Provisioning script for the slave node
    slave.vm.provision "shell", inline: <<-SHELL
      sudo apt-get -y update

      # Create a new group called 'admin', add users into this group
      sudo groupadd admin
      sudo useradd -m -G sudo -s /bin/bash altschool
      echo "altschool:53669" | sudo chpasswd
      sudo usermod -aG admin altschool
      sudo usermod -aG admin vagrant

      # Grant 'altschool' user root privileges
      echo "altschool ALL=(ALL:ALL) ALL" | sudo tee -a /etc/sudoers

      # set up permissions so that we can use sudo without entering our password each time
      echo "%admin ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/admin

      # Create the .ssh directory if it doesn't exist
      sudo -u altschool mkdir -p /home/altschool/.ssh || true

      # sleep 05 seconds before copying the key
      sudo sleep 05 || true

      # copy the public key from the shared directory to the ~/vagrant/.ssh/authorized_keys
      sudo cp /home/vagrant/shared/id_ed25519.pub /home/altschool/.ssh/authorized_keys || true

      # remove the public key from the shared folder
      sudo rm /home/vagrant/shared/id_ed25519.pub || true

      # sleep 05 seconds before creating directory
      sudo sleep 05 || true

      # make /mnt/altschool/ directory
      sudo mkdir -p /mnt/altschool/

      # permission for the /mnt/altschool/ directory
      sudo chmod 766 /mnt/altschool/

      # Assuming 'altschool' is the owner of the directory
      sudo chown -R altschool:admin /mnt/altschool/

      # sleep 05 seconds before the content
      sudo sleep 05 || true

      # copy the content of the shared folder to /mnt/altschool/ directory
      sudo cp -r /home/vagrant/shared/master_data.txt* /mnt/altschool/ || true

      # remove the master_data.txt file from the shared directory
      # sudo rm -rf /home/vagrant/shared/* || true
      sudo rm /home/vagrant/shared/master_data.txt || true

      # install lamp stack
      DEBIAN_FRONTEND=noninteractive sudo apt-get install -y apache2 mysql-server php libapache2-mod-php php-mysql

      # enable lamp stack
      sudo systemctl enable apache2 || true
      sudo systemctl enable mysql || true

      # start lamp stack
      sudo systemctl start apache2 || true
      sudo systemctl start mysql || true

      # secure mysql installation automatically
      sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password 53669'
      sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password 53669'

      # create a test php page to render lamp stack
      sudo echo "<?php phpinfo(); ?>" > /var/www/html/index.php

      # Specify the directory path and the file name
      directory_path="/home/vagrant/shared/"
      file_name="ps_slave.txt"

      # Use the touch command to create the file
      touch "/home/vagrant/shared/ps_slave.txt"

      # Change the permissions for the file
      chmod 644 /home/vagrant/shared/ps_slave.txt 

      # Change the ownership of the directory and its contents
      chown -R altschool:admin /home/vagrant/shared/ps_slave.txt 

      # create a cronjob to run ps -aux at every boot
      echo "@reboot altschool ps -aux > /home/vagrant/shared/ps_slave.txt" | sudo tee /etc/cron.d/ps_slave
    SHELL
  end

  # Define the Ubuntu 20.04 box for the load balancer (Nginx)
  config.vm.define "loadbalancer" do |lb|
    lb.vm.box = "bento/ubuntu-22.04"
    lb.vm.network "private_network", ip: "192.168.56.12"
    lb.vm.provider "virtualbox" do |vb|
      vb.memory = 1024 # 1GB RAM
      vb.cpus = 1
    end

    lb.vm.provision "shell", inline: <<-SHELL
      # provisioning specific steps to the load balancer

      # install update
      sudo apt-get -y update

      # create a load balancer with nginx
      DEBIAN_FRONTEND=noninteractive sudo apt-get install -y nginx
      
      # Install UFW (Uncomplicated Firewall)
      DEBIAN_FRONTEND=noninteractive sudo apt-get install -y ufw

      # Allow HTTP and HTTPS traffic
      sudo ufw allow http
      sudo ufw allow https
      sudo ufw --force enable

      # enable Nginx to start on boot
      sudo systemctl enable nginx

      #sleep for 05 seconds before starting nginx
      sudo sleep 05 || true

      #start Nginx
      sudo systemctl start nginx

      # remove the default nginx configuration
      sudo rm /etc/nginx/sites-available/default
      sudo rm /etc/nginx/sites-enabled/default

      # Reload Nginx to apply changes
      sudo systemctl reload nginx

      # Create a new Nginx configuration file with the load balancing configuration
      echo "upstream backend {" | sudo tee -a /etc/nginx/sites-available/loadbalancer.conf
      echo "    server 192.168.56.10 weight=3;" | sudo tee -a /etc/nginx/sites-available/loadbalancer.conf
      echo "    server 192.168.56.11 weight=1;" | sudo tee -a /etc/nginx/sites-available/loadbalancer.conf
      echo "}" | sudo tee -a /etc/nginx/sites-available/loadbalancer.conf
      echo "" | sudo tee -a /etc/nginx/sites-available/loadbalancer.conf
      echo "server {" | sudo tee -a /etc/nginx/sites-available/loadbalancer.conf
      echo "    listen 80;" | sudo tee -a /etc/nginx/sites-available/loadbalancer.conf
      echo "" | sudo tee -a /etc/nginx/sites-available/loadbalancer.conf
      echo "    location / {" | sudo tee -a /etc/nginx/sites-available/loadbalancer.conf
      echo "        proxy_pass http://backend;" | sudo tee -a /etc/nginx/sites-available/loadbalancer.conf
      echo "    }" | sudo tee -a /etc/nginx/sites-available/loadbalancer.conf
      echo "}" | sudo tee -a /etc/nginx/sites-available/loadbalancer.conf

      # create a page to render the load balancer
      sudo echo "<h1>Load Balancer</h1>" > /var/www/html/index.html || true

      # symlink the nginx configuration
      # sudo ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

      # Create a symbolic link to enable the configuration
      sudo ln -s /etc/nginx/sites-available/loadbalancer.conf /etc/nginx/sites-enabled/

      # Test Nginx configuration for syntax errors
      sudo nginx -t

      # If the syntax is okay, reload Nginx
      sudo systemctl reload nginx || true
    SHELL
  end
end
EOF

# Start the Vagrant virtual machines using vagrant up
vagrant up

# Check the exit status of the 'vagrant up' command
if vagrant up; then
    echo "Vagrant provisioning completed successfully."
else
    echo "Vagrant provisioning encountered errors."
fi

