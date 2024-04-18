#!/bin/bash

# Script to analyze network traffic from a tcpdump capture file

echo "TCPDump Capture Analysis Tool"
echo "----------------------------"

# Ask for the capture file path
read -p "Enter the path to the capture file: " captureFilePath

# Check if the file exists
if [ ! -f "$captureFilePath" ]; then
    echo "File does not exist: $captureFilePath"
    exit 1
fi

# Function to display menu options
showMenu() {
    echo "Select analysis option:"
    echo "1) View top source IPs"
    echo "2) View top destination IPs"
    echo "3) List all DNS queries"
    echo "4) Extract HTTP requests"
    echo "5) Quit"
}

# Main menu loop
while true; do
    showMenu
    read -p "Option: " option

    case $option in
        1) # Top source IPs
            echo "Top Source IPs:"
            tcpdump -nn -r "$captureFilePath" ip | awk '{print $3}' | sort | uniq -c | sort -nr | head
            ;;
        2) # Top destination IPs
            echo "Top Destination IPs:"
            tcpdump -nn -r "$captureFilePath" ip | awk '{print $5}' | cut -d '.' -f 1-4 | sort | uniq -c | sort -nr | head
            ;;
        3) # DNS queries
            echo "DNS Queries:"
            tcpdump -nn -r "$captureFilePath" port 53 | grep "A?" 
            ;;
        4) # HTTP requests
            echo "HTTP Requests:"
            tcpdump -A -r "$captureFilePath" port 80 | grep "GET\|POST\|PUT\|DELETE\|HEAD"
            ;;
        5) # Quit
            echo "Exiting..."
            exit 0
            ;;
        *) # Invalid option
            echo "Invalid option: $option"
            ;;
    esac
done

