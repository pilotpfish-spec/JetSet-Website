# 50-fix-next-config-and-deploy.ps1
# Fix Next config after "type":"module", rebuild, then guide Vercel deploy.

$ErrorActionPreference = "Stop"
Set-Location "C:\website"

# 1) Fix next.config after ESM switch:
#    If next.config.js uses CommonJS (module.exports/require), rename to .cjs
$nextJs = "C:\website\next.config.js"
$nextMjs = "C:\website\next.config.mjs"
$nextCjs = "C:\website\next.config.cjs"

if (Test-Path $nextJs) {
  $cfg = Get-Content $nextJs -Raw
  if ($cfg -match "module\.exports" -or $cfg -match "\brequire\(") {
    $stamp = Get-Date -Format "yyyyMMddHHmmss"
    Copy-Item $nextJs "$nextJs.bak.$stamp"
    if (Test-Path $nextCjs) { Remove-Item $nextCjs -Force }
    Rename-Item $nextJs "next.config.cjs"
    Write-Host "🔧 Renamed next.config.js → next.config.cjs (kept CommonJS)."
  } else {
    Write-Host "ℹ️ next.config.js appears ESM-friendly; leaving as-is."
  }
} elseif (Test-Path $nextMjs) {
  Write-Host "ℹ️ Using next.config.mjs already; no change."
} elseif (Test-Path $nextCjs) {
  Write-Host "ℹ️ Using next.config.cjs already; no change."
} else {
  Write-Host "⚠️ No Next config found; continuing."
}

# 2) Rebuild
if (Test-Path "C:\website\pnpm-lock.yaml") {
  corepack enable pnpm | Out-Null
  pnpm install
  pnpm build
} elseif (Test-Path "C:\website\package-lock.json") {
  npm ci
  npm run build
} else {
  yarn install --frozen-lockfile
  yarn build
}

Write-Host "`n✅ Build completed (if no errors above)."

# 3) Vercel deploy helper:
#    Newer CLI may not accept --prod here, and you aren't logged in yet.
#    We'll print the exact commands to run next.
Write-Host @"
Next steps to deploy:

1) Log in:
   vercel login

2) Link the folder to your project (only once per machine):
   vercel link --yes

3) Deploy (non-interactive):
   vercel deploy --yes

If you want to target Production explicitly after login/link:
   vercel deploy --yes --scope <your-team-or-user>
   (Then promote if needed with: vercel promote)

Tip: You can still use:
   vercel whoami
to confirm you’re logged in before deploying.
"@
