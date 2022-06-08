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

# Services compose
docker compose -f rhel-media.yml up -d

# Firewall rules
echo "Enabling firewall rules"
echo "Plex GUI"
firewall-cmd --permanent --add-port=32400/tcp
echo "Plex Companion for Home Theater"
firewall-cmd --permanent --add-port=3005/tcp
echo "Plex Companion for Roku"
firewall-cmd --permanent --add-port=8324/tcp
echo "Plex DLNA Server"
firewall-cmd --permanent --add-port=32469/tcp
echo "Plex UPnP"
firewall-cmd --permanent --add-port=1900/udp
echo "Plex GDM Discovery 0"
firewall-cmd --permanent --add-port=32410/udp
echo "Plex GDM Discovery 1"
firewall-cmd --permanent --add-port=32411/udp
echo "Plex GDM Discovery 2"
firewall-cmd --permanent --add-port=32412/udp
echo "Plex GDM Discovery 3"
firewall-cmd --permanent --add-port=32413/udp
echo "Plex GDM Discovery 4"
firewall-cmd --permanent --add-port=32414/udp
echo "Portainer"
firewall-cmd --permanent --add-port=8000/tcp
echo "Portainer GUI"
firewall-cmd --permanent --add-port=9443/tcp
echo "Reloading firewall"
firewall-cmd --reload
