# Windows Vision

**Captura de pantalla y OCR para Windows — 100% offline, código abierto.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-Windows-0078D6?logo=windows)](https://www.microsoft.com/windows)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue?logo=powershell)](https://github.com/PowerShell/PowerShell)
[![Issues](https://img.shields.io/github/issues/TX533/windows-vision)](https://github.com/TX533/windows-vision/issues)
[![Last Commit](https://img.shields.io/github/last-commit/TX533/windows-vision)](https://github.com/TX533/windows-vision/commits/main)

> Herramienta ligera de captura de pantalla con OCR opcional. Hecha para Windows, en PowerShell. Sin nube, sin suscripciones: tus datos se quedan en tu máquina.

---

## Estado del proyecto

Este proyecto está en **desarrollo temprano (v1.0)**. Es honesto decirte qué funciona y qué no:

| Función | Estado |
|---------|--------|
| Captura de pantalla completa | ✅ Funciona |
| Captura de región (x,y,width,height) | ✅ Funciona |
| OCR vía Tesseract | ✅ Funciona **si** instalas Tesseract (ver abajo) |
| Listado de ventanas | ✅ Básico (vía procesos) |
| Guía de configuración de OBS | ✅ Genera guía + .bat |
| Captura de ventana específica por nombre | ⚠️ Experimental |
| Streaming directo a RTMP | ❌ No implementado (solo guía OBS) |
| Automatización de flujos | ❌ No implementado |

Si algo no aparece como funcional, es porque todavía no lo está. Preferimos decirlo.

---

## Requisitos

- **Windows 10/11** (64-bit)
- **PowerShell 5.1+** (viene incluido en Windows)
- **Tesseract OCR** — *opcional*, solo para la función de OCR
  ```powershell
  winget install Tesseract.TesseractOCR
  ```

---

## Instalación

### Opción 1: Clonar el repositorio (recomendado)
```powershell
git clone https://github.com/TX533/windows-vision.git
cd windows-vision
```

> **Nota de seguridad:** recomendamos clonar y revisar el código antes de ejecutarlo. No publicamos instaladores de un-línea (`irm | iex`) a propósito.

---

## Uso

El script principal es `scripts/windows-vision-clean.ps1`.

```powershell
# Ver ayuda
.\scripts\windows-vision-clean.ps1 help

# Captura de pantalla completa
.\scripts\windows-vision-clean.ps1 capture -Full

# Captura de una región (x,y,ancho,alto)
.\scripts\windows-vision-clean.ps1 capture -Region "0,0,800,600"

# OCR sobre una imagen (requiere Tesseract)
.\scripts\windows-vision-clean.ps1 ocr -InputFile screenshot.png -Lang spa

# Generar guía de configuración de OBS
.\scripts\windows-vision-clean.ps1 stream -SetupOBS

# Ver ventanas abiertas
.\scripts\windows-vision-clean.ps1 automate -ListWindows
```

Las capturas se guardan por defecto en `%USERPROFILE%\.openclaw\workspace\windows-vision-output`.

---

## Estructura del proyecto

```
windows-vision/
├── scripts/
│   ├── windows-vision-clean.ps1   # Script principal (recomendado)
│   ├── vision-fixed.ps1           # Script alternativo
│   └── vision-simple.bat          # Atajo para .bat
├── examples/
│   └── USAGE.md                   # Ejemplos de uso
├── .github/
│   ├── ISSUE_TEMPLATE/            # Plantillas de issues
│   ├── workflows/ci.yml           # Validación de sintaxis en CI
│   └── PULL_REQUEST_TEMPLATE.md
├── config.json                    # Configuración
├── CONTRIBUTING.md                # Guía de contribución
└── LICENSE                        # MIT
```

---

## Solución de problemas

**"Tesseract not installed"** → instala con `winget install Tesseract.TesseractOCR` y reinicia PowerShell.

**El OCR devuelve un texto placeholder** → significa que Tesseract no está instalado o no está en el PATH. La función escribe un placeholder para avisarte de esto.

**La captura de región no funciona** → el formato debe ser exactamente `x,y,ancho,alto` (ej. `0,0,800,600`).

---

## Contribuir

¡Las contribuciones son bienvenidas!

1. Haz un **fork** del repositorio
2. Crea una rama (`git checkout -b feature/mi-mejora`)
3. Haz commit (`git commit -m 'Agrega mi mejora'`)
4. Sube la rama (`git push origin feature/mi-mejora`)
5. Abre un **Pull Request**

Ver [CONTRIBUTING.md](CONTRIBUTING.md) para más detalle.

---

## Hoja de ruta

**v1.0 (actual):** captura, OCR opcional, guía OBS, listado de ventanas
**v1.1 (próximo):** captura de ventana por nombre robusta, más opciones de OCR
**v2.0 (futuro):** streaming, automatización, integración con asistentes

---

## Licencia

Este proyecto está bajo la **Licencia MIT** — ver [LICENSE](LICENSE).

Es software libre y completo. No hay "versión de pago": todo el código está aquí y es MIT.

---

## Créditos

- **Tesseract OCR** — motor de OCR
- **Contribuidores** — todos los que ayudaron a mejorarlo

---

*Windows Vision no está afiliado a Microsoft Corporation. Windows es una marca registrada de Microsoft Corporation.*
