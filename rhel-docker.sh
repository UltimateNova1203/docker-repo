#!/bin/bash
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
