# Windows Vision Installer
# Instala Windows Vision copiando los archivos reales y creando un alias `vision`.

$ErrorActionPreference = "Stop"

Write-Host "=== Windows Vision Installer ===" -ForegroundColor Cyan
Write-Host ""

# --- Requisitos ---
Write-Host "Checking requirements..." -ForegroundColor Yellow

if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Host "PowerShell 5.1 or higher required" -ForegroundColor Red
    exit 1
}
Write-Host "  PowerShell $($PSVersionTable.PSVersion) OK" -ForegroundColor Green

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "  Running without admin rights (fine for user-level install)" -ForegroundColor Yellow
}

# --- Directorio de instalacion ---
$installDir = "$env:USERPROFILE\.windows-vision"
if (-not (Test-Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir -Force | Out-Null
    Write-Host "  Created: $installDir" -ForegroundColor Green
}

# --- Copiar archivos reales ---
Write-Host ""
Write-Host "Copying files..." -ForegroundColor Yellow

$scriptDir = $PSScriptRoot
if (-not $scriptDir) { $scriptDir = (Get-Location).Path }

$sourceScript = Join-Path $scriptDir "scripts"
if (Test-Path $sourceScript) {
    Copy-Item -Path $sourceScript -Destination $installDir -Recurse -Force
    Write-Host "  Copied scripts/" -ForegroundColor Green
} else {
    Write-Host "  scripts/ not found in source. Run installer from the repo root." -ForegroundColor Red
    exit 1
}

$mainScript = Join-Path $installDir "scripts\windows-vision-clean.ps1"
if (-not (Test-Path $mainScript)) {
    Write-Host "  Main script missing after copy: $mainScript" -ForegroundColor Red
    exit 1
}

if (Test-Path (Join-Path $scriptDir "config.json")) {
    Copy-Item (Join-Path $scriptDir "config.json") $installDir -Force
    Write-Host "  Copied config.json" -ForegroundColor Green
}
if (Test-Path (Join-Path $scriptDir "LICENSE")) {
    Copy-Item (Join-Path $scriptDir "LICENSE") $installDir -Force
}
Write-Host "  Files installed to: $installDir" -ForegroundColor Green

# --- Alias en el perfil de PowerShell ---
Write-Host ""
Write-Host "Installing PowerShell function 'vision'..." -ForegroundColor Yellow

$profileDir = Split-Path $PROFILE -Parent
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

$marker = "# >>> Windows Vision alias >>>"
$current = if (Test-Path $PROFILE) { Get-Content $PROFILE -Raw } else { "" }

if ($current -notmatch [regex]::Escape($marker)) {
    $aliasCommand = @"

$marker
function vision {
    & "$installDir\scripts\windows-vision-clean.ps1" @args
}
# <<< Windows Vision alias <<<
"@
    Add-Content -Path $PROFILE -Value $aliasCommand
    Write-Host "  Function 'vision' added to $PROFILE" -ForegroundColor Green
} else {
    Write-Host "  Function 'vision' already present in profile" -ForegroundColor Gray
}

# --- Mensaje final ---
Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "INSTALLATION COMPLETE" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor White
Write-Host "1. Open a new PowerShell window" -ForegroundColor Gray
Write-Host "2. Run: vision help" -ForegroundColor Gray
Write-Host ""
Write-Host "OCR is optional. To enable it:" -ForegroundColor White
Write-Host "  winget install Tesseract.TesseractOCR" -ForegroundColor Gray
Write-Host "=========================================" -ForegroundColor Cyan
