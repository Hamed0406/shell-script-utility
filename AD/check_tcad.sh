#!/bin/bash

# Prompt the user to enter the username
read -p "Enter the username: " username

# Get the user ID for the specified username
uid=$(id -u "$username")

# Get the primary group of the user
primary_group=$(id -gn "$username")

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
groups=$(id -Gn "$username" | tr ' ' '\n')
group_count=0
for group in $groups; do
    printf "%s\n" "$group"
    ((group_count++))
done

# Display the total number of groups the user is a member of
echo "---------------------"
echo "Total Groups: $group_count"
echo "---------------------"

