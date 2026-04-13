# Windows Vision - Examples
# ========================

## Basic Capture
```powershell
# Capture full screen
.\vision.ps1 capture full

# Capture Chrome window
.\vision.ps1 capture window "Chrome"

# Capture specific region (interactive)
.\vision.ps1 capture region
```

## OCR Examples
```powershell
# Extract text from image
.\vision.ps1 ocr screenshot.png

# Extract with specific language
$env:TESSERACT_LANG = "spa"
.\vision.ps1 ocr medical_document.png
```

## Automation Example
Create a file `automate-medical.ps1`:
```powershell
# Capture consultation area
.\vision.ps1 capture region

# Extract text
$text = .\vision.ps1 ocr capture.png

# Process with AI (OpenClaw integration)
# ... AI processing code ...
```

## Integration with OpenClaw
```powershell
# Use as OpenClaw skill
openclaw vision capture window "EMR System"
openclaw vision ocr patient_chart.png
```

## Batch File Usage (for non-PowerShell users)
```batch
REM Simple capture
vision-simple.bat

REM Capture with OCR
vision-simple.bat /ocr
```
