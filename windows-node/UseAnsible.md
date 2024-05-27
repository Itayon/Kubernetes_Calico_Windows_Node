## Utiliser Ansible pour créer une node Windows

Pour utiliser Ansible, il y a quelques prérequis à mettre en place sur Windows :

- Avoir un accés ssh au serveur windows
- Avoir winrm installé
- Avoir configuré le pare-feu pour autoriser les connexions
- Configurer correctement le repertoir tmp (le plus simple et de faire un lien symbolique) 

Ansible fonctionnera globalement comme sur linux, à quelque exceptions prêt voici a quoi doit ressembler la configuration ```/etc/ansible/host``` pour un hote windows:

```Bash
[wintest]
192.168.122.98

[wintest:vars]
ansible_user= Administrateur
ansible_password=Azert1234
remote_tmp= c:/tmp
ansible_connection=winrm
ansible_winrm_server_cert_validation=ignore
```

une fois configuré on peu tester la connexion avec : ``` ansible nom_de_la_node -m win_ping ```

## Utliser le [Script ansible](https://git.bu-dsa.si.c-s.fr/lbouakka/Kubernetes_calico_and_windows_node/src/branch/main/windows-node/autoconfigwindowsnode.yml)

Pour utiliser le [script](https://git.bu-dsa.si.c-s.fr/lbouakka/Kubernetes_calico_and_windows_node/src/branch/main/windows-node/autoconfigwindowsnode.yml), c'est simple : il suffit de le lancer avec ```ansible-playbook autoconfigwindowsnode.yml```.

Pour modifier la configuration, on peut changer le nom d'hôte (il doit correspondre à celui dans ```/etc/ansible/hosts```).

On peut également modifier les versions qu'on installe dans les variables à la fin du fichier.

Une fois que le script est terminé, attendez un petit moment. Vous verrez apparaitre la node sur votre cluster.

#### ⚠️ Attention, le script doit être lancé depuis le master Kubernetes. Si vous le lancez depuis un autre endroit, modifiez la ligne "Récupération du kubeconfig pour l'initialisation de Kubernetes" pour récupérer le bon fichier. ⚠️