# 48-fix-quote-import.ps1
# Fix the quote API import path and rebuild/deploy.

$ErrorActionPreference = "Stop"
Set-Location "C:\website"

$quotePath = "C:\website\app\api\quote\route.ts"

if (!(Test-Path $quotePath)) {
  throw "Missing file: $quotePath"
}

# Backup
$stamp = Get-Date -Format "yyyyMMddHHmmss"
Copy-Item $quotePath "$quotePath.bak.$stamp"

# Read and patch import
$content = Get-Content $quotePath -Raw

# Replace alias import with a reliable relative path
# From app/api/quote/route.ts → ../../../src/lib/fare
$content = $content -replace "from\s+['""]@/src/lib/fare['""]", "from '../../../src/lib/fare'"
$content = $content -replace "from\s+['""]@/lib/fare['""]", "from '../../../src/lib/fare'"

Set-Content $quotePath $content -Encoding UTF8
Write-Host "🔧 Patched import in app/api/quote/route.ts → ../../../src/lib/fare"

# Rebuild
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

# Deploy (assumes already linked to Vercel)
vercel deploy --prod --confirm

Write-Host "`n✅ Import fixed, build successful (if no errors above), and deployment attempted."
