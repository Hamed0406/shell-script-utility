#!/bin/bash

# Comprehensive Script for Network Traffic Capture
# Features: Interface selection, capture duration, filtering options, and custom save location

echo "Comprehensive Network Traffic Capture Tool"
echo "------------------------------------------"

# List and select network interface
selectInterface() {
    echo "Available network interfaces:"
    ip -o link show | awk -F': ' '{print $2}' | grep -v lo
    echo "-------------------------------------"
    read -p "Enter the interface you want to capture traffic on: " INTERFACE
}

# Set capture duration
setDuration() {
    read -p "Enter the capture duration in seconds (default is 300 seconds): " DURATION
    if ! [[ $DURATION =~ ^[0-9]+$ ]]; then
        echo "Invalid input, using default duration: 300 seconds."
        DURATION=300
    fi
}

# Set the output directory and file name
setOutputLocation() {
    read -p "Enter the directory where you want to save the capture file: " CAPTURE_DIR
    mkdir -p "${CAPTURE_DIR}" 2>/dev/null
    
    if [ $? -ne 0 ]; then
        echo "Unable to create or access specified directory. Using default /var/log/tcpdump."
        CAPTURE_DIR="/home/ikm126@tcad.telia.se/scripts/logs/tcpdump"
        mkdir -p "${CAPTURE_DIR}"
    fi
    
    read -p "Enter the filename for the capture file: " FILENAME
    if [ -z "${FILENAME}" ]; then
        echo "No filename entered, using default name."
        FILENAME="capture_$(date +%Y-%m-%d_%H-%M-%S).pcap"
    fi
    
    FULL_PATH="${CAPTURE_DIR}/${FILENAME}"
    echo "Capture will be saved to: ${FULL_PATH}"
}

# Show available filters and set capture filter
setFilter() {
    echo "Select a filter option:"
    echo "1) ICMP traffic"
    echo "2) TCP traffic"
    echo "3) UDP traffic"
    echo "4) Specific IP address traffic"
    echo "5) Custom tcpdump filter"
    echo "6) No filter (capture all traffic)"
    read -p "Your choice: " filter_choice
    
    case $filter_choice in
        1) CAPTURE_FILTER="icmp";;
        2) CAPTURE_FILTER="tcp";;
        3) CAPTURE_FILTER="udp";;
        4)
            read -p "Enter the IP address: " ip_address
            echo "Select traffic direction for IP $ip_address:"
            echo "1) Incoming to the IP"
            echo "2) Outgoing from the IP"
            echo "3) All traffic to and from the IP"
            read -p "Direction option: " direction_option
            case $direction_option in
                1) CAPTURE_FILTER="dst host $ip_address";;
                2) CAPTURE_FILTER="src host $ip_address";;
                3) CAPTURE_FILTER="host $ip_address";;
                *) echo "Invalid direction option, capturing all traffic to and from $ip_address."
                   CAPTURE_FILTER="host $ip_address";;
            esac;;
        5) 
            read -p "Enter your custom tcpdump filter: " custom_filter
            CAPTURE_FILTER="$custom_filter";;
        6) CAPTURE_FILTER="";;
        *) 
            echo "Invalid option. Capturing all traffic."
            CAPTURE_FILTER="";;
    esac
}

# Start the capture
startCapture() {
    echo "Starting capture on interface $INTERFACE with filter '$CAPTURE_FILTER'."
    sudo timeout --signal=SIGINT "${DURATION}"s tcpdump -i "$INTERFACE" -w "$FULL_PATH" -vv ${CAPTURE_FILTER:+-f "$CAPTURE_FILTER"}
    echo "Capture complete. File saved to: $FULL_PATH"
}

# Main flow
selectInterface
setDuration
setOutputLocation
setFilter
startCapture

