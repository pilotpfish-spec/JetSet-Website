param([string]$ProjectRoot = "C:\website")
$ErrorActionPreference = "Stop"; Set-StrictMode -Version Latest
Set-Location $ProjectRoot

$path = Join-Path $ProjectRoot "src\lib\stripe.ts"
$utf8 = New-Object System.Text.UTF8Encoding($false)
$code = Get-Content -Raw -LiteralPath $path

# Replace any constructor that sets apiVersion with a minimal config
$code = $code -replace 'new Stripe\((.+?),\s*\{[^}]*apiVersion[^}]*\}\s*\)',
                       'new Stripe($1, {})'

# Also handle the exact string you have
$code = $code -replace 'new Stripe\(\s*process\.env\.STRIPE_SECRET_KEY!?,\s*\{\s*apiVersion:\s*".*?"\s*\}\s*\)',
                       'new Stripe(process.env.STRIPE_SECRET_KEY || "", {})'

[IO.File]::WriteAllText($path, $code, $utf8)
Write-Host "OK: Removed hard-coded Stripe apiVersion in $path"
