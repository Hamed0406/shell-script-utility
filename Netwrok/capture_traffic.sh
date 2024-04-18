#!/bin/bash

# Script to list all network interfaces, then capture traffic on a selected interface.

echo "Listing all network interfaces:"
echo "-------------------------------------------------"

# List all network interfaces (excluding loopback)
for interface in $(ip -o link show | awk -F': ' '{print $2}' | grep -v lo); do
    echo "Interface: $interface"
    status=$(ip -o link show $interface | awk '{print $9}')
    echo "Status: $status"
    ipAddress=$(ip -o -f inet addr show $interface | awk '{print $4}')
    if [ -z "$ipAddress" ]; then
        echo "IP Address: None"
    else
        echo "IP Address: $ipAddress"
    fi
    echo "-------------------------------------------------"
done

# Ask the user to specify the interface for traffic capture
read -p "Enter the interface you want to capture traffic on: " captureInterface

# Check if the user entered a valid interface
if ! ip link show "$captureInterface" > /dev/null 2>&1; then
    echo "Invalid interface: $captureInterface. Exiting."
    exit 1
fi

# Define the directory where you want to save the capture file
CAPTURE_DIR="/home/ikm126@tcad.telia.se/scripts/logs/tcpdump"
mkdir -p "${CAPTURE_DIR}"

# Define the capture file name
FILENAME="capture_$(date +%Y-%m-%d_%H-%M-%S).pcap"
FULL_PATH="${CAPTURE_DIR}/${FILENAME}"

# Capture packet size. Default is 96 bytes. 0 captures the entire packet
SNAPLEN=0

# Number of packets to capture before stopping.
PACKET_COUNT=1000

# Start capture
echo "Starting capture on interface: $captureInterface. Output file: $FULL_PATH"
sudo tcpdump -i "$captureInterface" -s "$SNAPLEN" -c "$PACKET_COUNT" -w "$FULL_PATH" -vv

echo "Capture complete. File saved to: $FULL_PATH"

