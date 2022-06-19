#!/bin/bash
# Check if root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
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

if [ -f ./.env ]; then
    touch /root/.env
else
    rm /root/.env
    touch /root/.env
fi

# NFS Setup
echo ""
echo "Are you using NFS shares? [y/n]:"
read NFSStatus

if [ "$NFSStatus" == "y" ]; then
    echo "Installing NFS Utils"
    dnf install nfs-utils -y
    echo ""
    echo "Enter NFS share for Movies: [e.g. 'nfshost:/nfs/share']"
    read NFSMovies
    echo "Enter Movies mount point: [e.g. '/media/movies']"
    read PlexMovies
    echo "PLEXMOVIES:$PlexMovies" >> /root/.env
    echo "Enter NFS share for Music: [e.g. 'nfshost:/nfs/share']"
    read NFSMusic
    echo "Enter Music mount point: [e.g. '/media/music]'"
    read PlexMusic
    echo "PLEXMUSIC:$PlexMusic" >> /root/.env
    echo "Enter NFS share for TV Shows: [e.g. 'nfshost:/nfs/share']"
    read NFSTVShows
    echo "Enter TV Shows mount point: [e.g. '/media/tvshows']"
    read PlexTVShows
    echo "PLEXTVSHOWS:$PlexTVShows" >> /root/.env
    echo "Enter NFS share for Videos: [e.g. 'nfshost:/nfs/share']"
    read NFSVideos
    echo "Enter Videos mount point: [e.g. '/media/videos']"
    read PlexVideos
    echo "PLEXVIDEOS:$PlexVideos" >> /root/.env
    echo "$NFSMovies	$PlexMovies	nfs	defaults	0	0" >> /etc/fstab
    echo "$NFSMusic	$PlexMusic	nfs	defaults	0	0" >> /etc/fstab
    echo "$NFSTVShows	$PlexTVShows	nfs	defaults	0	0" >> /etc/fstab
    echo "$NFSVideos 	$PlexVideos	nfs	defaults	0	0" >> /etc/fstab
fi

if [ "$NFSStatus" == "n" ]; then
    echo "Enter the path for Movies: [e.g. '/media/movies']"
    read PlexMovies
    echo "PLEXMOVIES:$PlexMovies" >> /root/.env
    echo "Enter the path for Music: [e.g. '/media/music']"
    read PlexMusic
    echo "PLEXMUSIC:$PlexMusic" >> /root/.env
    echo "Enter the path for TV Shows: [e.g. '/media/tvshows']"
    read PlexTVShows
    echo "PLEXTVSHOWS:$PlexTVShows" >> /root/.env
    echo "Enter the path for Videos: [e.g. '/media/videos']"
    read PlexVideos
    echo "PLEXVIDEOS:$PlexVideos" >> /root/.env
fi

# Get Plex info
echo ""
echo "Navigate to https://www.plex.tv/claim/"
echo "Enter the Plex Claim Ticket:"
read PlexClaim
echo "PLEXCLAIM:$PlexClaim" >> /root/.env
echo "Enter the Hostname for Plex: [e.g. 'plex.example.org']"
read PlexHostname
echo "PLEXHOSTNAME:$PlexHostname" >> /root/.env
echo "Enter the path for Plex files: [e.g. '/media/plex']"
read PlexLocation
echo "PLEXLOCATION:$PlexLocation" >> /root/.env
echo "Enter your timezone: [e.g. 'America/New_York']"
read TimeZone
echo "TIMEZONE:$TimeZone" >> /root/.env

# Services compose
echo ""
echo "Start docker compose"
wget "https://raw.githubusercontent.com/UltimateNova1203/docker-repo/main/docker-media.yml" -o /root/docker-media.yml
docker compose -f /root/docker-media.yml up -d
rm /root/docker-media.yml
rm /root/.env

# Firewall rules
echo ""
echo "Are you using a firewall? [y/n]:"
read FirewallStatus

if [ "$FirewallStatus" == "y" ]; then
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
fi

echo ""
echo "Done"
