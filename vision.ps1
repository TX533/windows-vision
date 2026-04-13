# Windows Vision - Main Entry Point
# Version: 1.0.0
# Description: Screen capture and OCR tool for Windows

param(
    [string]$Command = "help",
    [string]$Target,
    [string]$Output,
    [switch]$Verbose
)

# Configuration
$ScriptDir = $PSScriptRoot
$Version = "1.0.0"

function Show-Help {
    Write-Host "Windows Vision v$Version" -ForegroundColor Cyan
    Write-Host "=========================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage: vision <command> [options]"
    Write-Host ""
    Write-Host "Commands:"
    Write-Host "  capture [window|region|full]  - Capture screen/window/region"
    Write-Host "  ocr <image>                   - Extract text from image"
    Write-Host "  stream <url>                  - Stream to OBS/RTMP"
    Write-Host "  automate <script>             - Run automation script"
    Write-Host "  help                          - Show this help"
    Write-Host "  version                       - Show version"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  vision capture window Chrome"
    Write-Host "  vision ocr screenshot.png"
    Write-Host "  vision stream rtmp://localhost/live"
    Write-Host ""
}

function Show-Version {
    Write-Host "Windows Vision v$Version" -ForegroundColor Green
}

function Invoke-Capture {
    param([string]$Type = "full", [string]$WindowName)
    
    Write-Host "Capturing $Type..." -ForegroundColor Yellow
    # Delegate to capture script
    & "$ScriptDir\scripts\vision-fixed.ps1" -Capture -Type $Type -Window $WindowName
}

function Invoke-OCR {
    param([string]$ImagePath)
    
    if (-not (Test-Path $ImagePath)) {
        Write-Host "Error: Image not found: $ImagePath" -ForegroundColor Red
        return
    }
    
    Write-Host "Extracting text from $ImagePath..." -ForegroundColor Yellow
    # Delegate to OCR functionality
    & "$ScriptDir\scripts\vision-fixed.ps1" -OCR -Image $ImagePath
}

# Main command dispatcher
switch ($Command.ToLower()) {
    "help" { Show-Help }
    "version" { Show-Version }
    "capture" { Invoke-Capture -Type $Target }
    "ocr" { Invoke-OCR -ImagePath $Target }
    "stream" { Write-Host "Streaming to: $Target" -ForegroundColor Yellow }
    "automate" { Write-Host "Running automation: $Target" -ForegroundColor Yellow }
    default {
        Write-Host "Unknown command: $Command" -ForegroundColor Red
        Show-Help
    }
}
