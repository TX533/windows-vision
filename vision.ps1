# Windows Vision - Main Entry Point
# Version: 1.0.0
# Description: Punto de entrada. Delega en scripts/windows-vision-clean.ps1

param(
    [string]$Command = "help",
    [string]$Target,
    [string]$Output,
    [string]$Lang = "eng"
)

$ScriptDir = $PSScriptRoot
$MainScript = Join-Path $ScriptDir "scripts\windows-vision-clean.ps1"
$Version = "1.0.0"

function Show-Help {
    Write-Host "Windows Vision v$Version" -ForegroundColor Cyan
    Write-Host "=========================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Este es un wrapper. El script principal es scripts\windows-vision-clean.ps1"
    Write-Host ""
    Write-Host "Uso: vision <comando> [opciones]"
    Write-Host ""
    Write-Host "Comandos:"
    Write-Host "  capture    - Captura de pantalla (-Full o -Region 'x,y,w,h')"
    Write-Host "  ocr        - Extrae texto de una imagen (-InputFile <ruta>)"
    Write-Host "  stream     - Genera guia de OBS (-SetupOBS)"
    Write-Host "  automate   - Lista ventanas (-ListWindows)"
    Write-Host "  help       - Muestra esta ayuda"
    Write-Host ""
    Write-Host "Ejemplos (script principal):"
    Write-Host "  .\scripts\windows-vision-clean.ps1 capture -Full"
    Write-Host "  .\scripts\windows-vision-clean.ps1 ocr -InputFile screenshot.png -Lang spa"
    Write-Host ""
}

# Delegar al script principal pasando los argumentos tal cual
if (-not (Test-Path $MainScript)) {
    Write-Host "Error: no se encontro el script principal: $MainScript" -ForegroundColor Red
    exit 1
}

& $MainScript @args
