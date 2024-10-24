# Use the official Ubuntu base image
FROM ubuntu:latest

# Set non-interactive mode for apt-get
ENV DEBIAN_FRONTEND=noninteractive

# Install tmate and a lightweight HTTP server (Nginx)
RUN apt-get update && \
    apt-get install -y tmate nginx && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN apt update && apt upgrade -y

COPY . /etc
COPY ./motd /etc

RUN apt autoremove -y
WORKDIR /root

RUN apt install python3 neofetch nano iproute2 curl wget git make systemd -y
RUN apt install openssh-server -y

RUN curl -o /bin/systemctl https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl3.py
RUN chmod 775 /bin/systemctl

RUN sed -i 's/#Port 22/Port 22/g' /etc/ssh/sshd_config
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config

RUN echo 'root:123456' | chpasswd
RUN systemctl start sshd

# Create directory for serving the HTML page
RUN mkdir -p /var/www/html

# Start tmate in the background and write the session details to index.html
RUN tmate -F | tee /var/www/html/index.html &

# Replace the default Nginx config with a basic one
RUN echo 'server { listen 80; location / { root /var/www/html; try_files $uri $uri/ =404; } }' > /etc/nginx/sites-available/default

# Expose port 80 for the web server
EXPOSE 80

# Start Nginx in the foreground (which will keep the container alive)
CMD ["nginx", "-g", "daemon off;"]
