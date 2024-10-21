# Use the official Ubuntu base image
FROM ubuntu:latest

# Set non-interactive mode for apt-get
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages: tmate, and OpenSSH server
RUN apt-get update && \
    apt-get install -y tmate openssh-server && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create necessary directories for SSH
RUN mkdir -p /var/run/sshd /root/.tmate

# Start SSH server
RUN service ssh start

# Generate persistent SSH keys if they don't exist
RUN ssh-keygen -A

# Generate a tmate SSH session with persistent keys
RUN if [ ! -f /root/.tmate.conf ]; then \
    tmate -S /root/.tmate.sock new-session -d && \
    tmate -S /root/.tmate.sock wait tmate-ready && \
    tmate -S /root/.tmate.sock display -p '#{tmate_ssh}' > /root/.tmate.conf && \
    tmate -S /root/.tmate.sock display -p '#{tmate_web}' >> /root/.tmate.conf; \
    fi

# Expose port 22 for SSH
EXPOSE 22

# Ensure tmate session runs in a persistent loop, without resetting
CMD while true; do \
    if ! tmate -S /root/.tmate.sock has-session 2>/dev/null; then \
        tmate -S /root/.tmate.sock new-session -d && \
        tmate -S /root/.tmate.sock wait tmate-ready && \
        cat /root/.tmate.conf; \
    fi; \
    sleep 10; \
done
