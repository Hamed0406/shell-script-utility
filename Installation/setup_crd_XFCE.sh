#!/bin/bash

################################################################################
# Chrome Remote Desktop Setup Script (XFCE for Azure/VM Environments)
#
# Author: hamed0406
# Date: July 21, 2025
#
# Description:
#   This script sets up Chrome Remote Desktop (CRD) with XFCE on Ubuntu.
#   It's optimized for headless or cloud-based VMs (like Azure).
#
# Features:
#   ✅ Installs Google Chrome
#   ✅ Installs Chrome Remote Desktop
#   ✅ Installs XFCE desktop environment
#   ✅ Configures XFCE as the CRD session
#   ✅ Adds user to CRD group and enables auto-start
#   ✅ Prevents root misuse
#
# Usage:
#   chmod +x setup_crd.sh
#   ./setup_crd.sh   # Do NOT run with sudo
#   Then visit: https://remotedesktop.google.com/access to finish setup
################################################################################

# ❌ Prevent running as root
if [ "$EUID" -eq 0 ]; then
  echo "❌ Do NOT run this script with sudo or as root."
  echo "   Just run it as your normal user: ./setup_crd.sh"
  exit 1
fi

set -e

# File names
CRD_DEB="chrome-remote-desktop_current_amd64.deb"
CHROME_DEB="google-chrome-stable_current_amd64.deb"

echo "📦 Installing Google Chrome..."
wget -q https://dl.google.com/linux/direct/$CHROME_DEB
sudo apt install -y ./$CHROME_DEB
rm $CHROME_DEB

echo "📦 Installing Chrome Remote Desktop..."
wget -q https://dl.google.com/linux/direct/$CRD_DEB
sudo apt install -y ./$CRD_DEB
rm $CRD_DEB

echo "🖼️ Installing XFCE desktop environment..."
sudo DEBIAN_FRONTEND=noninteractive apt install -y xfce4 desktop-base xscreensaver

echo "⚙️ Setting XFCE as the CRD session..."
echo "exec /usr/bin/xfce4-session" > ~/.chrome-remote-desktop-session

echo "👥 Ensuring 'chrome-remote-desktop' group exists..."
if ! getent group chrome-remote-desktop > /dev/null; then
  echo "  → Group not found. Creating it..."
  sudo groupadd chrome-remote-desktop
else
  echo "  → Group already exists."
fi

echo "👤 Adding user '$USER' to chrome-remote-desktop group..."
sudo usermod -a -G chrome-remote-desktop "$USER"

echo "🔁 Enabling CRD auto-start for $USER..."
sudo systemctl enable chrome-remote-desktop@"$USER"

echo -e "\n✅ Setup complete!"
echo "🔐 Final step: open this link in Google Chrome:"
echo "👉 https://remotedesktop.google.com/access"
echo "➡️  Click 'Set up remote access', name your device, and set a PIN."
echo "🔄 Please log out and log back in (or reboot) to apply group changes."

