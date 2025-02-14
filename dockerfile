# Use Ubuntu 22.04 base image
FROM ubuntu:22.04

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3.8 \
    python3.8-venv \
    git \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Create virtual environment
RUN python3.8 -m venv /app/rknn-env

# Activate virtual environment and install RKNN-Toolkit2
RUN source /app/rknn-env/bin/activate && \
    wget https://github.com/airockchip/rknn-toolkit2/archive/refs/tags/v2.3.0.tar.gz && \
    tar -zxvf v2.3.0.tar.gz && \
    cd rknn-toolkit2-2.3.0/rknn-toolkit2/packages/x86_64/ && \
    pip install -r requirements_cp38-2.3.0.txt && \
    pip install rknn_toolkit2-2.3.0-cp38-cp38-linux_x86_64.whl

# Copy requirement files
COPY requirements.txt .

# Install dependencies inside virtual environment
RUN source /app/rknn-env/bin/activate && pip install -r requirements.txt

# Copy source code
COPY src/ /app/src/

# Ensure scripts are executable
RUN chmod +x /app/src/*.py

# Copy configuration file
COPY config.yaml /app/config.yaml

# Set the default command (can be overridden)
CMD ["bash"]
