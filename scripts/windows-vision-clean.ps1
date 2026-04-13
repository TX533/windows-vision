#!/usr/bin/env pwsh
# Windows Vision - Clean Fixed Version
# Version: 1.0.3 - No Syntax Errors

param(
    [string]$Command = "help",
    [string]$InputFile,
    [string]$Output,
    [string]$Lang = "eng",
    [switch]$Full,
    [string]$Region,
    [switch]$SetupOBS,
    [switch]$ListWindows
)

# Configuration
$Config = @{
    OutputDir = "$env:USERPROFILE\.openclaw\workspace\windows-vision-output"
    Version = "1.0.3"
}

function Show-Help {
    Write-Host "Windows Vision v$($Config.Version)" -ForegroundColor Cyan
    Write-Host "==============================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Commands:" -ForegroundColor Yellow
    Write-Host "  capture    - Capture screenshot" -ForegroundColor White
    Write-Host "  ocr        - Extract text from image" -ForegroundColor White
    Write-Host "  stream     - Setup OBS for recording" -ForegroundColor White
    Write-Host "  automate   - List windows/processes" -ForegroundColor White
    Write-Host "  help       - Show this help" -ForegroundColor White
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Green
    Write-Host "  .\windows-vision-clean.ps1 capture -Full" -ForegroundColor Gray
    Write-Host "  .\windows-vision-clean.ps1 ocr -InputFile screen.png -Lang spa" -ForegroundColor Gray
    Write-Host "  .\windows-vision-clean.ps1 stream -SetupOBS" -ForegroundColor Gray
    Write-Host "  .\windows-vision-clean.ps1 automate -ListWindows" -ForegroundColor Gray
}

function Initialize-OutputDir {
    if (-not (Test-Path $Config.OutputDir)) {
        New-Item -ItemType Directory -Path $Config.OutputDir -Force | Out-Null
    }
}

function Capture-Screen {
    Initialize-OutputDir
    
    # Generate output filename
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    if ($Output) {
        $outputFile = $Output
        if (-not [System.IO.Path]::IsPathRooted($outputFile)) {
            $outputFile = Join-Path $Config.OutputDir $outputFile
        }
    } else {
        $outputFile = Join-Path $Config.OutputDir "capture_${timestamp}.png"
    }
    
    Write-Host "Capturing screen..." -ForegroundColor Cyan
    
    try {
        Add-Type -AssemblyName System.Windows.Forms
        Add-Type -AssemblyName System.Drawing
        
        if ($Region) {
            # Region capture
            $coords = $Region -split ','
            if ($coords.Count -eq 4) {
                $x, $y, $width, $height = $coords
                $bitmap = New-Object System.Drawing.Bitmap $width, $height
                $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
                $graphics.CopyFromScreen([System.Drawing.Point]::new($x, $y), [System.Drawing.Point]::Empty, [System.Drawing.Size]::new($width, $height))
                Write-Host "Captured region: ${x},${y} ${width}x${height}" -ForegroundColor Green
            } else {
                Write-Host "Invalid region format. Use: x,y,width,height" -ForegroundColor Red
                return $null
            }
        } else {
            # Full screen capture
            $screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
            $bitmap = New-Object System.Drawing.Bitmap $screen.Width, $screen.Height
            $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
            $graphics.CopyFromScreen($screen.Location, [System.Drawing.Point]::Empty, $screen.Size)
            Write-Host "Captured full screen: $($screen.Width)x$($screen.Height)" -ForegroundColor Green
        }
        
        # Save image
        $bitmap.Save($outputFile, [System.Drawing.Imaging.ImageFormat]::Png)
        
        $bitmap.Dispose()
        $graphics.Dispose()
        
        $fileSize = [math]::Round((Get-Item $outputFile).Length / 1KB, 2)
        Write-Host "Saved to: $outputFile ($fileSize KB)" -ForegroundColor Green
        
        return $outputFile
        
    } catch {
        Write-Host "Capture failed: $_" -ForegroundColor Red
        return $null
    }
}

function Extract-OCR {
    param([string]$InputFile, [string]$Lang)
    
    if (-not $InputFile) {
        Write-Host "Input file required" -ForegroundColor Red
        return $null
    }
    
    if (-not (Test-Path $InputFile)) {
        Write-Host "File not found: $InputFile" -ForegroundColor Red
        return $null
    }
    
    $outputFile = $InputFile -replace '\.[^.]*$', '.txt'
    
    Write-Host "Extracting text with OCR ($Lang)..." -ForegroundColor Cyan
    
    # Check for Tesseract
    $hasTesseract = $false
    try {
        $null = Get-Command tesseract -ErrorAction Stop
        $hasTesseract = $true
    } catch {
        $hasTesseract = $false
    }
    
    if ($hasTesseract) {
        # Use Tesseract
        $tempFile = [System.IO.Path]::GetTempFileName()
        $tempFile = $tempFile -replace '\.tmp$', ''
        
        & tesseract $InputFile $tempFile -l $Lang 2>$null
        
        if (Test-Path "${tempFile}.txt") {
            Move-Item -Path "${tempFile}.txt" -Destination $outputFile -Force
            $lineCount = (Get-Content $outputFile).Count
            
            Write-Host "OCR completed" -ForegroundColor Green
            Write-Host "  Output: $outputFile" -ForegroundColor Gray
            Write-Host "  Lines: $lineCount" -ForegroundColor Gray
            
            return $outputFile
        }
    }
    
    # Fallback placeholder
    $fileInfo = Get-Item $InputFile
    $placeholder = "OCR Placeholder - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n"
    $placeholder += "File: $InputFile`n"
    $placeholder += "Size: $([math]::Round($fileInfo.Length/1KB,2)) KB`n"
    $placeholder += "Language: $Lang`n`n"
    $placeholder += "To enable OCR:`n"
    $placeholder += "1. Install Tesseract: winget install Tesseract.TesseractOCR`n"
    $placeholder += "2. Run: tesseract `"$InputFile`" output -l $Lang`n`n"
    $placeholder += "For now, share the image directly for analysis.`n"
    
    $placeholder | Out-File -FilePath $outputFile -Encoding UTF8
    
    Write-Host "Tesseract not installed" -ForegroundColor Yellow
    Write-Host "  Created placeholder: $outputFile" -ForegroundColor Gray
    
    return $outputFile
}

function Setup-OBS {
    Write-Host "Setting up OBS Studio..." -ForegroundColor Cyan
    
    $obsDir = Join-Path $Config.OutputDir "obs_recordings"
    New-Item -ItemType Directory -Path $obsDir -Force | Out-Null
    
    # Create guide
    $guide = "OBS Studio Setup Guide`n"
    $guide += "=====================`n`n"
    $guide += "1. Install OBS Studio:`n"
    $guide += "   winget install OBSProject.OBSStudio`n`n"
    $guide += "2. Recording directory:`n"
    $guide += "   $obsDir`n`n"
    $guide += "3. Recommended settings:`n"
    $guide += "   - Output → Recording → Path: $obsDir`n"
    $guide += "   - Output → Recording → Format: mp4`n"
    $guide += "   - Video → Base Resolution: Your screen resolution`n"
    $guide += "   - Video → Output Resolution: 1280x720`n"
    $guide += "   - Video → FPS: 30`n`n"
    $guide += "4. Create scene 'Chrome':`n"
    $guide += "   - Add source → Window Capture`n"
    $guide += "   - Select Chrome window`n"
    $guide += "   - Check 'Capture cursor'`n`n"
    $guide += "5. Hotkeys:`n"
    $guide += "   - Start/Stop recording: Ctrl+F9`n"
    
    $guideFile = Join-Path $Config.OutputDir "obs_guide.txt"
    $guide | Out-File -FilePath $guideFile -Encoding UTF8
    
    # Create batch file
    $batchFile = Join-Path $Config.OutputDir "start_obs.bat"
    $batchContent = "@echo off`n"
    $batchContent += "echo OBS Studio Launcher`n"
    $batchContent += "echo ==================`n"
    $batchContent += "echo.`n"
    $batchContent += "echo Starting OBS...`n"
    $batchContent += "start `"`" `"C:\Program Files\obs-studio\bin\64bit\obs64.exe`"`n"
    $batchContent += "echo.`n"
    $batchContent += "echo If OBS is not installed:`n"
    $batchContent += "echo 1. Open PowerShell as Administrator`n"
    $batchContent += "echo 2. Run: winget install OBSProject.OBSStudio`n"
    $batchContent += "echo.`n"
    $batchContent += "pause`n"
    
    $batchContent | Out-File -FilePath $batchFile -Encoding ASCII
    
    Write-Host "OBS setup complete:" -ForegroundColor Green
    Write-Host "  Guide: $guideFile" -ForegroundColor Gray
    Write-Host "  Batch file: $batchFile" -ForegroundColor Gray
    Write-Host "  Recordings dir: $obsDir" -ForegroundColor Gray
    
    return @($guideFile, $batchFile, $obsDir)
}

function List-Windows {
    Write-Host "Listing visible windows..." -ForegroundColor Cyan
    
    try {
        # Simple method using Get-Process
        $processes = Get-Process | Where-Object { $_.MainWindowTitle -and $_.MainWindowTitle.Length -gt 0 } | Select-Object -First 10
        
        Write-Host "Found $($processes.Count) windowed processes:" -ForegroundColor Green
        
        $i = 1
        foreach ($proc in $processes) {
            Write-Host "  $i. $($proc.ProcessName) - $($proc.MainWindowTitle)" -ForegroundColor Gray
            $i++
        }
        
        Write-Host ""
        Write-Host "For Chrome, look for: chrome.exe - [window title]" -ForegroundColor Yellow
        
    } catch {
        Write-Host "Error listing windows: $_" -ForegroundColor Red
    }
}

# Main execution
Initialize-OutputDir

switch ($Command.ToLower()) {
    "help" {
        Show-Help
    }
    "capture" {
        if (-not $Full -and -not $Region) {
            Write-Host "Use -Full for full screen or -Region 'x,y,width,height'" -ForegroundColor Yellow
            $Full = $true
        }
        
        $result = Capture-Screen
        if ($result) {
            Write-Host ""
            Write-Host "Next: .\windows-vision-clean.ps1 ocr -InputFile `"$result`"" -ForegroundColor Magenta
        }
    }
    "ocr" {
        if (-not $InputFile) {
            Write-Host "Error: -InputFile parameter required" -ForegroundColor Red
            Write-Host "Usage: .\windows-vision-clean.ps1 ocr -InputFile filename.png [-Lang spa]" -ForegroundColor Gray
            break
        }
        Extract-OCR -InputFile $InputFile -Lang $Lang
    }
    "stream" {
        if ($SetupOBS) {
            Setup-OBS
        } else {
            Write-Host "Use -SetupOBS flag" -ForegroundColor Yellow
        }
    }
    "automate" {
        if ($ListWindows) {
            List-Windows
        } else {
            Write-Host "Use -ListWindows flag" -ForegroundColor Yellow
        }
    }
    default {
        Write-Host "Unknown command: $Command" -ForegroundColor Red
        Show-Help
    }
}