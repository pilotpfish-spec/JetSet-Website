# 21-vercel-deploy.ps1
# Deploy the Next.js app to Vercel (production) — cloud build (no --prebuilt)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# 1) Build locally just to sanity-check (optional but nice)
Write-Host "==> Building project before deploy…"
& "$env:ProgramFiles\nodejs\npm.cmd" run build
if ($LASTEXITCODE -ne 0) { throw "Build failed (code $LASTEXITCODE)" }

# 2) Deploy using the Windows launcher for Vercel
$vercelCmd = Join-Path $env:APPDATA "npm\vercel.cmd"
$npxCmd    = Join-Path $env:ProgramFiles "nodejs\npx.cmd"

Write-Host "==> Deploying to Vercel (production)…"
if (Test-Path $vercelCmd) {
  & $vercelCmd --prod --yes
} else {
  & $npxCmd vercel --prod --yes
}

if ($LASTEXITCODE -ne 0) { throw "Vercel deploy failed (code $LASTEXITCODE)" }

Write-Host "OK: Vercel deploy complete."
