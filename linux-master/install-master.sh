#!/bin/bash
while true; do
    echo "Please choose your CentOS(c) or Debian(d) distribution:"
    read choice

    case "$choice" in
        c)
sudo dnf update -y
sudo dnf install -y apt-transport-https ca-certificates curl
sudo modprobe overlay
sudo modprobe br_netfilter
sudo cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sysctl --system
sudo sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install -y containerd
sudo mkdir -p /etc/containerd

sudo containerd config default | sudo tee /etc/containerd/config.toml
fichier="/etc/containerd/config.toml"
nouvelle_ligne="            SystemdCgroup = true"
sudo sed -i "125s/.*/$nouvelle_ligne/" "$fichier"
sudo systemctl restart containerd
sudo systemctl enable containerd
sudo touch /etc/yum.repos.d/kubernetes.repo

sudo cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

sudo dnf update
sudo dnf install -y kubelet kubeadm kubectl

sudo hostnamectl set-hostname "master-node"
sudo exec bash

echo 'désactivation de swap'
sudo swapoff -a
sudo swapoff -a; sed -i '/swap/d' /etc/fstab

systemctl enable kubelet

echo 'désactivation du firewall'
sudo systemctl disable firewalld
sudo systemctl stop firewalld

kubectl patch ipamconfigurations default --type merge --patch='{"spec": {"strictAffinity": true}}'
kubectl patch installation default --type=merge -p '{"spec": {"calicoNetwork": {"bgp": "Disabled"}}}'

kubeadm config images pull

break
;;
        d)
echo "pas encore implémenter"
break
;;
        *)
            echo "Invalid entry. Please enter 'c' or 'd'."
            ;;
    esac
done

