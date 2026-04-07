# Attendance AI — Windows install (Python 3.11–3.13).
# Run from this folder:  powershell -ExecutionPolicy Bypass -File .\install-windows.ps1

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

if (-not (Test-Path .venv)) {
    python -m venv .venv
}

& .\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip

# Prebuilt dlib (avoids Visual Studio + CMake). Official PyPI "dlib" often tries to compile and fails on Windows.
pip install dlib-bin

# face_recognition_models needs pkg_resources; very new setuptools removed it from the default layout for some setups.
pip install "setuptools>=65,<70"

# Do not let pip pull "dlib" from PyPI (source build). We already have dlib from dlib-bin.
pip install face-recognition --no-deps
pip install face_recognition_models "Click>=6.0" numpy opencv-contrib-python openpyxl pillow fastapi uvicorn python-multipart

Write-Host ""
Write-Host "Done. Activate with:  .\.venv\Scripts\Activate.ps1"
Write-Host "Then run:              uvicorn api_main:app --reload --host 127.0.0.1 --port 8000"
Write-Host "Put reference face photos in .\dataset\ named like 1.jpg, 2.png (name = student id)."
