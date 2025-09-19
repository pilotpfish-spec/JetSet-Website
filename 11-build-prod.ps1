# 11-build-prod.ps1
param([string]$ProjectRoot = "C:\website")
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
Set-Location $ProjectRoot

$npm = Join-Path $env:ProgramFiles "nodejs\npm.cmd"
if (!(Test-Path $npm)) { throw "npm.cmd not found at $npm" }

Write-Host "==> Building Next.js (production)…"
& $npm run build
if ($LASTEXITCODE -ne 0) { throw "Build failed (code $LASTEXITCODE)" }

Write-Host "OK: Build complete."
