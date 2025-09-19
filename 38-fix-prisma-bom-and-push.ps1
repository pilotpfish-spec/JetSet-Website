# 38-fix-prisma-bom-and-push.ps1
# Strip BOM from prisma\schema.prisma, ensure DATABASE_URL, then validate -> db push -> generate.

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root
$schemaPath = Join-Path $root "prisma\schema.prisma"
if (!(Test-Path $schemaPath)) { throw "Missing prisma\schema.prisma" }

# 1) Remove UTF-8 BOM and any stray U+FEFF, save WITHOUT BOM
$bytes = [System.IO.File]::ReadAllBytes($schemaPath)
if ($bytes.Length -ge 3 -and $bytes[0] -eq 239 -and $bytes[1] -eq 187 -and $bytes[2] -eq 191) {
  $bytes = $bytes[3..($bytes.Length-1)]
}
$text = [System.Text.Encoding]::UTF8.GetString($bytes)
$text = $text.Replace([string][char]0xFEFF, '')
$enc = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($schemaPath, $text, $enc)
Write-Host "✅ schema.prisma saved without BOM."

# 2) Ensure clean DATABASE_URL in .env (prefer .env, fallback .env.local / env)
$envFile  = Join-Path $root ".env"
$envLocal = Join-Path $root ".env.local"
function GetDbFromFile($p) {
  if (!(Test-Path $p)) { return $null }
  $line = (Get-Content $p | Where-Object { $_ -match '^\s*DATABASE_URL\s*=' } | Select-Object -First 1)
  if ($line) { return ($line -replace '^\s*DATABASE_URL\s*=\s*','').Trim() }
  return $null
}
$db = $env:DATABASE_URL
if (-not $db) { $db = GetDbFromFile $envFile }
if (-not $db) { $db = GetDbFromFile $envLocal }
if (-not $db) { throw "DATABASE_URL not found. Add to .env:  DATABASE_URL=postgresql://<...>" }

# normalize quotes/backticks
if (($db.StartsWith('"') -and $db.EndsWith('"')) -or
    ($db.StartsWith("'") -and $db.EndsWith("'")) -or
    ($db.StartsWith('`') -and $db.EndsWith('`'))) {
  $db = $db.Substring(1, $db.Length-2)
}
$db = $db -replace '"',''
if ($db -notmatch '^(postgresql|postgres)://') { throw "Invalid DATABASE_URL: $db" }

# write .env (no quotes, no BOM)
$lines = @()
if (Test-Path $envFile) { $lines = Get-Content $envFile }
$found = $false
for ($i=0; $i -lt $lines.Count; $i++) {
  if ($lines[$i] -match '^\s*DATABASE_URL\s*=') { $lines[$i] = "DATABASE_URL=$db"; $found=$true }
}
if (-not $found) { if ($lines.Count -gt 0) { $lines += "" }; $lines += "DATABASE_URL=$db" }
[System.IO.File]::WriteAllLines($envFile, $lines, $enc)
$env:DATABASE_URL = $db
Write-Host "✅ DATABASE_URL set."

# 3) Prisma: validate -> db push -> generate
Write-Host "==> prisma validate..."
& npx prisma validate; if ($LASTEXITCODE -ne 0) { throw "validate failed" }

Write-Host "==> prisma db push..."
& npx prisma db push --accept-data-loss; if ($LASTEXITCODE -ne 0) { throw "db push failed" }

Write-Host "==> prisma generate..."
& npx prisma generate; if ($LASTEXITCODE -ne 0) { throw "generate failed" }

Write-Host "`n✅ All set. (Optional) npx prisma studio"
