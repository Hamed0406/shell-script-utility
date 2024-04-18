#!/bin/bash

# The path to the directory containing log files.
LOG_DIR="$1"

# The specific string or event we're looking for.
SEARCH_TERM="$2"

# Check if the directory exists
if [ ! -d "$LOG_DIR" ]; then
    echo "The specified directory does not exist: $LOG_DIR"
    exit 1
fi

# Find all log files under the specified directory
find "$LOG_DIR" -type f | while read -r file; do
    echo "Analyzing file: $file"
    
    # Count occurrences of the search term in the current file
    COUNT=$(grep -o "$SEARCH_TERM" "$file" | wc -l)
    if [ "$COUNT" -gt 0 ]; then
        echo "Found $COUNT occurrences of \"$SEARCH_TERM\" in $file"
        
        # Find the first and last occurrence with timestamps if available
        FIRST=$(grep "$SEARCH_TERM" "$file" | head -1)
        LAST=$(grep "$SEARCH_TERM" "$file" | tail -1)

        echo "First occurrence: $FIRST"
        echo "Last occurrence: $LAST"
    else
        echo "No occurrences found in $file."
    fi
done

