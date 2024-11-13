#!/bin/bash

# Function to prompt user input with a default value
prompt() {
    read -p "$1 [$2]: " input
    echo "${input:-$2}"
}

# Prompt for user inputs with default values
CONTAINER_NAME=$(prompt "Enter the Docker container name" "ubuntu_ssh_container")
HOST_PORT=$(prompt "Enter the host port for SSH access" "2222")
CONTAINER_PORT=$(prompt "Enter the container SSH port" "22")
ROOT_PASSWORD=$(prompt "Enter the root password for SSH" "1234")

# Step 1: Run a new Ubuntu container with SSH port mapping
echo "Starting a new Docker container with name: $CONTAINER_NAME"
sudo docker run -d -p $HOST_PORT:$CONTAINER_PORT --name $CONTAINER_NAME ubuntu tail -f /dev/null

# Wait for container to start
sleep 2

# Step 2: Install OpenSSH server and nano editor
echo "Installing OpenSSH server and nano inside the container..."
sudo docker exec -it $CONTAINER_NAME apt update
sudo docker exec -it $CONTAINER_NAME apt install -y openssh-server nano

# Step 3: Set the root password for SSH access
echo "Setting root password in container..."
sudo docker exec -it $CONTAINER_NAME bash -c "echo 'root:$ROOT_PASSWORD' | chpasswd"

# Step 4: Allow root login for SSH
echo "Configuring SSH to allow root login..."
sudo docker exec -it $CONTAINER_NAME bash -c "echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config"

# Step 5: Start SSH service
echo "Starting SSH service in container..."
sudo docker exec -it $CONTAINER_NAME service ssh start

echo -e "\nContainer setup complete!"
echo "To SSH into the container, use the following command:"
echo "ssh root@<Docker_Host_IP> -p $HOST_PORT"
echo "Password: $ROOT_PASSWORD"
