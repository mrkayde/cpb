#!/bin/bash

# Script to install TP-Link Omada Controller with dependencies
# Based on: https://gist.github.com/OSCUK/3c76ccabe78b6d3ce479c6d885b9c065
# Updated for Ubuntu 22.04 compatibility

set -e  # Exit on error

# Function to display messages
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    log "This script must be run as root. Please use sudo."
    exit 1
fi

log "Starting Omada Controller installation..."

# Update package lists and install initial dependencies
log "Updating package lists and installing initial dependencies..."
apt update
apt install -y openssh-server openjdk-8-jre-headless jsvc curl gnupg2 wget

# Install libssl1.1 (required for MongoDB on Ubuntu 22.04)
log "Installing libssl1.1 from Ubuntu 20.04 repositories..."
cd /tmp
wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb
dpkg -i libssl1.1_1.1.1f-1ubuntu2_amd64.deb

# MongoDB installation
log "Setting up MongoDB..."

# Add MongoDB repository key in a non-deprecated way
wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | gpg --dearmor | tee /usr/share/keyrings/mongodb-org-4.4.gpg > /dev/null

# Add MongoDB repository for Ubuntu 20.04 (focal) as it's compatible with the MongoDB version we need
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-org-4.4.gpg ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.4.list

# Update package lists again and install MongoDB
log "Installing MongoDB 4.4..."
apt update
apt install -y mongodb-org

# Start and enable MongoDB service
log "Starting and enabling MongoDB service..."
systemctl start mongod.service
systemctl enable mongod

# Verify MongoDB is running
log "Checking MongoDB status..."
systemctl status mongod --no-pager

# Download and install Omada Controller
log "Downloading latest Omada Controller..."
OMADA_URL="https://static.tp-link.com/upload/software/2025/202501/20250109/Omada_SDN_Controller_v5.15.8.2_linux_x64.deb"
OMADA_DEB="/tmp/omada_controller.deb"

wget -O "$OMADA_DEB" "$OMADA_URL"

log "Installing Omada Controller..."
apt install -y "$OMADA_DEB"

# Check if installation was successful
if systemctl is-active --quiet omadac; then
    log "Omada Controller installed and running successfully!"
    log "You can access the controller at http://$(hostname -I | awk '{print $1}'):8088"
else
    log "Omada Controller installation completed, but service is not running."
    log "Please check logs at /opt/tplink/EAPController/logs/ for details."
fi


log "Installation process completed."
