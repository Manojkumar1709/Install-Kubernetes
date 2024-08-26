# Installing Metallb for kubernetes cluster

#!/bin/bash

# Fetch the latest MetalLB version from GitHub
#METALLB_VERSION=$(curl --silent "https://api.github.com/repos/metallb/metallb/releases/latest" | grep 'tag_name' | awk -F '"' '{print $4}')

# Apply the MetalLB namespace manifest
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.10.2/manifests/namespace.yaml
#kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/${METALLB_VERSION}/manifests/namespace.yaml

# Apply the MetalLB manifest
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.10.2/manifests/metallb.yaml
#kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/${METALLB_VERSION}/manifests/metallb.yaml

# Get the list of all node IPs
NODE_IPS=$(kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}')

# Convert the IPs to an array
IFS=' ' read -r -a IP_ARRAY <<< "$NODE_IPS"

# Function to extract the subnet (first three octets) from an IP address
extract_subnet() {
  local ip=$1
  IFS='.' read -r -a octets <<< "$ip"
  echo "${octets[0]}.${octets[1]}.${octets[2]}"
}

# Get the subnet from the first IP in the array
SUBNET=$(extract_subnet "${IP_ARRAY[0]}")

# Function to increment an IP address
increment_ip() {
  local ip=$1
  local -a octets
  IFS='.' read -r -a octets <<< "$ip"
  ((octets[3]++))
  if [ "${octets[3]}" -eq 256 ]; then
    octets[3]=0
    ((octets[2]++))
    if [ "${octets[2]}" -eq 256 ]; then
      octets[2]=0
      ((octets[1]++))
      if [ "${octets[1]}" -eq 256 ]; then
        octets[1]=0
        ((octets[0]++))
      fi
    fi
  fi
  echo "${octets[0]}.${octets[1]}.${octets[2]}.${octets[3]}"
}

# Sort the IP array to find the highest IP address in use
IFS=$'\n' sorted_ips=($(sort -t . -k 1,1n -k 2,2n -k 3,3n -k 4,4n <<< "${IP_ARRAY[*]}"))
unset IFS

# Start IP range just after the highest IP in the list
START_IP=$(increment_ip "${sorted_ips[-1]}")

# Define the number of IPs needed for the pool (adjust as necessary)
IP_RANGE_SIZE=20

# Calculate the end IP
END_IP=$START_IP
for ((i=1; i<IP_RANGE_SIZE; i++)); do
  END_IP=$(increment_ip "$END_IP")
done

# Create the MetalLB ConfigMap file with the dynamically generated IP range
cat <<EOF > metallb-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - ${START_IP}-${END_IP}
EOF

# Apply the MetalLB configuration
kubectl apply -f metallb-config.yaml

# Check the status of MetalLB pods
kubectl get pods -n metallb-system

echo "MetalLB configuration applied successfully with IP range ${START_IP} to ${END_IP}!"
