param([string]$ProjectRoot = "C:\website")
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
Set-Location $ProjectRoot

$schemaPath = Join-Path $ProjectRoot "prisma\schema.prisma"
if (!(Test-Path $schemaPath)) { throw "Schema not found at $schemaPath" }

# 1) Load raw text and strip BOM/zero-width chars
$raw = Get-Content -LiteralPath $schemaPath -Raw -Encoding Byte
# Remove UTF-8 BOM if present (EF BB BF)
if ($raw.Length -ge 3 -and $raw[0] -eq 0xEF -and $raw[1] -eq 0xBB -and $raw[2] -eq 0xBF) {
  $raw = $raw[3..($raw.Length-1)]
}
# Convert to string and remove any stray U+FEFF / U+200B just in case
$text = [System.Text.Encoding]::UTF8.GetString($raw) -replace "^\uFEFF", "" -replace "\uFEFF", "" -replace "\u200B",""

# 2) Write back as UTF-8 (no BOM)
Set-Content -LiteralPath $schemaPath -Value $text -Encoding utf8

# 3) Generate Prisma client using npx.cmd (avoids PowerShell shim)
$npxCmd = Join-Path $env:ProgramFiles "nodejs\npx.cmd"
if (!(Test-Path $npxCmd)) { throw "npx.cmd not found at $npxCmd" }
& $npxCmd prisma generate
Write-Host "OK: Prisma schema sanitized and client generated."
