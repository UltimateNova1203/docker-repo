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

# Heimdall setup
echo ""
echo "Enter the path for Heimdall files: [e.g. '/media/heimdall']"
read Folder
echo "FOLDER:$Folder" >> /root/.env

# Services compose
echo ""
echo "Start docker compose"
wget -P /root "https://raw.githubusercontent.com/UltimateNova1203/docker-repo/main/docker-heimdall.yml"
docker compose -f /root/docker-heimdall.yml up -d
rm /root/docker-heimdall.yml
rm /root/.env

# Firewall rules
echo ""
echo "Are you using a firewall? [y/n]:"
read FirewallStatus

if [ "$FirewallStatus" == "y" ]; then
    echo ""
    echo "Enabling firewall rules"
    echo "Heimdall HTTP"
    firewall-cmd --permanent --add-port=80/tcp
    echo "Heimdall HTTPS"
    firewall-cmd --permanent --add-port=443/tcp
    echo "Portainer"
    firewall-cmd --permanent --add-port=8000/tcp
    echo "Portainer GUI"
    firewall-cmd --permanent --add-port=9443/tcp
    echo "Reloading firewall"
    firewall-cmd --reload
fi

echo ""
echo "Done"
