# Use official Ubuntu 22.04 image
FROM ubuntu:22.04

# Set noninteractive mode for apt
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies (including libgl1 and libglib2.0-0)
RUN apt-get update && apt-get install -y \
    python3.10 python3.10-venv python3-pip \
    wget unzip git curl nano \
    libgl1 libglib2.0-0 \
    && apt-get clean

# Set Python3.10 as default
RUN ln -sf /usr/bin/python3.10 /usr/bin/python

# Create a virtual environment at /opt/venv
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Set working directory
WORKDIR /app

# Copy requirements.txt and install dependencies (using a fast mirror if needed)
COPY requirements.txt /app/
RUN pip install --upgrade pip && pip install -r requirements.txt

# Copy the entire project into the container
COPY . /app

# Ensure entrypoint.sh is executable
RUN chmod +x entrypoint.sh

# Expose ports (if needed)
EXPOSE 8888

# Set entrypoint to run our entrypoint.sh script.
# Default CMD argument is "-untagged" (the user must supply the dataset folder path via a volume mount)
CMD ["-untagged"]

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
