## Possible erreur et comment les réglers



### Le script PowerShell échoue avec l'erreur " …nssm.exe is not recognized as the name of a cmdlet"

Quand on execute : ```C:\install-calico-windows.ps1 -KubeVersion 1.25.3 -ServiceCidr 10.96.0.0/12 -DNSServerIPs 10.96.0.10 ``` ou une commande similaire
il y a l'erreur : ``` The term ‘c:\CalicoWindows\libs\calico\..\..\..\nssm.exe’ is not recognized as the name of cmdlet, function,….```

voici la solution
```powershell
Remove-Item $RootDir -Force  -Recurse -ErrorAction SilentlyContinue
Write-Host "Unzip Calico for Windows release..."
Expand-Archive -Force $CalicoZip c:\
$nssmDir = Get-ChildItem $RootDir -filter "nssm*" -Directory
mv $nssmDir.fullname $RootDir\nssm-2.24
ipmo -force $RootDir\libs\calico\calico.psm1
```
