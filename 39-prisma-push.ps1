# 39-prisma-push.ps1
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

# Ensure node_modules and prisma CLI exist
if (!(Test-Path "$root\node_modules")) {
  npm i --no-audit --no-fund
}

if (!(Test-Path "$root\node_modules\.bin\prisma.cmd")) {
  npm i -D prisma @prisma/client --no-audit --no-fund
}

# Use local prisma binary (bypass npx)
$prisma = Join-Path $root "node_modules\.bin\prisma.cmd"

# Make sure DATABASE_URL is available from .env
$envFile = Join-Path $root ".env"
if (Test-Path $envFile) {
  (Get-Content $envFile) | ForEach-Object {
    if ($_ -match '^\s*DATABASE_URL\s*=\s*(.+)$') {
      $env:DATABASE_URL = $Matches[1].Trim('"').Trim("'")
    }
  }
}
if (-not $env:DATABASE_URL) { throw "DATABASE_URL not set. Add it to .env and rerun." }

# Validate -> push -> generate
& $prisma validate; if ($LASTEXITCODE -ne 0) { throw "prisma validate failed" }
& $prisma db push --accept-data-loss; if ($LASTEXITCODE -ne 0) { throw "prisma db push failed" }
& $prisma generate; if ($LASTEXITCODE -ne 0) { throw "prisma generate failed" }

Write-Host "`n✅ Prisma schema pushed and client generated."
