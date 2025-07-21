
#!/bin/bash

###############################################################################
# Script: setup_rdp_secure.sh
# Description: Installs GNOME GUI, XRDP, sets up RDP access,
#              configures fail2ban, and enables UFW firewall.
#
# Author: hamed0406
# Date: 2025-07-21
#
# Usage:
#   chmod +x setup_rdp_secure.sh
#   ./setup_rdp_secure.sh
#
# Notes:
# - Make sure your Azure NSG allows port 3389 **only** from your IP.
# - Tested on Ubuntu 20.04 / 22.04 VM in Azure.
###############################################################################

# Exit on errors
set -e

echo "==> Updating packages..."
sudo apt update && sudo apt upgrade -y

echo "==> Installing GNOME desktop (ubuntu-desktop)..."
sudo apt install ubuntu-desktop -y

echo "==> Installing XRDP..."
sudo apt install xrdp -y
sudo systemctl enable xrdp
sudo systemctl start xrdp

echo "==> Configuring XRDP to use GNOME..."
echo "gnome-session" > ~/.xsession
sudo systemctl restart xrdp

echo "==> Installing and configuring fail2ban..."
sudo apt install fail2ban -y

# Configure fail2ban for XRDP
cat <<EOF | sudo tee /etc/fail2ban/jail.d/xrdp.conf
[xrdp-sesman]
enabled = true
port    = 3389
filter  = xrdp-sesman
logpath = /var/log/xrdp-sesman.log
maxretry = 3
bantime = 1h
findtime = 10m
EOF

# Filter file for XRDP
cat <<EOF | sudo tee /etc/fail2ban/filter.d/xrdp-sesman.conf
[Definition]
failregex = .*login failed for user.*
EOF

sudo systemctl restart fail2ban

echo "==> Configuring UFW firewall..."
sudo ufw allow OpenSSH
sudo ufw allow 3389/tcp
sudo ufw --force enable

echo "==> DONE. XRDP is running with GNOME, and security is applied."

# Optional: Ask user if they want to disable XRDP until needed
read -p "Do you want to disable XRDP now (until needed)? (y/n): " choice
if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
    sudo systemctl stop xrdp
    sudo systemctl disable xrdp
    echo "XRDP service stopped and disabled. You can start it later with:"
    echo "  sudo systemctl start xrdp && sudo systemctl enable xrdp"
else
    echo "XRDP is left enabled and running."
fi

echo "==> IMPORTANT: Make sure Azure NSG allows port 3389 ONLY from your IP!"

