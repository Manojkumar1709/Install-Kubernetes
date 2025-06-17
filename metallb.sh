#!/bin/bash

# Step 1: Install MetalLB
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.12/config/manifests/metallb-native.yaml

# Wait for MetalLB pods to be ready
echo "⏳ Waiting for MetalLB to be ready..."
kubectl wait --namespace metallb-system \
  --for=condition=ready pod \
  --selector=app=metallb \
  --timeout=90s

# Step 2: Create MetalLB IP AddressPool and L2Advertisement
cat <<EOF > metallb-config.yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  namespace: metallb-system
  name: local-ip-pool
spec:
  addresses:
    - 192.168.100.200-192.168.100.220  # Adjust this to your local subnet
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  namespace: metallb-system
  name: local-l2
spec:
  ipAddressPools:
    - local-ip-pool
EOF

# Step 3: Apply the configuration
kubectl apply -f metallb-config.yaml

echo -e "\n✅ MetalLB is installed and configured."
echo "🎯 IP Range set: 192.168.100.200-192.168.100.220"
