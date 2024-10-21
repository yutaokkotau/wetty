# Use the official Ubuntu base image
FROM ubuntu:latest

# Set non-interactive mode for apt-get
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages: tmate and OpenSSH server
RUN apt-get update && \
    apt-get install -y tmate openssh-server && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create necessary directories for SSH and tmate
RUN mkdir -p /var/run/sshd /root/.tmate

# Start SSH server and generate persistent SSH keys
RUN ssh-keygen -A

# Generate a tmate session and save SSH and web connection info to /root/.tmate.conf
RUN if [ ! -f /root/.tmate.conf ]; then \
    tmate -S /root/.tmate.sock new-session -d && \
    tmate -S /root/.tmate.sock wait tmate-ready && \
    tmate -S /root/.tmate.sock display -p '#{tmate_ssh}' > /root/.tmate.conf && \
    tmate -S /root/.tmate.sock display -p '#{tmate_web}' >> /root/.tmate.conf; \
    fi

# Expose multiple ports for SSH and web access
EXPOSE 2222   # Default SSH port (can use for SSH access)
EXPOSE 8080   # Example web service port
EXPOSE 3000   # Example alternative service port (for another app if needed)

# Ensure tmate session runs in a persistent loop without resetting
CMD while true; do \
    if ! tmate -S /root/.tmate.sock has-session 2>/dev/null; then \
        tmate -S /root/.tmate.sock new-session -d && \
        tmate -S /root/.tmate.sock wait tmate-ready && \
        cat /root/.tmate.conf; \
    fi; \
    sleep 10; \
done
