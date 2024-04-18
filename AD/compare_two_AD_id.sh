#!/bin/bash

# Function to get groups for a user
function get_user_groups() {
    local username=$1
    echo $(id -Gn "$username")
}

# Function to display user information and group count
function display_user_info() {
    local username=$1
    local groups=($2) # Convert group list string to array
    local group_count=${#groups[@]}

    # Get the user ID for the specified username
    local uid=$(id -u "$username")

    # Get the primary group of the user
    local primary_group=$(id -gn "$username")

    # Display the user ID and primary group in a table-like format
    echo "--------------------------------------------"
    echo "User Information for $username"
    echo "--------------------------------------------"
    echo "| Username  | User ID | Primary Group |"
    echo "--------------------------------------------"
    printf "| %-10s| %-8s| %-13s|\n" "$username" "$uid" "$primary_group"
    echo "--------------------------------------------"
    
    # Display the supplementary groups the user is a member of
    echo "Supplementary Groups:"
    echo "---------------------"
    for group in "${groups[@]}"; do
        printf "%s\n" "$group"
    done

    # Display the total number of groups the user is a member of
    echo "---------------------"
    echo "Total Groups: $group_count"
    echo "---------------------"
}

# Function to compare and display unique groups
function compare_groups() {
    local groups1=($1)
    local groups2=($2)
    local username1=$3
    local username2=$4

    echo "Unique Groups for $username1:"
    echo "-----------------------------"
    for group in "${groups1[@]}"; do
        if [[ ! " ${groups2[*]} " =~ " $group " ]]; then
            echo "$group"
        fi
    done

    echo "-----------------------------"
    echo "Unique Groups for $username2:"
    echo "-----------------------------"
    for group in "${groups2[@]}"; do
        if [[ ! " ${groups1[*]} " =~ " $group " ]]; then
            echo "$group"
        fi
    done
}

# Prompt the user to enter two usernames
read -p "Enter the first username: " username1
read -p "Enter the second username: " username2

# Get the group lists for both users
groups1=$(get_user_groups "$username1")
groups2=$(get_user_groups "$username2")

# Display user information and group count
display_user_info "$username1" "$groups1"
display_user_info "$username2" "$groups2"

# Compare the group lists and display unique groups
compare_groups "$groups1" "$groups2" "$username1" "$username2"

