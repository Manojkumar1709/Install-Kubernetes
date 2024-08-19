# Required Ubuntu Server OS 
# Setup Kubernetes using Kubeadm
# Setup Master Node

#!/bin/bash

# Update the package repositories and upgrade installed packages to their latest versions
sudo apt update
sudo apt upgrade -y

# Disable swap to meet Kubernetes requirements (Kubernetes does not work with swap enabled)
sudo swapoff -a

# Comment out any lines in /etc/fstab that enable swap (prevents swap from being enabled after a reboot)
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# Reload the fstab file to apply any changes made
sudo mount -a

# Load necessary kernel modules for Kubernetes networking
sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF

# Apply the module changes immediately
sudo modprobe overlay
sudo modprobe br_netfilter

# Configure sysctl parameters required by Kubernetes to enable networking between containers
sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

# Apply the sysctl settings without rebooting
sudo sysctl --system

# Install dependencies for adding new repositories and downloading packages over HTTPS
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates

# Add Docker's official GPG key to the system keyring for package verification
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/docker.gpg

# Add Docker's official stable repository to the system's package sources
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Update the package repositories to include the Docker repository
sudo apt update

# Install containerd, the container runtime that Kubernetes will use
sudo apt install -y containerd.io

# Generate the default configuration for containerd and save it to /etc/containerd/config.toml
containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1

# Modify the containerd configuration to use systemd as the cgroup driver, which is recommended for Kubernetes
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

# Restart containerd to apply the new configuration
sudo systemctl restart containerd

# Enable containerd to start on boot
sudo systemctl enable containerd

# Update the package repositories again to ensure the latest information is available
sudo apt-get update

# Install dependencies for adding new repositories and downloading Kubernetes packages over HTTPS
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

# Add the Kubernetes official GPG key to the system keyring for package verification
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Add the Kubernetes repository to the system's package sources
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Update the package repositories to include the Kubernetes repository
sudo apt-get update

# Install the kubelet, kubeadm, and kubectl packages, which are necessary for managing the Kubernetes cluster
sudo apt-get install -y kubelet kubeadm kubectl

# Prevent these packages from being automatically updated to avoid potential compatibility issues
sudo apt-mark hold kubelet kubeadm kubectl
