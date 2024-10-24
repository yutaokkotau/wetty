# Use the official Ubuntu base image
FROM ubuntu:latest

# Set non-interactive mode for apt-get
ENV DEBIAN_FRONTEND=noninteractive

# Install tmate and a lightweight HTTP server (Nginx)
RUN apt-get update && \
    apt-get install -y tmate nginx && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Upgrade packages
RUN apt update && apt upgrade -y

# Remove unnecessary packages
RUN apt autoremove -y

# Set the working directory
WORKDIR /root

# Install essential packages
RUN apt install python3 neofetch nano iproute2 curl wget git make systemd -y
RUN apt install openssh-server -y

# Install a systemctl replacement for Docker
RUN curl -o /bin/systemctl https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl3.py
RUN chmod 775 /bin/systemctl

# Configure SSH to allow root login
RUN sed -i 's/#Port 22/Port 22/g' /etc/ssh/sshd_config
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
RUN echo 'root:123456' | chpasswd

# Start the SSH service
RUN systemctl start sshd

# Create a directory for serving the HTML page
RUN mkdir -p /var/www/html

# Start tmate in the background and write the session details to index.html
RUN tmate -F | tee /var/www/html/index.html &

# Set a default message for motd (Message of the Day)
RUN echo 'Welcome to your container!' > /etc/motd

# Replace the default Nginx config with a basic one to serve the tmate session
RUN echo 'server { listen 80; location / { root /var/www/html; try_files $uri $uri/ =404; } }' > /etc/nginx/sites-available/default

# Expose port 80 for the web server
EXPOSE 80

# Start Nginx in the foreground (which will keep the container alive)
CMD ["nginx", "-g", "daemon off;"]
