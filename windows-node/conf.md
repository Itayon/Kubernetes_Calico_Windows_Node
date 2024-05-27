### fichier de configuration calico
```
C:\CalicoWindows\config.ps1
```
dans ce fichier plusieur élément sont important:

- les **CNI BIN DIR** et **CNI CONF DIR** si il ne sont pas bin configurer comme les autre système alors la node ne fonctionnera pas. (ex: celle de containerd et de kuberentes)

- **CALICO DATASTORE TYPE** séléctionnez le datastore qui correspond a vos besoin dans la plupart des cas utiliser le datastore kubernetes

aprés la première modification utliser le script **install-calico.ps1**. Si vous avez déja lancer le script et que vous avez des modification a faire faites les, redémarrer votre machine etrelancer le script install.

une fois l'installation efféctuer démarer calico avec **start-calico.ps1**

### fichier de configuration kubernetes

```
C:\CalicoWindows\kubernetes\kubelet-service.ps1
```

Ce fichier permet de configurer des paramètre de kubernetes. dans **$argList** configurer correctement l'emplacement du fichier **config** logiquement en ```C:\k\config```

En bas du fichier il y a la configuration cni, il faut la configurer comme calico. utliser de préférence:
```
$argList += "--cni-bin-dir=""C:\k\cni\bin"""
$argList += "--cni-conf-dir=""C:\k\cni\config"""
```

### Fichier de configuration Containerd

```
C:\Program Files\containerd\config.toml
```
configurer le cni de la même façon que calico et kubernetes.
