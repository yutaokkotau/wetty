# Use the official Ubuntu base image
FROM ubuntu:latest

# Set non-interactive mode for apt-get
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages: Wetty (web-based SSH terminal) and Node.js
RUN apt-get update && \
    apt-get install -y curl gnupg && \
    curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get install -y nodejs openssl && \
    npm install -g wetty && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Expose port 3000 for Wetty web SSH access
EXPOSE 3000

# Start Wetty (web-based SSH) on port 3000
CMD ["wetty", "--port", "3000"]
