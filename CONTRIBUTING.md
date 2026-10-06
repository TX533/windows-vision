# Contribuir a Windows Vision

¡Gracias por tu interés en contribuir!

## Cómo contribuir

### 1. Reportar bugs
- Usa GitHub Issues
- Incluye: versión de Windows, mensaje de error, pasos para reproducir

### 2. Sugerir funciones
- Revisa primero la hoja de ruta en el README
- Explica el caso de uso
- Si puedes, propón una implementación

### 3. Enviar código
- Haz fork del repositorio
- Crea una rama (`git checkout -b feature/mi-mejora`)
- Commits claros
- Abre un Pull Request

## Estructura del código

```
scripts/
├── windows-vision-clean.ps1   # Script principal
├── vision-fixed.ps1           # Script alternativo
└── vision-simple.bat          # Atajo .bat

examples/
└── USAGE.md                   # Ejemplos
```

## Pruebas

Antes de enviar, valida la sintaxis de tus scripts:

```powershell
Get-ChildItem -Filter *.ps1 -Recurse | ForEach-Object {
    $errs = $null
    [System.Management.Automation.PSParser]::Tokenize((Get-Content $_.FullName -Raw), [ref]$errs)
    if ($errs.Count) { Write-Host "Errores en $($_.Name)" }
}
```

## Estilo de código
- Indentación: 4 espacios
- Nombres: PascalCase para funciones
- Comentarios: inglés preferido
- Manejo de errores: try/catch

## Preguntas
Abre un Issue en el repositorio.
