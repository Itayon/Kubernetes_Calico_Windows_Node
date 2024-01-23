#!/bin/bash
while true; do
    echo "Please choose your CentOS(c) or Debian(d) distribution:"
    read choice

    case "$choice" in
        c)
            dnf update -y
            dnf install -y apt-transport-https ca-certificates curl
            modprobe overlay
            modprobe br_netfilter
            cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
            overlay
            br_netfilter
            EOF

            cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
            net.bridge.bridge-nf-call-iptables = 1
            net.ipv4.ip_forward = 1
            net.bridge.bridge-nf-call-ip6tables = 1
            EOF

            sysctl --system
            dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
            dnf install -y containerd
            mkdir -p /etc/containerd

            containerd config default | sudo tee /etc/containerd/config.toml
            fichier="/etc/containerd/config.toml"
            nouvelle_ligne="            SystemdCgroup = true"
            sed -i "125s/.*/$nouvelle_ligne/" "$fichier"
            systemctl restart containerd
            systemctl enable containerd
            touch /etc/yum.repos.d/kubernetes.repo

            cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
            [kubernetes]
            name=Kubernetes
            baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
            enabled=1
            gpgcheck=1
            repo_gpgcheck=1
            gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
            EOF

            dnf update
            dnf install -y kubelet kubeadm kubectl

            hostnamectl set-hostname "master-node"
            exec bash

            swapoff -a
            swapoff -a; sed -i '/swap/d' /etc/fstab

            systemctl enable kubelet

            systemctl disable firewalld
            systemctl stop firewalld

            kubectl patch ipamconfigurations default --type merge --patch='{"spec": {"strictAffinity": true}}'
            kubectl patch installation default --type=merge -p '{"spec": {"calicoNetwork": {"bgp": "Disabled"}}}'

            kubeadm config images pull

            break
            ;;
        d)

            break
            ;;
        *)
            echo "Invalid entry. Please enter 'c' or 'd'."
            ;;
    esac
done

