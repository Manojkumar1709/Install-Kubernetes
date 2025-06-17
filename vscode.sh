#!/bin/bash

# Create Namespace
kubectl create namespace vscode

# Create Deployment YAML
cat <<EOF > vscode-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: code-server
  namespace: vscode
spec:
  replicas: 1
  selector:
    matchLabels:
      app: code-server
  template:
    metadata:
      labels:
        app: code-server
    spec:
      containers:
        - name: code-server
          image: codercom/code-server:latest
          ports:
            - containerPort: 8080
          volumeMounts:
            - name: code-data
              mountPath: /home/coder/project
          env:
            - name: PASSWORD
              value: "vscode123"  # Change this password
      volumes:
        - name: code-data
          emptyDir: {}
EOF

# Apply Deployment
kubectl apply -f vscode-deployment.yaml

# Create Service YAML
cat <<EOF > vscode-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: code-server
  namespace: vscode
spec:
  type: NodePort
  selector:
    app: code-server
  ports:
    - port: 8080
      targetPort: 8080
      nodePort: 30080  # You can access it at http://<node-ip>:30080
EOF

# Apply Service
kubectl apply -f vscode-service.yaml

# Output Access Info
echo -e "\n✅ VS Code Server Deployed!"
echo "🌐 Access it via: http://<NODE-IP>:30080"
echo "🔐 Password: vscode123"
