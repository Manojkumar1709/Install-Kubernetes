#!/bin/bash

# Define the namespace
NAMESPACE="monitoring"

# Create a new namespace
echo "Creating namespace: $NAMESPACE"
kubectl create namespace $NAMESPACE

# Install Helm
echo "Installing Helm..."
curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
sudo apt-get install apt-transport-https --yes
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm -y

# Add Prometheus and stable repos
echo "Adding Helm repositories..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install Prometheus and Grafana in the new namespace
echo "Installing Prometheus and Grafana in namespace '$NAMESPACE'..."
helm install prometheus prometheus-community/kube-prometheus-stack -n $NAMESPACE

# Wait for Grafana to be ready
echo "Waiting for Grafana to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/prometheus-grafana -n $NAMESPACE

# Enable Grafana to be accessible via NodePort
echo "Enabling Grafana to be accessible via NodePort..."
kubectl patch svc prometheus-grafana -n $NAMESPACE -p '{"spec": {"type": "NodePort"}}'

# Get Node IP and Grafana NodePort
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
NODE_PORT=$(kubectl get svc prometheus-grafana -n $NAMESPACE -o jsonpath='{.spec.ports[0].nodePort}')

# Output Grafana access info
echo "--------------------------------------------------"
echo "Grafana is accessible at: http://$NODE_IP:$NODE_PORT"
echo "Default username: admin"
echo "To get the password, run: kubectl get secret prometheus-grafana -n $NAMESPACE -o jsonpath='{.data.admin-password}' | base64 --decode"
echo "--------------------------------------------------"