### calico configuration file
```
C:\CalicoWindows\config.ps1
```
in this file several elements are important:

- the **CNI BIN DIR** and **CNI CONF DIR** if they are not bin configured like other systems, then the node will not work (e.g. containerd and kuberentes nodes)

- CALICO DATASTORE TYPE** select the datastore that corresponds to your needs. In most cases, use the kubernetes datastore.

after the first modification, use the **install-calico.ps1** script. If you've already run the script and need to make changes, restart your machine and run the install script again.

once installation is complete, start calico with **start-calico.ps1**.

### kubernetes configuration file
```
C:\CalicoWindows\kubernetes\kubelet-service.ps1
```
This file is used to configure kubernetes parameters. in **$argList**, configure the location of the **config** file logically as ``C:\k\config```.

At the bottom of the file is the cni configuration, which should be configured as calico:
```
$argList += "--cni-bin-dir=""C:\k\cni\bin"""
$argList += "--cni-conf-dir=""C:\k\cni\config"""
```

### Containerd configuration file

```
C:\Program Files\containerd\config.toml
```
configure cni in the same way as calico and kubernetes


