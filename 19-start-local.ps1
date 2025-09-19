param([string]$ProjectRoot = "C:\website")

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
Set-Location $ProjectRoot

# Ensure build exists
if (!(Test-Path ".next")) {
  Write-Host "No .next build found, running production build first..."
  & "$env:ProgramFiles\nodejs\npm.cmd" run build
  if ($LASTEXITCODE -ne 0) {
    throw "Build failed (code $LASTEXITCODE)"
  }
}

Write-Host "==> Starting Next.js in production mode…"
& "$env:ProgramFiles\nodejs\npm.cmd" run start
if ($LASTEXITCODE -ne 0) {
  throw "Start failed (code $LASTEXITCODE)"
}

Write-Host "OK: Next.js running at http://localhost:3000"
