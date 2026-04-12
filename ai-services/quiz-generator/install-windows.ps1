# Quiz Generator - Windows install helper.
# Run from repo root: npm run quiz:install

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

if (-not (Test-Path .venv)) {
    python -m venv .venv
}

& .\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
pip install -r requirements.txt

Write-Host ""
Write-Host "Done. Activate with:  .\.venv\Scripts\Activate.ps1"
Write-Host "Then run:              uvicorn app.main:app --reload --host 127.0.0.1 --port 8001"
Write-Host "Make sure MY_API_KEY exists in your .env"
