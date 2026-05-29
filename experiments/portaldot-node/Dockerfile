# Dockerfile for Portaldot Development Node
# This runs the Ubuntu binary in a container

FROM ubuntu:22.04

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    wget \
    tar \
    && rm -rf /var/lib/apt/lists/*

# Download and extract Portaldot binary
RUN wget -q https://github.com/portaldotVolunteer/Portaldot-node/raw/main/portaldot-testnet-ubuntu.tar.gz && \
    tar -xzf portaldot-testnet-ubuntu.tar.gz && \
    chmod +x portaldot-testnet-ubuntu/portaldot_dev && \
    mv portaldot-testnet-ubuntu/portaldot_dev /usr/local/bin/ && \
    rm -rf portaldot-testnet-ubuntu*

# Expose WebSocket and HTTP RPC ports
EXPOSE 9944 9933

# Run dev node
ENTRYPOINT ["portaldot_dev", "--dev", "--alice", "--ws-external", "--rpc-external", "--rpc-cors", "all"]
