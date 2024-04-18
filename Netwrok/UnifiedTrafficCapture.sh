#!/bin/bash

# Unified Script to capture network traffic with flexible filter options, including IP-specific traffic

echo "Unified Network Traffic Capture Tool"
echo "------------------------------------"

# Function to list and select network interface
selectInterface() {
    echo "Available network interfaces:"
    ip -o link show | awk -F': ' '{print $2}' | grep -v lo
    echo "-------------------------------------"
    read -p "Enter the interface you want to capture traffic on: " INTERFACE
}

# Define default capture duration in seconds (e.g., 300 seconds = 5 minutes)
DURATION=300

# Define default capture file directory and name
CAPTURE_DIR="/var/log/tcpdump"
mkdir -p "${CAPTURE_DIR}"
FILENAME="unified_capture_$(date +%Y-%m-%d_%H-%M-%S).pcap"
FULL_PATH="${CAPTURE_DIR}/${FILENAME}"

# Function to show available filters and set capture filter
setFilter() {
    echo "Available Filters:"
    echo "1) ICMP traffic"
    echo "2) TCP traffic"
    echo "3) UDP traffic"
    echo "4) Traffic for a specific IP address"
    echo "5) Custom filter (you will enter a custom tcpdump filter)"
    echo "6) No filter (capture all traffic)"
    read -p "Select a filter option: " filter_option
    
    if [ "$filter_option" -eq 4 ]; then
        read -p "Enter the IP address to capture traffic for: " IP_ADDRESS
        echo "Select traffic direction for IP $IP_ADDRESS:"
        echo "1) Incoming to the IP"
        echo "2) Outgoing from the IP"
        echo "3) All traffic to and from the IP"
        read -p "Direction option: " direction_option
        case $direction_option in
            1) CAPTURE_FILTER="dst $IP_ADDRESS";;
            2) CAPTURE_FILTER="src $IP_ADDRESS";;
            3) CAPTURE_FILTER="host $IP_ADDRESS";;
            *) echo "Invalid direction option selected, capturing all traffic to and from $IP_ADDRESS by default."
               CAPTURE_FILTER="host $IP_ADDRESS";;
        esac
    elif [ "$filter_option" -eq 5 ]; then
        read -p "Enter your custom tcpdump filter: " CAPTURE_FILTER
    elif [ "$filter_option" -eq 1 ]; then
        CAPTURE_FILTER="icmp"
    elif [ "$filter_option" -eq 2 ]; then
        CAPTURE_FILTER="tcp"
    elif [ "$filter_option" -eq 3 ]; then
        CAPTURE_FILTER="udp"
    else
        CAPTURE_FILTER=""
    fi
}

# Function to set capture duration
setDuration() {
    read -p "Enter the capture duration in seconds (default is 300 seconds): " input_duration
    if [[ $input_duration =~ ^[0-9]+$ ]]; then
        DURATION=$input_duration
    else
        echo "Using default duration: 300 seconds."
    fi
}

# Function to start capture
startCapture() {
    echo "Starting capture on interface $INTERFACE..."
    echo "Capture filter: $CAPTURE_FILTER"
    sudo timeout --signal=SIGINT "${DURATION}" tcpdump -i "$INTERFACE" -w "${FULL_PATH}" -vv ${CAPTURE_FILTER:+-f "$CAPTURE_FILTER"}
    echo "Capture complete. File saved to: ${FULL_PATH}"
}

# Main script flow

selectInterface    # Select network interface
setDuration        # Set capture duration
setFilter          # Set capture filter based on user input
startCapture       # Start the capture process based on selected options

