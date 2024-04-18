#!/bin/bash

# Script to display status and details of all network interfaces

echo "Listing all network interfaces and their details:"

# Loop through all available network interfaces (excluding loopback)
for interface in $(ip -o link show | awk -F': ' '{print $2}' | grep -v lo); do
    echo "-------------------------------------------------"
    echo "Interface: $interface"

    # Check if the interface is up or down
    status=$(ip -o link show $interface | awk '{print $9}')
    echo "Status: $status"

    # Retrieve and display the IP address assigned to the interface, if any
    ipAddress=$(ip -o -f inet addr show $interface | awk '{print $4}')
    if [ -z "$ipAddress" ]; then
        echo "IP Address: None"
    else
        echo "IP Address: $ipAddress"
    fi

    # Additional details can be added here as needed
done

echo "-------------------------------------------------"
echo "Network interfaces listing complete."

