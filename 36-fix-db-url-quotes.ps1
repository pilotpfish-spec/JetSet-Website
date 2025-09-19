# 36-fix-db-url-quotes.ps1
# Fix DATABASE_URL formatting and re-run Prisma deploy

$envPath = "C:\website\.env.local"

# Read the .env.local file
$content = Get-Content $envPath

# Remove quotes if present on DATABASE_URL
$fixed = $content -replace '^DATABASE_URL="?(.+?)"?$', 'DATABASE_URL=$1'

# Write back to .env.local
$fixed | Set-Content -Path $envPath -Encoding utf8

Write-Host "✅ DATABASE_URL fixed in .env.local"

# Export to current session
$match = $fixed | Select-String '^DATABASE_URL=(.+)$'
if ($match) {
  $dbUrl = $match.Matches[0].Groups[1].Value
  $env:DATABASE_URL = $dbUrl
  Write-Host "✅ Exported DATABASE_URL to session"
}

# Run Prisma commands
Write-Host "==> Running prisma generate..."
npx prisma generate

Write-Host "==> Deploying migrations to Neon..."
npx prisma migrate deploy

Write-Host "==> Done. Try: npx prisma studio"
