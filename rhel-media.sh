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

# NFS Setup
echo ""
echo "Are you using NFS shares? [y/n]:"
read NFSStatus

if (${NFSStatus} == "y")
    echo "Enter NFS share for Movies:"
    read NFSMovies
    echo "Enter Movies mount point:"
    read PlexMovies
    echo "Enter NFS share for Music:"
    read NFSMusic
    echo "Enter Music mount point:"
    read PlexMusic
    echo "Enter NFS share for TV Shows:"
    read NFSTVShows
    echo "Enter TV Shows mount point:"
    read PlexTVShows
    echo "Enter NFS share for Videos:"
    read NFSVideos
    echo "Enter Videos mount point:"
    read PlexVideos
    echo "${NFSMovies}	${PlexMovies}  nfs defaults 0 0" >> /etc/fstab
    echo "${NFSMusic}   ${PlexMusic}   nfs defaults 0 0" >> /etc/fstab
    echo "${NFSTVShows} ${PlexTVShows} nfs defaults 0 0" >> /etc/fstab
    echo "${NFSVideos}  ${PlexVideos}  nfs defaults 0 0" >> /etc/fstab
fi

if (${NFSStatus} == "n")
    echo "Enter the path for Movies:"
    read PlexMovies
    echo "Enter the path for Music:"
    read PlexMusic
    echo "Enter the path for TV Shows:"
    read PlexTVShows
    echo "Enter the path for Videos:"
    read PlexVideos
fi

# Get Plex info
echo ""
echo "Navigate to https://www.plex.tv/claim/"
echo "Enter the Plex Claim Ticket"
read PlexClaim

# Services compose
echo ""
echo "Start docker compose"
wget "https://raw.githubusercontent.com/UltimateNova1203/docker-repo/main/docker-media.yml"
docker compose -f docker-media.yml up -d

# Firewall rules
echo ""
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
