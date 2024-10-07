#!/bin/bash

# Environment Variables
TELEGRAM_API_KEY=${TELEGRAM_API_KEY}
CHAT_ID=${CHAT_ID}
URLS=${URLS}
CHECK_INTERVAL=${CHECK_INTERVAL:-3}    # Default to 3 minutes if not set
TIMEOUT_MINUTES=${TIMEOUT:-2}          # Default timeout of 2 minutes if not set
MAX_DOWN_COUNT=${MAX_DOWN_COUNT:-2}     # Default to 2 if not set

# Convert timeout from minutes to seconds
TIMEOUT=$((TIMEOUT_MINUTES * 60))

# Convert the comma-separated URLs into an array
IFS=',' read -r -a url_array <<< "$URLS"

# Initialize an associative array to keep track of down counts and down timestamps
declare -A down_count
declare -A down_start_time

# Function to send notification to Telegram (without message preview)
send_telegram_notification() {
    local message=$1
    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_API_KEY}/sendMessage" \
    -d "chat_id=${CHAT_ID}" \
    -d "text=${message}" \
    -d "disable_web_page_preview=true"  # Disable web page preview in Telegram message
}

# Function to check if a website is up or down
check_website() {
    local url=$1
    local current_time
    current_time=$(date +"%Y-%m-%d %H:%M:%S")  # Get current date and time

    # Check the HTTP status code with a timeout
    http_response=$(curl -s --connect-timeout "$TIMEOUT" --max-time "$TIMEOUT" -o /dev/null -w "%{http_code}" "$url")

    # Determine if the status code indicates success (1xx, 2xx, or 3xx)
    if [[ "$http_response" =~ ^(1|2|3)[0-9]{2}$ ]]; then
        # HTTP success
        echo "$current_time - $url is up (HTTP status: $http_response)"
        # Reset down count for this URL
        down_count["$url"]=0
    else
        # HTTP failure (4xx, 5xx, or 000)
        echo "$current_time - $url is down (HTTP status: $http_response)"

        # Check if this is the first time the website is down
        if [ -z "${down_start_time["$url"]}" ]; then
            # Set the down start time for this URL (store as Unix timestamp)
            down_start_time["$url"]=$(date +%s)
        fi

        # Increment the down count for this URL
        down_count["$url"]=$((down_count["$url"] + 1))

        # If the down count exceeds MAX_DOWN_COUNT, send a notification
        if [ ${down_count["$url"]} -gt "$MAX_DOWN_COUNT" ]; then
            # Calculate how long the site has been down
            down_duration=$(( $(date +%s) - down_start_time["$url"] ))  # Duration in seconds
            down_duration_human=$(date -u -d @${down_duration} +"%H:%M:%S")  # Format as HH:MM:SS

            # Convert down_start_time back to a human-readable format
            down_start_time_human=$(date -d @${down_start_time["$url"]} +"%Y-%m-%d %H:%M:%S")

            # Send a notification with the down duration and human-readable down start time
            message="$url is down since $down_start_time_human (down for $down_duration_human)"
            send_telegram_notification "$message"
        fi
    fi
}

# Main loop: check websites at regular intervals
while true; do
    for url in "${url_array[@]}"; do
        check_website "$url"
    done
    sleep "$((CHECK_INTERVAL * 60))" # Check every X minutes
done
