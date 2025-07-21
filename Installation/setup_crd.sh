#!/bin/bash

################################################################################
# Chrome Remote Desktop Setup Script for Ubuntu (GNOME)
#
# Author: hamed0406
# Date: July 21, 2025
#
# Description:
#   This script installs and configures Chrome Remote Desktop (CRD)
#   on an Ubuntu system using the default GNOME desktop environment.
#
# Features:
#   ✅ Installs Google Chrome browser
#   ✅ Installs Chrome Remote Desktop (CRD)
#   ✅ Configures GNOME as the CRD desktop session
#   ✅ Adds the current user to the required group
#   ✅ Enables CRD to auto-start on boot
#   ✅ Safe: prevents running as root
#
# Usage:
#   1. Save this file as setup_crd.sh
#   2. Run: chmod +x setup_crd.sh
#   3. Then: ./setup_crd.sh (DO NOT use sudo)
#   4. After setup, go to: https://remotedesktop.google.com/access
################################################################################

# ❌ Prevent running as root
if [ "$EUID" -eq 0 ]; then
  echo "❌ Do NOT run this script with sudo or as root."
  echo "   Just run it as your normal user: ./setup_crd.sh"
  exit 1
fi

set -e

# Variables
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

echo "🖥️ Setting GNOME as the CRD session..."
echo "exec /usr/bin/gnome-session" > ~/.chrome-remote-desktop-session

echo "👥 Ensuring 'chrome-remote-desktop' group exists..."
if ! getent group chrome-remote-desktop > /dev/null; then
  echo "  → Group not found. Creating it..."
  sudo groupadd chrome-remote-desktop
else
  echo "  → Group already exists."
fi

echo "👤 Adding user '$USER' to the group..."
sudo usermod -a -G chrome-remote-desktop "$USER"

echo "🔁 Enabling CRD auto-start for $USER..."
sudo systemctl enable chrome-remote-desktop@"$USER"

echo -e "\n✅ Setup complete!"
echo "🔐 Final step: open this link in Google Chrome:"
echo "👉 https://remotedesktop.google.com/access"
echo "➡️  Click 'Set up remote access', name your device, and set a PIN."
echo "🔄 Please log out and log back in (or reboot) to apply group changes."

