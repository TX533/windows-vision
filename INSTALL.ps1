# Windows Vision Installer
Write-Host "=== Windows Vision Installer ===" -ForegroundColor Cyan
Write-Host ""

# Check requirements
Write-Host "Checking requirements..." -ForegroundColor Yellow

# Check PowerShell version
if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Host "❌ PowerShell 5.1 or higher required" -ForegroundColor Red
    exit 1
}

Write-Host "✅ PowerShell $($PSVersionTable.PSVersion)" -ForegroundColor Green

# Check admin rights (recommended)
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "⚠️  Running without administrator privileges" -ForegroundColor Yellow
    Write-Host "   Some features may require admin rights" -ForegroundColor Gray
}

# Create installation directory
$installDir = "$env:USERPROFILE\.windows-vision"
if (-not (Test-Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir -Force | Out-Null
    Write-Host "✅ Created installation directory: $installDir" -ForegroundColor Green
}

# Copy files
Write-Host ""
Write-Host "Copying files..." -ForegroundColor Yellow

# Here you would copy the actual files
# For now, just create a placeholder
$readmeContent = @"
# Windows Vision

Thank you for installing Windows Vision!

To get started:
1. Open PowerShell
2. Run: vision --help
3. Check documentation at: https://github.com/TX533/windows-vision

For support:
- GitHub Issues: https://github.com/TX533/windows-vision/issues
- Email: support@windowsvision.pro
"@

Set-Content -Path "$installDir\README.txt" -Value $readmeContent
Write-Host "✅ Files copied to: $installDir" -ForegroundColor Green

# Add to PATH (user level)
Write-Host ""
Write-Host "Adding to PATH..." -ForegroundColor Yellow

$userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
if ($userPath -notlike "*$installDir*") {
    [Environment]::SetEnvironmentVariable("PATH", "$userPath;$installDir", "User")
    Write-Host "✅ Added to user PATH" -ForegroundColor Green
}

# Create alias in PowerShell profile
Write-Host ""
Write-Host "Creating PowerShell alias..." -ForegroundColor Yellow

$profileDir = Split-Path $PROFILE -Parent
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

$aliasCommand = @"
# Windows Vision alias
function vision {
    param(
        [string]`$Command = "help"
    )
    
    `$scriptPath = "$installDir\windows-vision.ps1"
    if (Test-Path `$scriptPath) {
        & `$scriptPath @args
    } else {
        Write-Host "Windows Vision not found. Reinstall or check path." -ForegroundColor Red
    }
}
"@

Add-Content -Path $PROFILE -Value $aliasCommand -ErrorAction SilentlyContinue
Write-Host "✅ PowerShell alias created" -ForegroundColor Green

# Final message
Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "🎉 INSTALLATION COMPLETE!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor White
Write-Host "1. Restart PowerShell or open a new window" -ForegroundColor Gray
Write-Host "2. Run: vision --help" -ForegroundColor Gray
Write-Host "3. Visit: https://github.com/TX533/windows-vision" -ForegroundColor Gray
Write-Host ""
Write-Host "Need help?" -ForegroundColor White
Write-Host "• GitHub: https://github.com/TX533/windows-vision/issues" -ForegroundColor Gray
Write-Host "• Email: support@windowsvision.pro" -ForegroundColor Gray
Write-Host "=========================================" -ForegroundColor Cyan