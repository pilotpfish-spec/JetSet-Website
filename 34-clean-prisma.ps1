cd C:\website

Write-Host "==> Cleaning Prisma schema..."

$schemaPath = "C:\website\prisma\schema.prisma"

# Strip BOM by re-reading and writing raw text
$content = Get-Content $schemaPath -Raw
$clean = $content -replace "^\uFEFF", ""

# Correct header
$header = @"
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}
"@

# If generator/datasource missing, prepend them
if ($clean -notmatch "generator client") {
    $clean = $header + "`r`n" + $clean
}

# Write back (UTF8 without BOM)
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($schemaPath, $clean, $utf8NoBom)

Write-Host "✅ Schema cleaned and header fixed."

# Prisma format
Write-Host "==> Running prisma format..."
npx prisma format

# Reset and migrate
Write-Host "==> Resetting and applying schema..."
npx prisma migrate reset --force

Write-Host "==> Done. Schema synced with Postgres."
Write-Host "👉 Run: npx prisma studio to inspect tables"
