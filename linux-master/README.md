## Scripts pour installer kubernetes sur un serveur master CentOS

Ce répertoir contient un  scripts a lancer nommer ```install-master.sh```

Le role de ce script est d'installer des addons pour kubernetes  de l'installer ansi que containerd

A la fin du script la machine va redémarrer

A la reconnexion on va lancer kubernetes
voici la commande ```kubeadm init --pod-network-cidr=192.168.0.0/16 --apiserver-advertise-address=l'adresse.ip.de.cette-machinne```

Exemple dans notre cas ```kubeadm init --pod-network-cidr=192.168.0.0/16 --apiserver-advertise-address=192.168.100.20```


La commande va nous fournir une autre commande permettant de connecter des nodes si vous perdres la commande vous pouvez la récupérez a nouveau avec ```kubeadm token create --print-join-command```

Les commandes ci dessous sont a executer aprés le kubeadm init. elle a valider la configuration de kubernetes et de permettre a l'utilisateur d'avoir accés a kubernetes

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
**Pour les commandes disponible et les fichier de configuration consulter conf.md**
