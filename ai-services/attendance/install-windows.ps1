# Attendance AI - Windows install (Python 3.11 to 3.13).
# Run from this folder:  powershell -ExecutionPolicy Bypass -File .\install-windows.ps1

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

$venvPython = Join-Path $PSScriptRoot ".venv\Scripts\python.exe"

# Recreate venv if missing or broken (folder exists but Scripts\python.exe does not)
if (-not (Test-Path $venvPython)) {
    if (Test-Path ".venv") {
        Write-Host "Removing incomplete .venv folder..."
        Remove-Item -Recurse -Force ".venv"
    }
    Write-Host "Creating Python virtual environment..."
    python -m venv .venv
    if (-not (Test-Path $venvPython)) {
        throw "venv creation failed: python.exe not found in .venv. Is python on PATH (use 3.11-3.13)?"
    }
}

# Use venv Python directly (no Activate.ps1 - avoids missing or blocked activation scripts)
& $venvPython -m pip install --upgrade pip

# Prebuilt dlib (avoids Visual Studio + CMake). Official PyPI "dlib" often tries to compile and fails on Windows.
& $venvPython -m pip install dlib-bin

# face_recognition_models needs pkg_resources; very new setuptools removed it from the default layout for some setups.
& $venvPython -m pip install "setuptools>=65,<70"

# Do not let pip pull "dlib" from PyPI (source build). We already have dlib from dlib-bin.
& $venvPython -m pip install face-recognition --no-deps
& $venvPython -m pip install face_recognition_models "Click>=6.0" numpy opencv-contrib-python openpyxl pillow fastapi uvicorn python-multipart

Write-Host ""
Write-Host "If pip warned that face-recognition needs dlib: ignore it - dlib-bin provides import dlib (pip only checks the package name dlib)."
Write-Host ""
Write-Host "Done. Run the service from repo root:  npm run attendance"
Write-Host "Or manually:  .\.venv\Scripts\python.exe -m uvicorn api_main:app --reload --host 127.0.0.1 --port 8000"
Write-Host "Put reference face photos in .\dataset\ named like 1.jpg, 2.png (name = student id)."
