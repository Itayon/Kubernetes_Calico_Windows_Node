## Possible errors and how to fix them



### PowerShell script fails with error "...nssm.exe is not recognized as the name of a cmdlet"

When executing: ``C:\install-calico-windows.ps1 -KubeVersion 1.25.3 -ServiceCidr 10.96.0.0/12 -DNSServerIPs 10.96.0.10 ``` or a similar command
there is the error: ```The term 'c:\CalicoWindows\libs\calico...\..\..\nssm.exe' is not recognized as the name of cmdlet, function,....```

here's the solution

```powershell
Remove-Item $RootDir -Force  -Recurse -ErrorAction SilentlyContinue
Write-Host "Unzip Calico for Windows release..."
Expand-Archive -Force $CalicoZip c:\
$nssmDir = Get-ChildItem $RootDir -filter "nssm*" -Directory
mv $nssmDir.fullname $RootDir\nssm-2.24
ipmo -force $RootDir\libs\calico\calico.psm1
```
