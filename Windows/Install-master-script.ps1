# PS support base script
# https://stackoverflow.com/a/44810914/8552476

# 1. Catch bugs before run
# https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/set-strictmode
Set-StrictMode -Version Latest

# 2. Stop if an error occurs
# https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_preference_variables#erroractionpreference
$ErrorActionPreference = 'Stop'

$PSDefaultParameterValues['*:ErrorAction'] = 'Stop'

# --------------------- Install-master-script.ps1 --------------------- 

# import Appx or this wont work
# https://superuser.com/questions/1456837/powershell-get-appxpackage-not-working
if ($PSVersionTable.PSVersion.Major -eq 5) {
    # -UseWindowsPowershell it doesn't work on PS 5.0, only in 7.0
    Import-Module -Name Appx 
}
elseif ($PSVersionTable.PSVersion.Major -eq 7) {
    # -UseWindowsPowershell it doesn't work on PS 5.0, only in 7.0
    Import-Module -Name Appx -UseWindowsPowerShell
}
else {
    Write-Error "unknown powershell version"
}

# clear screen
Clear-Host

# Check for winget and install
Write-Host "`nInstalling winget - " -ForegroundColor Yellow -NoNewline; Write-Host "[1-10]" -ForegroundColor Green -BackgroundColor Black
$hasPackageManager = Get-AppPackage -name "Microsoft.DesktopAppInstaller"
$hasWingetexe = Test-Path "C:\Users\$env:Username\AppData\Local\Microsoft\WindowsApps\winget.exe"
if (!$hasPackageManager -or !$hasWingetexe) {
    $releases_url = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $releases = Invoke-RestMethod -uri "$($releases_url)"
    $latestRelease = $releases.assets | Where-Object { $_.browser_download_url.EndsWith("msixbundle") } | Select-Object -First 1
    Add-AppxPackage -Path $latestRelease.browser_download_url
}
else {
    Write-Host "Winget found. Skipping`n" -ForegroundColor Yellow
}

# Install PS7 
Write-Host "Installing Powershell 7 - " -ForegroundColor Yellow -NoNewline; Write-Host "[2-10]" -ForegroundColor Green -BackgroundColor Black
If (!(Test-Path "C:\Program Files\PowerShell\7\pwsh.exe")) {
    winget install --id Microsoft.Powershell --source winget #  --accept-package-agreements --accept-source-agreements doesnt work on PS 5.0
}
else {
    Write-Host "pwsh.exe found. Skipping`n" -ForegroundColor Yellow
}

# # make ~/Code/ folders
Write-Host "`ncreating `\Code` - " -ForegroundColor Yellow -NoNewline; Write-Host "[4-10]" -ForegroundColor Green -BackgroundColor Black

$codeFolderExists = Test-Path "C:\Users\$env:Username\Code\"

if (!$codeFolderExists) {
    New-Item -ItemType Directory "C:\Users\$env:Username\Code\"
}
else {
    Write-Host "~/Code/ folder found. Skipping`n" -ForegroundColor Yellow
}

# scoop install
Write-Host "`nInstalling scoop & apps - "  -ForegroundColor Yellow -NoNewline ; Write-Host "[6-10]" -ForegroundColor Green -BackgroundColor Black
try {
    $scoopIsInstalled = [Boolean](Get-Command 'scoop' -ErrorAction SilentlyContinue)
    if (!$scoopIsInstalled) {
        # Set policy to avoid errors
        Set-ExecutionPolicy RemoteSigned -scope CurrentUser

        # Install scoop
        Invoke-WebRequest -UseBasicParsing get.scoop.sh | Invoke-Expression
    }

    # Scoop can utilize aria2 to use multi-connection downloads
    scoop install aria2
    # disable the warning
    scoop config aria2-warning-enabled false

    # buckets
    # git is required for buckets
    scoop install git
    scoop bucket add extras

    # core
    scoop install 7zip autohotkey calibre czkawka-gui delta discord
    scoop install everything googlechrome jpegview-fork
    scoop install keepassxc nu oh-my-posh obs-studio peazip 
    scoop install powertoys ripgrep rustdesk sumatrapdf 
    scoop install telegram vlc vscode windirstat

    # programming languages
    # scoop install deno fnm python rustup

}
catch { Write-Warning $_ }

# configure `git
Write-Host "`nconfiguring git" -ForegroundColor Yellow -NoNewline; Write-Host "[4-10]" -ForegroundColor Green -BackgroundColor Black
git config --global user.name "YamiTL"
git config --global user.email "yamitlemos@gmail.com"

# clone `dotfiles`
Write-Host "`ncloning `\dotfiles\` - " -ForegroundColor Yellow -NoNewline; Write-Host "[4-10]" -ForegroundColor Green -BackgroundColor Black

$dotfilesFolderExists = Test-Path "C:\Users\$env:Username\Code\dotfiles\"

if (!$dotfilesFolderExists) {
    git clone https://github.com/YamiTL/dotfiles "$HOME\Code\dotfiles"
}
else {
    Write-Error "~\Code\dotfiles\ folder exists. Stopping excecution.`n" 
}

# Install glyphed fonts
$Font = "FiraCode"
Write-Host "`nInstalling glyphed fonts for OMP [$Font] - " -ForegroundColor Yellow -NoNewline ; Write-Host "[4-10]" -ForegroundColor Green -BackgroundColor Black
try {
    $fontsToInstallDirectory = "$Font-temp"

    # clean the folder if the font or directory exists
    $zipFileExists = Test-Path ".\$Font.zip"
    $fontsToInstallDirectoryExists = Test-Path "$fontsToInstallDirectory\"

    if ($zipFileExists) {
        Write-Host "$Font.zip found! Removing..." -ForegroundColor Yellow
        Remove-Item "$Font.zip"
    }
    if ($fontsToInstallDirectoryExists) {
        Write-Host "$fontsToInstallDirectory dir found! Removing..." -ForegroundColor Yellow
        Remove-Item "$fontsToInstallDirectory\" -Recurse -Force
    }

    # download the font
    # it doesnt work with .tar.xz. Only with .zip
    Invoke-WebRequest -Uri "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$Font.zip" -OutFile "./$Font.zip"

    # expand the zip
    # (you don't need to create the directory)
    Expand-Archive ".\$Font.zip" -DestinationPath $fontsToInstallDirectory

    
    # install the fonts
    $fontsToInstall = Get-ChildItem $fontsToInstallDirectory -Recurse -Include '*.ttf'

    $shellObejct = New-Object -ComObject shell.application
    $Fonts = $shellObejct.NameSpace(0x14)

    foreach ($f in $fontsToInstall) {
        $fullPath = $f.FullName
        $name = $f.Name
        $userInstalledFonts = "$env:USERPROFILE\AppData\Local\Microsoft\Windows\Fonts"
        if (!(Test-Path "$UserInstalledFonts\$Name")) {
            Write-Host "Installing $name... " -ForegroundColor Green
            $Fonts.CopyHere($FullPath)
        }
        else {
            $name = $f.Name
            Write-Host "$name found!. Skipping" -ForegroundColor Yellow
        }
    }
    Write-Host "Finished! $name... " -ForegroundColor Green

    Write-Host "Removing $Font.zip" -ForegroundColor Yellow
    Remove-Item "$Font.zip"
    Write-Host "Removing $fontsToInstallDirectory\ dir" -ForegroundColor Yellow
    Remove-Item "$fontsToInstallDirectory\" -Recurse -Force
}
catch { Write-Warning $_ }

Set PS profile
Write-Host "`nApplying Powershell profile - " -ForegroundColor Yellow -NoNewline ; Write-Host "[5-10]" -ForegroundColor Green -BackgroundColor Black
try {
    # backup
    if (Test-Path $profile) { Rename-Item $profile -NewName Microsoft.PowerShell_profile.ps1.bak }

    $originPath = "$HOME\OneDrive\Documents\PowerShell\"
    $destinationPath = "$HOME\repos\dotfiles\Windows\PowerShell"

    # delete the folder if it exists
    $LocalStateExits = Test-Path $originPath
    if ($LocalStateExits) {
        Remove-Item $originPath -Recurse -Force
    }

    # symlink the settings.json
    New-Item -ItemType Junction -Path $originPath -Target $destinationPath
}
catch { Write-Warning $_ }

# todo:
# Oh-My-Posh install, add to default prompt, add theme
# npm -g install
