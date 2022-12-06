#!/bin/bash

declare -A ubuntu_links=(
  ["20.04"]="https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"
  ["21.10"]="https://cloud-images.ubuntu.com/impish/current/impish-server-cloudimg-amd64.img"
  ["22.04"]="https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
  ["22.10"]="https://cloud-images.ubuntu.com/kinetic/current/kinetic-server-cloudimg-amd64.img"
)

declare -A ubuntu_image=(
  ["20.04"]="focal-server-cloudimg-amd64.img"
  ["21.10"]="impish-server-cloudimg-amd64.img"
  ["22.04"]="jammy-server-cloudimg-amd64.img"
  ["22.10"]="kinetic-server-cloudimg-amd64.img"
)

# Install libguestfs-tools (dependency) on Proxmox server.
echo "Installing image customization tools, it can take some time..."
apt-get install -y libguestfs-tools

# Set environment variables. Change these as necessary.
export UBUNTU_RELEASE="22.04" # Available versions: 20.04, 21.10, 22.04, 22.10
export VM_NAME="ubuntu-${UBUNTU_RELEASE}-cloudimg"
export STORAGE_POOL="local-lvm"
export VM_ID="10000"

# You can add your own packages by splitting them with comma between
export PACKAGES_TO_INSTALL="qemu-guest-agent,htop"

# System variables, DO NOT CHANGE them
export CLOUD_IMAGE_NAME="${ubuntu_image[$UBUNTU_RELEASE]}"
export CLOUD_IMAGE_URL="${ubuntu_links[$UBUNTU_RELEASE]}"

# Switch into temporary directory
cd `mktemp -d`

# Download Ubuntu Image
wget $CLOUD_IMAGE_URL

# Customize the downloaded image



# Add packages (qemu-guest-agent) to Ubuntu image.
virt-customize -a $CLOUD_IMAGE_NAME --install $PACKAGES_TO_INSTALL

# Enable password authentication in the template. Obviously, not recommended for except for testing.
virt-customize -a $CLOUD_IMAGE_NAME --run-command "sed -i 's/.*PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config"

# Create Proxmox VM image from Ubuntu Cloud Image.
qm create $VM_ID --cpu cputype=host --cores 4 --memory 4096 --net0 virtio,bridge=vmbr0
qm importdisk $VM_ID $CLOUD_IMAGE_NAME $STORAGE_POOL
qm set $VM_ID --scsihw virtio-scsi-pci --scsi0 $STORAGE_POOL:vm-$VM_ID-disk-0
qm set $VM_ID --agent enabled=1,fstrim_cloned_disks=1
qm set $VM_ID --name $VM_NAME

# Create Cloud-Init Disk and configure boot.
qm set $VM_ID --ide2 $STORAGE_POOL:cloudinit
qm set $VM_ID --boot c --bootdisk scsi0
qm set $VM_ID --serial0 socket --vga serial0

# Convert VM into Template
qm template $MV_ID
