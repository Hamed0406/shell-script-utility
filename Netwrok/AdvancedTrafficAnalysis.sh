#!/bin/bash

# Advanced Script to analyze network traffic from a tcpdump capture file

echo "TCPDump Advanced Capture Analysis Tool"
echo "--------------------------------------"

# Ask for the capture file path
read -p "Enter the path to the capture file: " captureFilePath

# Verify the capture file exists
if [ ! -f "$captureFilePath" ]; then
    echo "File does not exist: $captureFilePath"
    exit 1
fi

# Function to display analysis options
showMenu() {
    echo "Select analysis option:"
    echo "1) View top source IPs"
    echo "2) View top destination IPs"
    echo "3) List all DNS queries"
    echo "4) Extract HTTP requests"
    echo "5) Filter by protocol (TCP/UDP/ICMP)"
    echo "6) Summarize packet sizes"
    echo "7) Analyze traffic within a specific time frame"
    echo "8) Quit"
}

# Analyze traffic within a specific time frame
analyzeTimeFrame() {
    read -p "Enter start time (HH:MM:SS): " startTime
    read -p "Enter end time (HH:MM:SS): " endTime
    echo "Traffic between $startTime and $endTime:"
    tcpdump -r "$captureFilePath" -tttt | grep -E "$startTime|$endTime" | less
}

# Main menu loop
while true; do
    showMenu
    read -p "Option: " option

    case $option in
        1)
            echo "Top Source IPs:"
            tcpdump -nn -r "$captureFilePath" ip | awk '{print $3}' | sort | uniq -c | sort -nr | head
            ;;
        2)
            echo "Top Destination IPs:"
            tcpdump -nn -r "$captureFilePath" ip | awk '{print $5}' | cut -d '.' -f 1-4 | sort | uniq -c | sort -nr | head
            ;;
        3)
            echo "DNS Queries:"
            tcpdump -nn -r "$captureFilePath" port 53 | grep "A?"
            ;;
        4)
            echo "HTTP Requests:"
            tcpdump -A -r "$captureFilePath" port 80 | grep "GET\|POST\|PUT\|DELETE\|HEAD"
            ;;
        5)
            read -p "Enter protocol (TCP/UDP/ICMP): " protocol
            echo "Filtering by $protocol protocol:"
            tcpdump -nn -r "$captureFilePath" $protocol | less
            ;;
        6)
            echo "Packet Size Summary:"
            tcpdump -r "$captureFilePath" | awk '{print $NF}' | sort -n | uniq -c | less
            ;;
        7)
            analyzeTimeFrame
            ;;
        8)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid option: $option"
            ;;
    esac
done

