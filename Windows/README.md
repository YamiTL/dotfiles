# dotfiles

Installation mode

Allow to run external sripts

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

```powershell
$InstallMasterScriptURI = "https://raw.githubusercontent.com/YamiTL/dotfiles/main/Install-master-script.ps1"
Invoke-WebRequest -Uri $InstallMasterScriptURI -OutFile .\Install-master-script.ps1
```

and run it with

```
& .\Install-master-script.ps1
```
