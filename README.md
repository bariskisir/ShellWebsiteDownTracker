
# Website Down Tracker

Website Down Tracker is a simple Docker-based monitoring bot that checks the availability of specified URLs and sends notifications to a Telegram chat when a website is down.

## Features

- Monitors multiple URLs for HTTP status.
- Sends Telegram notifications for downtime.
- Configurable check intervals, timeouts, and failure thresholds.

## Requirements

- Docker
- A Telegram bot and chat ID

## Environment Variables

Set the following environment variables before running the Docker container:

- `TELEGRAM_API_KEY`: Your Telegram bot API key. [Create telegram bot with @BotFather](https://t.me/botfather)
- `CHAT_ID`: The chat ID for notifications. [Get your user id with @userinfobot](https://t.me/userinfobot)
- `URLS`: Comma-separated list of URLs to monitor (e.g., `http://example.com,http://example.org`).
- `CHECK_INTERVAL`: (Optional) Interval in minutes to check URLs (default: 3).
- `TIMEOUT`: (Optional) Request timeout in minutes (default: 2).
- `MAX_DOWN_COUNT`: (Optional) Number of consecutive failures before notification (default: 2).

## Usage

1.  **Build the Docker Image**
    
	```bash
	git clone https://github.com/bariskisir/ShellWebsiteDownTracker
	cd ShellWebsiteDownTracker
	docker build -t shellwebsitedowntracker .
	```
    
2.  **Run the Docker Container**
    
    Use the following command to run the container, replacing the environment variable values as needed:
	```bash
	docker run -e TELEGRAM_API_KEY=your_api_key \
               -e CHAT_ID=your_chat_id \
               -e URLS="http://example.com,http://example.org" \
               -e CHECK_INTERVAL=3 \
               -e TIMEOUT=2 \
               -e MAX_DOWN_COUNT=2 \
               bariskisir/shellwebsitedowntracker
	```
    This command will run the container in detached mode, checking and updating the DNS record as necessary.

## License

This project is licensed under the MIT License.

[Dockerhub](https://hub.docker.com/r/bariskisir/shellwebsitedowntracker)
