<#
.SYNOPSIS
    Script de instalación automatizada para la carpeta de instaladores.
    Instala la última versión de los programas encontrados.

.DESCRIPTION
    Este script recorre la carpeta actual, identifica instaladores conocidos (.exe, .msi)
    y ejecuta su instalación silenciosa (desatendida) cuando es posible.
    Filtra versiones antiguas si detecta duplicados (ej. WinRAR).

.NOTES
    Requiere permisos de Administrador.
#>

# Asegurar permisos de administrador
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {  
    Write-Warning "Este script requiere permisos de administrador para instalar programas."
    Write-Warning "Por favor, ejecute PowerShell como Administrador."
    Start-Sleep -Seconds 5
    Break
}

$ErrorActionPreference = "SilentlyContinue"
$scriptPath = $PSScriptRoot
Write-Host "Iniciando instalación masiva desde: $scriptPath" -ForegroundColor Cyan

# Definición de argumentos de instalación silenciosa para archivos conocidos
$installArgs = @{
    "Apache_OpenOffice"  = "/qn TARGETDIR=`"D:\Program Files\OpenOffice`""
    "CrystalDiskInfo"    = "/VERYSILENT /NORESTART /DIR=`"D:\Program Files\CrystalDiskInfo`""
    "Cursor Setup"       = "/S"
    "DiscordSetup"       = "/S"
    "GeForce_Experience" = "/s"
    "NTLite_setup"       = "/VERYSILENT /NORESTART /DIR=`"D:\Program Files\NTLite`""
    "SteamSetup"         = "/S /D=D:\Program Files\Steam"
    "VSCodeUserSetup"    = "/VERYSILENT /MERGETASKS=!runcode /DIR=`"D:\Program Files\Microsoft VS Code`""
    "VirtualBox"         = "--silent"
    "winrar-x64"         = "/S"
    "adksetup"           = "/quiet /installpath `"D:\Program Files\Windows Kits\10`" /norestart /features OptionId.DeploymentTools"
    "dia-setup"          = "/S /D=`"D:\Program Files\Dia`""
    "lghub_installer"    = "--silent"
    "xampp"              = "--mode unattended --prefix `"D:\xampp`""
    "node"               = "/quiet INSTALLDIR=`"D:\Program Files\nodejs`""
    "git"                = "/VERYSILENT /DIR=`"D:\Program Files\Git`""
    "ChromeSetup"        = "/silent /install"
    "Antigravity"        = "/S"
    "League of Legends"  = "--mode unattended"
    "EpicInstaller"      = "/q TARGETDIR=`"D:\Program Files\Epic Games`""
    "EAappInstaller"     = "/quiet"
    "SpotifyFullSetup"   = "/silent"
    "WhatsAppSetup"      = "--silent"
    "BsgLauncher"        = "/S" 
    "WarThunderLauncher" = "/S"
    "nmap"               = "/S"
    "GoogleDriveSetup"   = "--silent"
    "OpenVPN"            = "/qn TARGETDIR=`"D:\Program Files\OpenVPN`""
    "krita"              = "/S"
    "Docker Desktop"     = "install --quiet --accept-license --installation-dir=`"D:\Program Files\Docker\Docker`""
    "ObsidianSetup"      = "/S"
}

# --- SECCIÓN DE DESCARGAS AUTOMÁTICAS ---
$downloadList = @{
    "ChromeSetup.exe"                   = "https://dl.google.com/tag/s/appguid%3D%7B8A69D345-D564-463C-AFF1-A69D9E530F96%7D%26needsadmin%3Dtrue%26ap%3Dx64-stable/chrome/install/ChromeStandaloneSetup64.exe"
    "EpicInstaller.msi"                 = "https://launcher-public-service-prod06.ol.epicgames.com/launcher/api/installer/download/EpicGamesLauncher.msi"
    "EAappInstaller.exe"                = "https://origin-a.akamaihd.net/EA-Desktop-Client-Download/installer-releases/EAappInstaller.exe"
    "Install League of Legends euw.exe" = "https://lol.secure.dyn.riotcdn.net/channels/public/x/installer/current/live.euw.exe"
    "SpotifyFullSetup.exe"              = "https://download.scdn.co/SpotifyFullSetup.exe"
    "WhatsAppSetup.exe"                 = "https://web.whatsapp.com/desktop/windows/release/x64/WhatsAppSetup.exe"
    "WarThunderLauncher.exe"            = "https://yupmaster.gaijinent.com/launcher/current.php?id=WarThunderLauncher"
    "nmap-setup.exe"                    = "https://nmap.org/dist/nmap-7.94-setup.exe"
    "GoogleDriveSetup.exe"              = "https://dl.google.com/drive-file-stream/GoogleDriveSetup.exe"
    "OpenVPNConnect.msi"                = "https://openvpn.net/downloads/openvpn-connect-v3-windows.msi"
    "Docker Desktop Installer.exe"      = "https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe"
    "ObsidianSetup.exe"                 = "https://github.com/obsidianmd/obsidian-releases/releases/download/v1.10.6/Obsidian.1.10.6.exe"
    "Apache_OpenOffice.exe"             = "https://sourceforge.net/projects/openofficeorg.mirror/files/4.1.15/binaries/es/Apache_OpenOffice_4.1.15_Win_x86_install_es.exe/download"
    "CrystalDiskInfo.exe"               = "https://osdn.net/frs/redir.php?m=gigenet&f=crystaldiskinfo%2F78635%2FCrystalDiskInfo9_2_1.exe"
    "SteamSetup.exe"                    = "https://cdn.akamai.steamstatic.com/client/installer/SteamSetup.exe"
    "VSCodeUserSetup.exe"               = "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-user"
    "VirtualBox.exe"                    = "https://download.virtualbox.org/virtualbox/7.0.12/VirtualBox-7.0.12-159484-Win.exe"
    "winrar-x64.exe"                    = "https://www.win-rar.com/fileadmin/winrar-versions/winrar/winrar-x64-624es.exe"
    "dia-setup.exe"                     = "http://dia-installer.de/download/dia-setup-0.97.2-2-unsigned.exe"
    "xampp-installer.exe"               = "https://sourceforge.net/projects/xampp/files/XAMPP%20Windows/8.2.4/xampp-windows-x64-8.2.4-0-VS16-installer.exe/download"
    "node-v20.msi"                      = "https://nodejs.org/dist/v20.10.0/node-v20.10.0-x64.msi"
    "git.exe"                           = "https://github.com/git-for-windows/git/releases/download/v2.43.0.windows.1/Git-2.43.0-64-bit.exe"
    "adksetup.exe"                      = "https://go.microsoft.com/fwlink/?linkid=2196127"
    "NTLite_setup.exe"                  = "https://downloads.ntlite.com/files/NTLite_setup_x64.exe"
}

Write-Host "`n--- Verificando Descargas ---" -ForegroundColor Cyan
foreach ($key in $downloadList.Keys) {
    $targetPath = Join-Path $scriptPath $key
    if (-not (Test-Path $targetPath)) {
        Write-Host "Descargando $key..." -ForegroundColor Yellow
        try {
            Invoke-WebRequest -Uri $downloadList[$key] -OutFile $targetPath -UseBasicParsing
            Write-Host "  -> Descargado." -ForegroundColor Green
        }
        catch {
            Write-Host "  -> Error descargando $key : $_" -ForegroundColor Red
        }
    }
}
Write-Host "---------------------------`n"

# Archivos a ignorar o manejar manualmente
$skipList = @(
    "MediaCreationTool22H2.exe", # Herramienta, no instalador directo
    "WinRAR.msi"                 # Ignorar MSI genérico en favor de la versión 7.00 exe detectada
)

# Función para instalar MSI
function Install-MSI {
    param([string]$FilePath)
    Write-Host "Instalando MSI: $(Split-Path $FilePath -Leaf)..." -ForegroundColor Yellow
    $proc = Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$FilePath`" /qn /norestart" -Wait -PassThru
    if ($proc.ExitCode -eq 0) {
        Write-Host "  -> Instalado correctamente." -ForegroundColor Green
    }
    else {
        Write-Host "  -> Error o reinicio requerido. Código: $($proc.ExitCode)" -ForegroundColor Red
    }
}

# Función para instalar EXE
function Install-EXE {
    param([string]$FilePath)
    $fileName = Split-Path $FilePath -Leaf
    
    # Buscar argumentos
    $args = ""
    foreach ($key in $installArgs.Keys) {
        if ($fileName -match $key) {
            $args = $installArgs[$key]
            break
        }
    }

    Write-Host "Ejecutando EXE: $fileName" -ForegroundColor Yellow
    if ($args) {
        Write-Host "  -> Argumentos silenciosos: $args" -ForegroundColor Gray
        try {
            $proc = Start-Process -FilePath $FilePath -ArgumentList $args -Wait -PassThru
            if ($proc.ExitCode -eq 0) {
                Write-Host "  -> Completado." -ForegroundColor Green
            }
            else {
                Write-Host "  -> Completado con código: $($proc.ExitCode)" -ForegroundColor Magenta
            }
        }
        catch {
            Write-Host "  -> Error al ejecutar: $_" -ForegroundColor Red
        }
    }
    else {
        Write-Host "  -> No se detectaron argumentos silenciosos conocidos. Ejecutando en modo normal..." -ForegroundColor White
        Start-Process -FilePath $FilePath -Wait
    }
}

# Obtener archivos
$files = Get-ChildItem -Path $scriptPath -File | Where-Object { $_.Extension -match "\.(exe|msi)$" }

# Filtrado inteligente de versiones (Caso WinRAR)
$files = $files | Sort-Object LastWriteTime

foreach ($file in $files) {
    if ($skipList -contains $file.Name) {
        Write-Host "Saltando: $($file.Name) (en lista de exclusión)" -ForegroundColor DarkGray
        continue
    }

    if ($file.Extension -eq ".msi") {
        Install-MSI -FilePath $file.FullName
    }
    elseif ($file.Extension -eq ".exe") {
        Install-EXE -FilePath $file.FullName
    }
}

Write-Host "Proceso finalizado." -ForegroundColor Cyan
Pause
