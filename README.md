
# Kubernetes 

<img src="https://github.com/kubernetes/kubernetes/raw/master/logo/logo.png" width="100">

## Installing the Kubeadm on a local ubuntu machine

This guide provides step-by-step instructions to install and configure a Kubernetes cluster using Kubeadm on Ubuntu.




## Requirements to install and setup Kubernetes using Kubeadm

 - [Ubuntu](https://ubuntu.com/download/server)
 - [Oracle Virtual Box](https://www.virtualbox.org/wiki/Downloads)


## Installation of kubeadm

### Requirements to install and setup Kubernetes using Kubeadm

 - master - 1
 - nodes - 2

Install on master machine

```bash
curl -fsSL https://raw.githubusercontent.com/Manojkumar1709/Install-Kubernetes/master/master.sh | sudo bash
```

or 

```bash
git clone https://github.com/Manojkumar1709/Install-Kubernetes.git && cd Install-Kubernetes
```

```bash
chmod +x master.sh
sudo ./master.sh
```

Install on node machine

```bash
curl -fsSL https://raw.githubusercontent.com/Manojkumar1709/Install-Kubernetes/master/node.sh | sudo bash
```

or

```bash
git clone https://github.com/Manojkumar1709/Install-Kubernetes.git && cd Install-Kubernetes
```

```bash
chmod +x node.sh
sudo ./node.sh
```


After Installing kubeadm on both master and worker node machine print the join command master machine

```bash
kubeadm token create --print-join-command
```

Now in node machine use the same command and join the nodes 

```bash
kubeadm join <master-node-ip>:<port> --token <token> --discovery-token-ca-cert-hash sha256:<hash>
```


### Setup LoadBalancer for Kubernetes Cluster

```bash
curl -fsSL https://raw.githubusercontent.com/Manojkumar1709/Install-Kubernetes/master/load-balancer.sh | sudo bash
```

or

```bash
git clone https://github.com/Manojkumar1709/Install-Kubernetes.git && cd Install-Kubernetes
```

```bash
chmod +x load-balancer.sh
sudo ./load-balancer.sh
```

### Install Prometheus-Grafana Monitoring Tool

```bash
curl -fsSL https://raw.githubusercontent.com/Manojkumar1709/Install-Kubernetes/master/prometheus-grafana.sh | sudo bash
```

or

```bash
git clone https://github.com/Manojkumar1709/Install-Kubernetes.git && cd Install-Kubernetes
```

```bash
chmod +x prometheus-grafana.sh
sudo ./prometheus-grafana.sh
```

    