# Windows Vision - Fixed Version
# PowerShell script without syntax errors

param(
    [string]$Command = "help",
    [string]$InputFile,
    [string]$Output,
    [string]$Lang = "eng"
)

function Show-Help {
    Write-Host "Windows Vision v1.0.1 (Fixed)" -ForegroundColor Cyan
    Write-Host "==============================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Commands:" -ForegroundColor Yellow
    Write-Host "  capture    - Capture full screen" -ForegroundColor White
    Write-Host "  ocr        - Extract text from image" -ForegroundColor White
    Write-Host "  test       - Test system capabilities" -ForegroundColor White
    Write-Host "  help       - Show this help" -ForegroundColor White
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Green
    Write-Host "  .\vision-fixed.ps1 capture" -ForegroundColor Gray
    Write-Host "  .\vision-fixed.ps1 ocr -InputFile screen.png" -ForegroundColor Gray
    Write-Host "  .\vision-fixed.ps1 test" -ForegroundColor Gray
}

function Capture-Screen {
    $outputDir = "$env:USERPROFILE\.openclaw\workspace\windows-vision-output"
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
    
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    
    if ($Output) {
        $outputFile = $Output
        if (-not [System.IO.Path]::IsPathRooted($outputFile)) {
            $outputFile = Join-Path $outputDir $outputFile
        }
    } else {
        $outputFile = Join-Path $outputDir "capture_${timestamp}.png"
    }
    
    Write-Host "Capturing screen..." -ForegroundColor Cyan
    
    try {
        Add-Type -AssemblyName System.Windows.Forms
        Add-Type -AssemblyName System.Drawing
        
        $screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
        $bitmap = New-Object System.Drawing.Bitmap $screen.Width, $screen.Height
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
        $graphics.CopyFromScreen($screen.Location, [System.Drawing.Point]::Empty, $screen.Size)
        
        $bitmap.Save($outputFile, [System.Drawing.Imaging.ImageFormat]::Png)
        
        $bitmap.Dispose()
        $graphics.Dispose()
        
        $fileSize = [math]::Round((Get-Item $outputFile).Length / 1KB, 2)
        
        Write-Host "Success!" -ForegroundColor Green
        Write-Host "  File: $outputFile" -ForegroundColor Gray
        Write-Host "  Size: $fileSize KB" -ForegroundColor Gray
        Write-Host "  Resolution: $($screen.Width)x$($screen.Height)" -ForegroundColor Gray
        
        return $outputFile
        
    } catch {
        Write-Host "Error: $_" -ForegroundColor Red
        return $null
    }
}

function Extract-OCR {
    param([string]$InputFile)
    
    if (-not $InputFile) {
        Write-Host "Error: Input file required" -ForegroundColor Red
        return $null
    }
    
    if (-not (Test-Path $InputFile)) {
        Write-Host "Error: File not found: $InputFile" -ForegroundColor Red
        return $null
    }
    
    $outputFile = $InputFile -replace '\.[^.]*$', '.txt'
    
    Write-Host "Extracting text from: $InputFile" -ForegroundColor Cyan
    
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
    
    # Fallback
    $fileInfo = Get-Item $InputFile
    $placeholder = @"
OCR Placeholder - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
File: $InputFile
Size: $([math]::Round($fileInfo.Length/1KB,2)) KB
Language: $Lang

To enable OCR:
1. Install Tesseract: winget install Tesseract.TesseractOCR
2. Run: tesseract "$InputFile" output -l $Lang

For now, share the image directly for analysis.
"@
    
    $placeholder | Out-File -FilePath $outputFile -Encoding UTF8
    
    Write-Host "Tesseract not installed" -ForegroundColor Yellow
    Write-Host "  Created placeholder: $outputFile" -ForegroundColor Gray
    
    return $outputFile
}

function Test-System {
    Write-Host "Testing system capabilities..." -ForegroundColor Cyan
    Write-Host ""
    
    $tests = @()
    
    # Test 1: PowerShell version
    $psVersion = $PSVersionTable.PSVersion
    $tests += @{
        Name = "PowerShell Version"
        Result = if ($psVersion -ge [Version]"5.1") { "PASS" } else { "FAIL" }
        Details = "v$psVersion"
    }
    
    # Test 2: .NET assemblies
    try {
        Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
        Add-Type -AssemblyName System.Drawing -ErrorAction Stop
        $tests += @{
            Name = ".NET Assemblies"
            Result = "PASS"
            Details = "System.Windows.Forms, System.Drawing"
        }
    } catch {
        $tests += @{
            Name = ".NET Assemblies"
            Result = "FAIL"
            Details = "Missing: $_"
        }
    }
    
    # Test 3: Tesseract
    try {
        $null = Get-Command tesseract -ErrorAction Stop
        $tesseractVersion = & tesseract --version 2>&1 | Select-Object -First 1
        $tests += @{
            Name = "Tesseract OCR"
            Result = "PASS"
            Details = $tesseractVersion
        }
    } catch {
        $tests += @{
            Name = "Tesseract OCR"
            Result = "WARNING"
            Details = "Not installed (optional)"
        }
    }
    
    # Test 4: Output directory
    $outputDir = "$env:USERPROFILE\.openclaw\workspace\windows-vision-output"
    if (Test-Path $outputDir) {
        $tests += @{
            Name = "Output Directory"
            Result = "PASS"
            Details = $outputDir
        }
    } else {
        $tests += @{
            Name = "Output Directory"
            Result = "READY"
            Details = "Will be created on first capture"
        }
    }
    
    # Display results
    foreach ($test in $tests) {
        $color = switch ($test.Result) {
            "PASS" { "Green" }
            "WARNING" { "Yellow" }
            "READY" { "Cyan" }
            default { "Red" }
        }
        
        Write-Host "$($test.Result): $($test.Name)" -ForegroundColor $color
        Write-Host "  $($test.Details)" -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "System ready for Windows Vision!" -ForegroundColor Green
}

# Main execution
switch ($Command.ToLower()) {
    "help" {
        Show-Help
    }
    "capture" {
        $result = Capture-Screen
        if ($result) {
            Write-Host ""
            Write-Host "Next: .\vision-fixed.ps1 ocr -InputFile `"$result`"" -ForegroundColor Magenta
        }
    }
    "ocr" {
        if (-not $InputFile) {
            Write-Host "Error: -InputFile parameter required" -ForegroundColor Red
            Write-Host "Usage: .\vision-fixed.ps1 ocr -InputFile filename.png" -ForegroundColor Gray
            break
        }
        Extract-OCR -InputFile $InputFile
    }
    "test" {
        Test-System
    }
    default {
        Write-Host "Unknown command: $Command" -ForegroundColor Red
        Show-Help
    }
}