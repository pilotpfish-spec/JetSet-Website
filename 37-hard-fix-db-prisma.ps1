# 37b-hard-fix-db-prisma.ps1
# One-shot: read DB URL, normalize, write clean .env, validate & deploy.

$root = "C:\website"
$envLocal = Join-Path $root ".env.local"
$envFile  = Join-Path $root ".env"

function FindDbUrl {
  param([string]$path)
  if (!(Test-Path $path)) { return $null }
  $line = (Get-Content $path | Where-Object { $_ -match '^\s*DATABASE_URL\s*=' } | Select-Object -First 1)
  if ($line) { return ($line -replace '^\s*DATABASE_URL\s*=\s*', '') }
  return $null
}

# 1) Find DATABASE_URL (env.local > .env > session)
$db = FindDbUrl $envLocal
if (-not $db) { $db = FindDbUrl $envFile }
if (-not $db -and $env:DATABASE_URL) { $db = $env:DATABASE_URL }

if (-not $db) {
  Write-Error "DATABASE_URL not found. Put your Neon URL in $envFile as:`nDATABASE_URL=postgresql://...."
  exit 1
}

# 2) Normalize (trim + strip wrapping quotes/backticks + any inner quotes)
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

# 4) Ensure .env contains a clean DATABASE_URL (no quotes)
$lines = @()
if (Test-Path $envFile) { $lines = Get-Content $envFile }
$updated = @()
$done = $false
foreach ($l in $lines) {
  if ($l -match '^\s*DATABASE_URL\s*=') {
    $updated += "DATABASE_URL=$db"
    $done = $true
  } else {
    $updated += $l
  }
}
if (-not $done) {
  if ($updated.Count -gt 0) { $updated += "" }
  $updated += "DATABASE_URL=$db"
}
$updated | Set-Content -Path $envFile -Encoding UTF8
Write-Host "✅ Wrote clean DATABASE_URL to .env"

# 5) Export for current session
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

Write-Host "`n✅ Done. Open Studio if you want:  npx prisma studio"
