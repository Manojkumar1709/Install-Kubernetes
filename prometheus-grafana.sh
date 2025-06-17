#!/bin/bash

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
helm repo add stable https://charts.helm.sh/stable
helm repo update

# Install Prometheus and Grafana
echo "Installing Prometheus and Grafana..."
helm install prometheus prometheus-community/kube-prometheus-stack

# Wait for Grafana to be ready
echo "Waiting for Grafana to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/prometheus-grafana

# Enable Grafana to be accessible via NodePort
echo "Enabling Grafana to be accessible via NodePort..."
kubectl patch svc prometheus-grafana -n <namespace> -p '{"spec": {"type": "NodePort"}}'

# Output Grafana credentials
echo "Grafana is accessible at http://localhost:3000"
echo "Default username: admin"
echo "Default password: prom-operator"

