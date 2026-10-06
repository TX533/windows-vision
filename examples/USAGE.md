# Windows Vision — Ejemplos de uso

El script principal es `scripts/windows-vision-clean.ps1`.

## Captura

```powershell
# Captura de pantalla completa
.\scripts\windows-vision-clean.ps1 capture -Full

# Captura de una región (x,y,ancho,alto)
.\scripts\windows-vision-clean.ps1 capture -Region "0,0,800,600"

# Guardar en una ruta específica
.\scripts\windows-vision-clean.ps1 capture -Full -Output "mi_captura.png"
```

Las capturas se guardan por defecto en `%USERPROFILE%\.openclaw\workspace\windows-vision-output`.

## OCR

> Requiere Tesseract instalado: `winget install Tesseract.TesseractOCR`

```powershell
# OCR sobre una imagen (idioma por defecto: eng)
.\scripts\windows-vision-clean.ps1 ocr -InputFile screenshot.png

# OCR en español
.\scripts\windows-vision-clean.ps1 ocr -InputFile documento.png -Lang spa

# OCR multi-idioma
.\scripts\windows-vision-clean.ps1 ocr -InputFile foto.png -Lang eng+spa
```

El resultado se guarda en un `.txt` junto a la imagen.

## OBS

```powershell
# Genera una guía de configuración + un .bat para lanzar OBS
.\scripts\windows-vision-clean.ps1 stream -SetupOBS
```

## Ventanas

```powershell
# Lista las ventanas abiertas
.\scripts\windows-vision-clean.ps1 automate -ListWindows
```

## Flujo combinado: captura + OCR

```powershell
# 1. Capturar
.\scripts\windows-vision-clean.ps1 capture -Full

# 2. Aplicar OCR a la última captura
$last = Get-ChildItem "$env:USERPROFILE\.openclaw\workspace\windows-vision-output\*.png" |
        Sort-Object LastWriteTime -Descending | Select-Object -First 1
.\scripts\windows-vision-clean.ps1 ocr -InputFile $last.FullName -Lang spa
```

## Uso como .bat (para quien no usa PowerShell)

```batch
REM Captura simple
scripts\vision-simple.bat
```
