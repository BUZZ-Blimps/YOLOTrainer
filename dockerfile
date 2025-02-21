# Use official Ubuntu 22.04 image
FROM ubuntu:22.04

# Set noninteractive mode for apt
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3.10 python3.10-venv python3-pip \
    wget unzip git curl nano \
    && apt-get clean

# Set Python3.10 as default
RUN ln -sf /usr/bin/python3.10 /usr/bin/python

# Create a virtual environment at /opt/venv
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy requirements file and install dependencies
WORKDIR /app
COPY requirements.txt /app/
RUN pip install --upgrade pip && pip install -r requirements.txt

# Copy the entire project into the container
COPY . /app

# Ensure entrypoint.sh is executable
RUN chmod +x entrypoint.sh

# Expose ports if needed (e.g., 8888)
EXPOSE 8888

# Set entrypoint to our entrypoint.sh script and pass default CMD argument (-untagged)
CMD ["-untagged"]

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
