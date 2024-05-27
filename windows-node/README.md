## Préparation et installation de la node Windows

Pour l'implémentation d'une node Windows, il faut obligatoirement utiliser un serveur Windows.

### Préparer le master

Sur le serveur master, on va initialiser des pods pour permettre l'implémentation d'une node Windows. 
```bash
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.4/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.4/manifests/custom-resources.yaml
kubectl patch ipamconfigurations default --type merge --patch='{"spec": {"strictAffinity": true}}'kubectl patch installation default --type=merge -p '{"spec": {"calicoNetwork": {"bgp": "Disabled"}}}'
```
## Installation avec Ansible

Pour installer la node avec ansible voici un guide pour utliser ansible et windows et le script ansible. 
- [repertoir ansible](https://github.com/Itayon/Kubernetes_Calico_Windows_Node/tree/main/windows-node/Deploiment_Ansible)
- [Utiliser ansible et windows](https://github.com/Itayon/Kubernetes_Calico_Windows_Node/blob/main/windows-node/Deploiment_Ansible/README.md)
- [script ansible](https://github.com/Itayon/Kubernetes_Calico_Windows_Node/blob/main/windows-node/Deploiment_Ansible/playbook.yml)


## Installation a la main

#### Préparer le serveur windows
```powershell
Install-WindowsFeature Containers
Install-WindowsFeature Hyper-V
Install-WindowsFeature Hyper-V-PowerShell

Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

Restart-Computer -force
```
#### Installation containerd
```Powershell
$Version="1.6.9"
curl.exe -L https://github.com/containerd/containerd/releases/download/v$Version/containerd-$Version-windows-amd64.tar.gz -o containerd-windows-amd64.tar.gz
tar.exe xvf .\containerd-windows-amd64.tar.gz

Copy-Item -Path ".\bin\" -Destination "$Env:ProgramFiles\containerd" -Recurse -Force
cd $Env:ProgramFiles\containerd\
.\containerd.exe config default | Out-File config.toml -Encoding ascii

Get-Content config.toml

.\containerd.exe --register-service
Start-Service containerd
```

#### Installation de calico

Création du répertoire **C:\k** et installation de Calico.
```Powershell
mkdir c:\k
```

Avant d'installer Calico, on va récupérer le fichier config de Kubernetes du master.
```Powershell
scp utilisateurmaster@adresse.ip.du.master:.kube/config C:/k/config
```

Si vous voulez utiliser une autre méthode pour récupérer le fichier de configuration, vous pouvez le faire. L'essentiel est que le fichier soit identique et dans **C:/k**.
```powershell
Invoke-WebRequest https://github.com/projectcalico/calico/releases/download/v3.27.2/install-calico-windows.ps1 -OutFile c:\install-calico-windows.ps1
C:\install-calico-windows.ps1 -KubeVersion 1.28.2 -ServiceCidr 10.96.0.0/12 -DNSServerIPs 10.96.0.10
```

Vérifier que Calico et Kubernetes ont bien le bon CNI.

La configuration de Calico doit ressembler à cela :

**c:/calicowindows/config.ps1**
```powershell
## CNI configuration, only used for the "vxlan" networking backends.

if (Get-IsContainerdRunning)
{
    Set-EnvVarIfNotSet -var "CNI_BIN_DIR" -defaultValue "c:\k\cni"
    Set-EnvVarIfNotSet -var "CNI_CONF_DIR" -defaultValue "c:\k\cni\config"
} else {
    # Place to install the CNI plugin to. For docker, this should match kubelet's --cni-bin-dir.
    Set-EnvVarIfNotSet -var "CNI_BIN_DIR" -defaultValue "c:\k\cni"
    # Place to install the CNI config to. For docker, this should be located in kubelet's --cni-conf-dir.
    Set-EnvVarIfNotSet -var "CNI_CONF_DIR" -defaultValue "c:\k\cni\config"
```

le fichier de configuration kubernetes doit ressembler à cela:
**C:\CalicoWindows\kubernetes\kubelet-service.ps1**
```powershell
    # These params are only applicable for the docker container runtime.
    #
    $argList += "--cni-bin-dir=""c:\k\cni"""
    $argList += "--cni-conf-dir=""c:\k\cni\config"""
    $argList += "--network-plugin=cni"
    $argList += "--pod-infra-container-image=kubeletwin/pause"
    $argList += "--image-pull-progress-deadline=20m"
```

### dernière config et démarrage

on va vérifier le cni de containerd **C:\Program Files\containerd\config.toml**
le fichier doit ressembler à cela:
```powershell
    [plugins."io.containerd.grpc.v1.cri".cni]
      bin_dir = "C:\\k\\cni"
      conf_dir = "C:\\k\\cni\\config"
      conf_template = ""
      ip_pref = ""
      max_conf_num = 1
```

Le principal est que les trois services aient la même configuration CNI, peu importe où vous la faites.

-Ensuite, on va redémarrer (très important, et changer le nom de votre machine si ce n'est pas déjà fait) une dernière fois, puis démarrer le script ```C:\CalicoWindows\install-calico.ps1```.

-Une fois le script initialisé, on va exécuter le fichier ```C:\CalicoWindows\kubernetes\install-kube-services.ps1```.

### **Si toute la configuration s'est bien passée, la node devrait s'afficher en "Ready" d'ici une petite minute sur le master.**

-------------------------------------------------------------------------------------------------------------

## Mise a jour de la node windows

Pour mettre a jour la node il faut déplacer le fichier d'update dans le répèrtoir courant de calico
```powershell
cp C:\CalicoWindows\upgrade\upgrade-service.ps1 C:\CalicoWindows\upgrade-service.ps1
```

On va ensuite copier le fichier kube config pour l'utiliser dans le répèrtoir courant de calico
```powershell
cp C:\k\config C:\CalicoWindows\calico-kube-config
```

On va mainteant lancer l'upgrade
```powershell
./upgrade-service.ps1
```
Choisir la version de kubernetes vers leqeul on veut upgrade
exemple de commande:
```powershell
$kubeversion="1.29.2"
```

Récuperer la nouvelle version de kubeadm
```powershell
curl.exe -Lo c:\k\kubeadm.exe  "https://cdn.dl.k8s.io/release/v$kubeversion/bin/windows/amd64/kubeadm.exe"
```

⚠️ Sur le master⚠️  drain la node qu'on met a jour
```bash
kubectl drain <node-a-drain> --ignore-daemonsets
kubeadm upgrade node
```

Sur la node windows mettre a jour kubelet et kube-proxy
```powershell
stop-service kubelet
stop-service kube-proxy
curl.exe -Lo c:\k\kubelet.exe "https://cdn.dl.k8s.io/release/v$kubeversion/bin/windows/amd64/kubelet.exe"
curl.exe -Lo c:\k\kube-proxy.exe "https://cdn.dl.k8s.io/release/v$kubeversion/bin/windows/amd64/kube-proxy.exe"
restart-service kubelet
restart-service kube-proxy
```

⚠️ Sur le master⚠️  on ramène le noeud
```
kubectl uncordon <node-a-drain>
```

Enfin on redémarre la node windows
```powershell
Restart-Computer -force
```
-------------------------------------------------------------------------------------------------------------

## Lancement d'un pods

Pour vérifier que la node fonctionne on va initialiser un pods.
les conteneur windows ne reste pas allumer un fois lancer voici donc un [fichier yaml](https://github.com/Itayon/Kubernetes_Calico_Windows_Node/blob/main/windows-node/Pods/Nano_server_image.yaml) permettant de garder la pods allumer.

voici les étape pour l'initialiser sur le master:

- récupérer le yaml en le copiant ou en le téléchargant
```bash
wget https://github.com/Itayon/Kubernetes_Calico_Windows_Node/blob/main/windows-node/Pods/Nano_server_image.yaml
```

- On va ensuite le lancer
```bash
kubectl apply -f Nano_server_image.yaml
```

- Pour vérifier l'états du pods on peu executer la commande
```bash
kubectl get pods -o wide -w
```

- Si le pods ne fonctionne pas vous pouvez afficher les inforation du pods avec
```bash
kubectl describe pods/nomdupods
```
exemple
```bash
kubectl describe pods/win-1494aeff45
```
- Pour supprimer le pods
```bash
kubectl delete -f Nano_server_image.yaml
```



