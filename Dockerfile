# Use the official Ubuntu base image
FROM ubuntu:latest

# Set non-interactive mode for apt-get
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages: curl, sudo, OpenSSH server, and Sish
RUN apt-get update && \
    apt-get install -y curl sudo openssh-server && \
    curl -L https://github.com/antoniomika/sish/releases/download/v1.0.0/sish-linux-amd64 \
    -o /usr/local/bin/sish && \
    chmod +x /usr/local/bin/sish && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create a directory for SSH keys
RUN mkdir /run/sshd

# Expose port 2222 for SSH and 443 for HTTPS connections (Sish)
EXPOSE 2222 443

# Start SSH server and Sish (no user setup required)
CMD ["/usr/local/bin/sish", "-ssh-address", ":2222", "-http-address", ":443", "-https", "-localhost-only", "false"]
