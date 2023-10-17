# Deployment of Vangrant Ubuntu Cluster with Lamp Stack using bash script to automate the installation and configuration.

This Vagrant project allows you to create a multi-node environment with a load balancer using Vagrant and VirtualBox. It sets up three virtual machines:

- **Master Node:** This node serves as the primary node and hosts a basic LAMP stack, and also runs a cron job to collect process information at every boot.

- **Slave Node:** Similar to the master node, this node hosts a basic LAMP stack and runs a cron job to collect process information at every boot.

- **Load Balancer:** This node is configured as an Nginx-based load balancer to distribute incoming traffic across the master and slave nodes with the weighted method of balancing.

## Prerequisites

-  Before using this Vagrant project, ensure that you have the following software installed on your local machine:

- [Vagrant](https://www.vagrantup.com/)
- [VirtualBox](https://www.virtualbox.org/)
- [MySQL] 
- [PHP]
- [Apache]


## This script sets up a multi-node environment using Vagrant and VirtualBox. Below is a breakdown of what the script does:

1. Creates a shared folder named "shared" in the project directory.

2. Generates a Vagrantfile to define the virtual machines and their configurations.

3. The script provisions three virtual machines:

   - **Master Node (192.168.56.10)**:
     - Updates the system and installs a LAMP stack (Apache, MySQL, PHP).
     - Creates a user "altschool" and adds it to the "admin" group.
     - Grants "altschool" user root privileges.
     - Generates an SSH key (ed25519)fingerprint type  for "altschool" user without a passphrase.
     - Copies the public SSH key to the shared directory.
     - Creates a test PHP page to render the LAMP stack.
     - Creates a directory `/mnt/altschool` and a `master_data.txt` file in it.
     - create txt content and copies the content to `master_data.txt`.
     - Sets up a cronjob to run `ps -aux` at every boot. which the report is also available in the shared directory for both master and slave node.

   - **Slave Node (192.168.56.11)**:
     - Similar setup as the master node.
     - Copies the id_ed25519.pub SSH key from the shared folder to the "altschool" user.
     - Creates a directory `/mnt/altschool/` and copies content from the shared folder that was written there from the master node.
     - Removes the `master_data.txt` file from the shared folder after use.

   - **Load Balancer Node (192.168.56.12)**:
     - Updates the system and installs Nginx and UFW (Uncomplicated Firewall).
     - The ufw allows traffic for http and https.
     - Configures Nginx as a load balancer, distributing traffic to master and slave nodes using weighted method of load balancing.
     - Creates a test page to render the load balancer.
     - Symlinks Nginx configuration to enable load balancing.
     - Tests Nginx configuration and reloads Nginx.

4. Add the user execute permission before running the .sh script.

5. Then starts the virtual machines using `vagrant up` command.

6. Finally Provides basic error checking and reports if Vagrant provisioning completed successfully.

## Usage

- Clone this repository to your local machine.

- In the project directory, open a terminal and run the following command to start the virtual machines:

   `vagrant up`

-  Once the provisioning is complete, you can access the load balancer's web interface in your browser by navigating to http://192.168.56.12. The load balancer will distribute traffic between the master and slave nodes.

-  To access the virtual machines, you can use SSH. For example, to access the master node:

   `vagrant ssh master`


-  Replace "master" with "slave" for the slave node and for the "loadbalancer" for access logs.

- To shut down and destroy the virtual machines, run:

   `vagrant destroy -f`

## Customization
- You can customize the IP addresses and specifications (CPU, memory) for each virtual machine by modifying the Vagrantfile.

- The provisioning scripts for each node can be customized by editing the respective sections in the Vagrantfile.

- Cron jobs for collecting process information run at boot which are located in the /etc/cron.d/ directory on the master and slave nodes was directed to the /home/vagrant/shared directory for easy access or monitoring.

## Troubleshooting
-  If you encounter any issues during provisioning or while using the virtual machines, refer to the error messages and logs to identify the problem.

## Acknowledgments
-  This project was created as a basic example for setting up a multi-node environment with Vagrant. It can be extended and customized to meet specific requirements.

## License
-  This project is licensed under the MIT License.


-  Feel free to use this README file and adapt it to your specific project needs.
-  If you have any questions or need further assistance, please feel free to ask!
