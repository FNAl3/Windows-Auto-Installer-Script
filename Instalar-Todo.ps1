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
    "Apache_OpenOffice"  = "/S"
    "CrystalDiskInfo"    = "/VERYSILENT /NORESTART"
    "Cursor Setup"       = "/S"
    "DiscordSetup"       = "/S"
    "GeForce_Experience" = "/s"
    "NTLite_setup"       = "/S"
    "SteamSetup"         = "/S"
    "VSCodeUserSetup"    = "/VERYSILENT /MERGETASKS=!runcode"
    "VirtualBox"         = "--silent"
    "winrar-x64"         = "/S"
    "adksetup"           = "/quiet"
    "dia-setup"          = "/S"
    "lghub_installer"    = "--silent"
    "xampp"              = "--mode unattended"
    "node"               = "/quiet"
    "git"                = "/VERYSILENT"
    "ChromeSetup"        = "/silent /install"
    "Antigravity"        = "/S"
    "League of Legends"  = "--mode unattended"
    "EpicInstaller"      = "/q"
    "EAappInstaller"     = "/quiet"
    "SpotifyFullSetup"   = "/silent"
    "WhatsAppSetup"      = "--silent"
}

# --- SECCIÓN DE DESCARGAS AUTOMÁTICAS ---
# Lista de URLs para descargar si los archivos no existen
$downloadList = @{
    "ChromeSetup.exe"                   = "https://dl.google.com/tag/s/appguid%3D%7B8A69D345-D564-463C-AFF1-A69D9E530F96%7D%26needsadmin%3Dtrue%26ap%3Dx64-stable/chrome/install/ChromeStandaloneSetup64.exe"
    "EpicInstaller.msi"                 = "https://launcher-public-service-prod06.ol.epicgames.com/launcher/api/installer/download/EpicGamesLauncher.msi"
    "EAappInstaller.exe"                = "https://origin-a.akamaihd.net/EA-Desktop-Client-Download/installer-releases/EAappInstaller.exe"
    "Install League of Legends euw.exe" = "https://lol.secure.dyn.riotcdn.net/channels/public/x/installer/current/live.euw.exe"
    "SpotifyFullSetup.exe"              = "https://download.scdn.co/SpotifyFullSetup.exe"
    "WhatsAppSetup.exe"                 = "https://web.whatsapp.com/desktop/windows/release/x64/WhatsAppSetup.exe"
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
# ----------------------------------------

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
# Si existe winrar-x64*.exe, ignoramos WinRAR.msi mediante la $skipList, pero verificamos si hay otros conflictos.
# Para este script, ordenamos por fecha de modificación para asegurar que en caso de duda, instalamos lo más reciente si hubiera duplicados no listados.
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
