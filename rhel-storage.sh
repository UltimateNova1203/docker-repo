#!/bin/bash
# Docker setup
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

# Firewall rules
echo "Enabling firewall rules"
echo "Samba"
firewall-cmd --permanent --add-port=445/tcp
echo "Avahi"
firewall-cmd --permanent --add-port=5353/udp
echo "Portainer"
firewall-cmd --permanent --add-port=8000/tcp
echo "Portainer GUI"
firewall-cmd --permanent --add-port=9443/tcp
echo "Reloading firewall"
firewall-cmd --reload
