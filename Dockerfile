# Use a lightweight base image that includes bash
FROM alpine:latest

# Install curl and bash
RUN apk add --no-cache curl bash

# Set the working directory
WORKDIR /usr/src/app

# Copy the script into the container
COPY entrypoint.sh .

# Make the script executable
RUN chmod +x entrypoint.sh

# Set the entry point for the container to use bash
ENTRYPOINT ["/bin/bash", "./entrypoint.sh"]
