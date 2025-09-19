# 35-fix-db-url.ps1
# Ensures DATABASE_URL is quoted properly and Prisma can read it.

$envPath = "C:\website\.env.local"

# Load .env.local
$content = Get-Content $envPath

# Fix DATABASE_URL line
$fixed = $content -replace '^(DATABASE_URL=)(.*)$', 'DATABASE_URL="$2"'

# Write back
$fixed | Set-Content -Path $envPath -Encoding utf8

Write-Host "✅ Fixed DATABASE_URL line in .env.local"

# Export env var for this session
$match = $fixed | Select-String '^DATABASE_URL="(.+)"'
if ($match) {
  $dbUrl = $match.Matches[0].Groups[1].Value
  $env:DATABASE_URL = $dbUrl
  Write-Host "✅ Exported DATABASE_URL to session"
}

# Run Prisma checks
Write-Host "==> Running prisma generate..."
npx prisma generate

Write-Host "==> Deploying migrations to Neon..."
npx prisma migrate deploy

Write-Host "==> Done. Try: npx prisma studio"
