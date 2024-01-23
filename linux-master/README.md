## Scripts for installing kubernetes on a CentOS master server

This directory contains a script to run called ``install-master.sh``.

The role of this script is to install addons for kubernetes as well as containerd

At the end of the script, the machine will reboot.

On reconnection, kubernetes will be launched
This is the command ```kubeadm init --pod-network-cidr=192.168.0.0/16 --apiserver-advertise-address=your.kubernetes.master.ip```

example in our case ```kubeadm init --pod-network-cidr=192.168.0.0/16 --apiserver-advertise-address=192.168.100.20```


The command will provide us with another command to connect nodes. If you lose the command, you can retrieve it again with  ```kubeadm token create --print-join-command```


The commands below are to be executed after the kubeadm init. they validate the kubernetes configuration and allow the user to access kubernetes.
```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
**For available commands and configuration files see [conf.md](https://github.com/Itayon/Kubernetes_Calico_Windows_Node/linux-master/conf.md)**.
