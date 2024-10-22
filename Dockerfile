# Use the official Ubuntu base image
FROM ubuntu:latest

# Set non-interactive mode for apt-get
ENV DEBIAN_FRONTEND=noninteractive

# Install tmate and a lightweight HTTP server (Nginx)
RUN apt-get update && \
    apt-get install -y tmate nginx && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create directory for serving the HTML page
RUN mkdir -p /var/www/html

# Start tmate and write session details to index.html without resetting
RUN echo "set -g tmate-server-keepalive 1" > ~/.tmate.conf
RUN tmate -F | tee /var/www/html/index.html &

# Replace the default Nginx config with a basic one
RUN echo 'server { listen 80; location / { root /var/www/html; try_files $uri $uri/ =404; } }' > /etc/nginx/sites-available/default

# Expose port 80 for the web server
EXPOSE 80

# Use a keep-alive mechanism that doesn’t interfere with tmate
RUN echo '#!/bin/bash\nwhile true; do sleep 86400; done' > /keep-alive.sh && chmod +x /keep-alive.sh

# Start Nginx in the foreground and ensure the container doesn't shut down
CMD ["/bin/bash", "-c", "/keep-alive.sh & nginx -g 'daemon off;'"]
