# 37b-hard-fix-db-prisma.ps1
# Reads DATABASE_URL (from .env.local, .env, or env), normalizes it,
# writes a clean .env Prisma will read, then validate -> deploy -> generate.

$root = "C:\website"
$envLocal = Join-Path $root ".env.local"
$envFile  = Join-Path $root ".env"

function Find-DbUrl {
  param([string]$path)
  if (!(Test-Path $path)) { return $null }
  $line = (Get-Content $path | Where-Object { $_ -match '^\s*DATABASE_URL\s*=' } | Select-Object -First 1)
  if ($line) { return ($line -replace '^\s*DATABASE_URL\s*=\s*', '') }
  return $null
}

# 1) Find DATABASE_URL (env.local > .env > process env)
$db = Find-DbUrl $envLocal
if (-not $db) { $db = Find-DbUrl $envFile }
if (-not $db -and $env:DATABASE_URL) { $db = $env:DATABASE_URL }

if (-not $db) {
  Write-Error "DATABASE_URL not found. Put your Neon URL into .env as:`nDATABASE_URL=postgresql://<...connection...>"
  exit 1
}

# 2) Normalize (trim, strip wrapping quotes/backticks, remove inner quotes)
$db = $db.Trim()
if (($db.StartsWith('"') -and $db.EndsWith('"')) -or
    ($db.StartsWith("'") -and $db.EndsWith("'")) -or
    ($db.StartsWith('`') -and $db.EndsWith('`'))) {
  $db = $db.Substring(1, $db.Length-2)
}
$db = $db -replace '"',''

# 3) Quick protocol check
if ($db -notmatch '^(postgresql|postgres)://') {
  Write-Error "Invalid DATABASE_URL. Must start with postgresql:// or postgres://`nGot: $db"
  exit 1
}

# 4) Ensure .env contains clean DATABASE_URL (no quotes)
$lines = @()
if (Test-Path $envFile) { $lines = Get-Content $envFile }
$updated = @()
$replaced = $false
foreach ($l in $lines) {
  if ($l -match '^\s*DATABASE_URL\s*=') {
    $updated += "DATABASE_URL=$db"
    $replaced = $true
  } else {
    $updated += $l
  }
}
if (-not $replaced) {
  if ($updated.Count -gt 0) { $updated += "" }
  $updated += "DATABASE_URL=$db"
}
$updated | Set-Content -Path $envFile -Encoding UTF8
Write-Host "✅ Wrote clean DATABASE_URL to .env"

# 5) Export for this session
$env:DATABASE_URL = $db
Write-Host "✅ Exported DATABASE_URL to session"

# 6) Prisma: validate -> deploy -> generate
Write-Host "==> prisma validate..."
npx prisma validate
if ($LASTEXITCODE -ne 0) { exit 1 }

Write-Host "==> prisma migrate deploy..."
npx prisma migrate deploy
if ($LASTEXITCODE -ne 0) { exit 1 }

Write-Host "==> prisma generate..."
npx prisma generate

Write-Host "`n✅ Done. Open Studio (optional):  npx prisma studio"
