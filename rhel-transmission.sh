#!/bin/bash
# Check if root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Docker setup
if [ -f "/usr/bin/docker" ]; then
    echo "Docker is already installed"
else
    echo "Adding Docker Repo"
    dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    echo ""
    echo "Updating DNF"
    dnf update -y
    echo ""
    echo "Installing Docker"
    dnf install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y --allowerasing
    echo ""
    echo "Enabling Docker"
    systemctl enable --now docker
fi

if [ -f /root/.env ]; then
    touch /root/.env
else
    rm /root/.env
    touch /root/.env
fi

# Samba setup

# Avahi setup
echo "Installing Avahi"
dnf install avahi-daemon -y
echo ""
echo "Configuring Avahi"
wget "https://raw.githubusercontent.com/UltimateNova1203/docker-repo/main/avahi/samba.service" -o /etc/avahi/services/samba.service
sed -i 's/foo/Transmission/g' /etc/avahi/services/samba.service
sed -i 's/#host-name=foo/host-name=transmission/g' /etc/avahi/avahi-daemon.conf
sed -i 's/#domain-name=local/domain-name=local/g' /etc/avahi/avahi-daemon.conf
sed -i 's/use-ipv6=yes/use-ipv6=no/g' /etc/avahi/avahi-daemon.conf

# NSS setup
echo ""
echo "Configuring NSS"
sed -i 's/hosts:      files dns myhostname/hosts:      files mdns4_minimal dns myhostname/g' /etc/nsswitch.conf

# Transmission setup
echo ""
echo "Enter the path for Transmission files: [e.g. '/media/transmission']"
read Folder
echo "FOLDER:$Folder" >> /root/.env

# Services compose
echo ""
echo "Start docker compose"
wget "https://raw.githubusercontent.com/UltimateNova1203/docker-repo/main/docker-transmission.yml"
docker compose -f docker-transmission.yml up -d
rm /root/docker-transmission.yml
rm /root/.env

# Firewall rules
echo ""
echo "Are you using a firewall? [y/n]:"
read FirewallStatus

if [ "$FirewallStatus" == "y" ]; then
    echo ""
    echo "Enabling firewall rules"
    echo "Transmission TCP"
    firewall-cmd --permanent --add-port=51413/tcp
    echo "Transmission UDP"
    firewall-cmd --permanent --add-port=51413/udp
    echo "Transmission Combustion"
    firewall-cmd --permanent --add-port=9091/tcp
    echo "Portainer"
    firewall-cmd --permanent --add-port=8000/tcp
    echo "Portainer GUI"
    firewall-cmd --permanent --add-port=9443/tcp
    echo "Reloading firewall"
    firewall-cmd --reload
fi

echo ""
echo "Done"
