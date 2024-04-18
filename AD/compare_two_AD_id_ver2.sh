#!/bin/bash

# Function to get and display user details
get_user_details() {
    local username=$1

    # Extracting user information
    local user_info=$(getent passwd "$username")
    local user_id=$(echo "$user_info" | cut -d: -f3)
    local group_id=$(echo "$user_info" | cut -d: -f4)
    local home_dir=$(echo "$user_info" | cut -d: -f6)
    local shell=$(echo "$user_info" | cut -d: -f7)
    local groups=$(id -Gn "$username")
    local group_count=$(echo "$groups" | wc -w)

    # Displaying user information
    echo "================================================"
    echo "User Details for: $username"
    echo "================================================"
    printf "User ID: %s\nGroup ID: %s\nHome Directory: %s\nShell: %s\n" "$user_id" "$group_id" "$home_dir" "$shell"
    printf "Total Groups: %s\n" "$group_count"
    echo "Groups: $groups"
    echo "================================================"
}

# Function to display disk usage for the user's home directory
get_disk_usage() {
    local home_dir=$1
    local username=$2

    # Calculating and displaying disk usage
    local disk_usage=$(du -sh "$home_dir" 2>/dev/null | cut -f1)
    echo "Disk Usage for $username's Home: $disk_usage"
    echo "================================================"
}

# Function to initiate user comparison process
compare_users() {
    local username1=$1
    local username2=$2

    echo "Gathering details for $username1..."
    echo ""
    get_user_details "$username1"
    local home_dir1=$(getent passwd "$username1" | cut -d: -f6)
    get_disk_usage "$home_dir1" "$username1"

    echo ""

    echo "Gathering details for $username2..."
    echo ""
    get_user_details "$username2"
    local home_dir2=$(getent passwd "$username2" | cut -d: -f6)
    get_disk_usage "$home_dir2" "$username2"
}

# Main script starts here
read -p "Enter the first username: " username1
read -p "Enter the second username: " username2

compare_users "$username1" "$username2"

