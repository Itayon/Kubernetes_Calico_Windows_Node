## Preparing and installing the Windows node

To implement a Windows node, you need to use a Windows server.

### Preparing the master

On the master server, we'll initialize pods to enable implementation of a Windows node.

```bash
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.4/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.4/manifests/custom-resources.yaml
kubectl patch ipamconfigurations default --type merge --patch='{"spec": {"strictAffinity": true}}'kubectl patch installation default --type=merge -p '{"spec": {"calicoNetwork": {"bgp": "Disabled"}}}'
```

### Windows node installation

#### Preparing the windows server

```powershell
Install-WindowsFeature Containers
Install-WindowsFeature Hyper-V
Install-WindowsFeature Hyper-V-PowerShell

Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

Restart-Computer -force
```
#### Containerd installation
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
#### Installing calico

Create the **C:\k** directory and install Calico.

```Powershell
mkdir c:\k
```

Before installing Calico, we'll retrieve the Kubernetes config file from the master.
```Powershell
scp masteruser@your.kubernetes.master.ip:.kube/config C:/k/config
```

If you want to use another method to retrieve the configuration file, you can do so. The important thing is that the file is identical and in **C:/k**.
```powershell
Invoke-WebRequest https://github.com/Itayon/Kubernetes_Calico_Windows_Node/windows-node/install-calico-windows.ps1 -OutFile c:\install-calico-windows.ps1
C:\install-calico-windows.ps1 -KubeVersion 1.28.2 -ServiceCidr 10.96.0.0/12 -DNSServerIPs 10.96.0.10
```

Check that Calico and Kubernetes have the correct CNI.

The Calico configuration should look like this:

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

the kubernetes configuration file should look like this:
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

### last config and startup

we'll check the containerd cni **C:\Program Files\containerd\config.toml**.
the file should look like this:
```powershell
    [plugins."io.containerd.grpc.v1.cri".cni]
      bin_dir = "C:\\k\\cni"
      conf_dir = "C:\\k\\cni\\config"
      conf_template = ""
      ip_pref = ""
      max_conf_num = 1
```
The main thing is that all three services have the same CNI configuration, no matter where you do it.

-Next, we'll reboot (very important, and change the name of your machine if you haven't already) one last time, then run the script ``C:\CalicoWindows\install-calico.ps1``.

-Once the script has been initialized, we'll run the file ``C:\CalicoWindows\kubernetes\install-kube-services.ps1``.

### If all the configuration has gone smoothly, the node should display "Ready" in a few minutes on the master.

-------------------------------------------------------------------------------------------------------------

## Windows node update

To update the node, move the update file to the current calico directory
powershell
cp C:\CalicoWindows\upgrade-service.ps1 C:\CalicoWindows\upgrade-service.ps1
```

we will then copy the kube config file for use in the current calico directory
```powershell
cp C:\k\config C:\CalicoWindows\calico-kube-config
```

we'll now launch the upgrade
```powershell
./upgrade-service.ps1
```

-------------------------------------------------------------------------------------------------------------
## Launching a pod

To check that the node is working, we're going to initialize a pod. 
windows containers don't stay on once launched, so here's a [yaml file](/https://github.com/Itayon/Kubernetes_Calico_Windows_Node/windows-node/WinNanoServ.yaml) to keep the pod on.

here are the steps to initialize it on the master:

- get the yaml by copying or downloading it

```bash
wget https://git.bu-dsa.si.c-s.fr/lbouakka/Kubernetes_calico_and_windows_node/src/branch/main/windows-node/WinNanoServ.yaml
```

- We'll then launch it
```bash
kubectl apply -f WinNanoServ.yaml
```

- To check pod status, run the command
```bash
kubectl get pods -o wide -w
```
- If the pod doesn't work you can display the pod information with
```bash
kubectl describe pods/podname
```
example
```bash
kubectl describe pods/win-1494aeff45
```

