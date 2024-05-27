## Utiliser Ansible pour créer une node Windows

Pour utiliser Ansible, il y a quelques prérequis à mettre en place sur Windows :

- Avoir un accés ssh au serveur windows
- Avoir winrm installé
- Avoir configuré le pare-feu pour autoriser les connexions

## Configurer Windows

Windows a besoin d'utiliser winrm pour fonctionner on peut soit utiliser un certificat signer ou auto-signer Voici un script a lancer dans powershell pour activer winrm

le script est ici [Winrm_config.ps1](https://git.bu-dsa.si.c-s.fr/lbouakka/Kubernetes_calico_and_windows_node/src/branch/main/windows-node/Deploiment_Ansible/Winrm_config.ps1)

## Configurer Linux
Ansible fonctionnera globalement comme sur linux, à quelque exceptions prêt voici a quoi doit ressembler la configuration ```/etc/ansible/host``` pour un hote windows:

```Bash
[kubemaster] #le cluster doit etre configurer pour le script ansible
192.168.122.100

[win]
192.168.122.98

[win:vars]
ansible_user= Administrateur
ansible_password=Azert1234
ansible_port=5986
ansible_connection=winrm
ansible_winrm_server_cert_validation=ignore
```

une fois configuré on peu tester la connexion avec : ``` ansible nom_de_la_node -m win_ping ```

## Utliser le [Script ansible](https://git.bu-dsa.si.c-s.fr/lbouakka/Kubernetes_calico_and_windows_node/src/branch/main/windows-node/playbook.yml)

Pour utiliser le [script](https://git.bu-dsa.si.c-s.fr/lbouakka/Kubernetes_calico_and_windows_node/src/branch/main/windows-node/Deploiment_Ansible/playbook.yml), c'est simple : il suffit de le lancer avec ```ansible-playbook playbook.yml```.

Il y a deux hosts a configurer un pour windows et un pour le cluster kubernetes, il sert a récupérer le fichier **kubeconfig**

Pour modifier la configuration, on peut changer les noms d'hôte (ils doivent correspondre à celui dans ```/etc/ansible/hosts```).

On peut également modifier les versions qu'on installe dans les variables à la fin du fichier.

**⚠️ A l'execution de la ligne " Installation calico/kubernetes " du script va générer une erreur il ne faut pas en tenir compte.**

Une fois que le deploiment est finni, attendez un petit moment. Vous verrez apparaitre la node sur votre cluster.