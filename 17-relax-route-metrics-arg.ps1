param([string]$ProjectRoot = "C:\website")
$ErrorActionPreference = "Stop"; Set-StrictMode -Version Latest
Set-Location $ProjectRoot

$path = Join-Path $ProjectRoot "src\lib\google.ts"
$utf8 = New-Object System.Text.UTF8Encoding($false)
$code = Get-Content -Raw -LiteralPath $path

# 1) Make the apiKey param optional in the signature
$code = $code -replace 'routeMetrics\(\s*origin:\s*string\s*\|\s*LatLng,\s*destination:\s*string\s*\|\s*LatLng,\s*apiKey:\s*string\s*\)',
                              'routeMetrics(origin: string | LatLng, destination: string | LatLng, apiKey?: string)'

# 2) Ensure we pick up the key from env if it wasn’t provided
# Insert a local "key" variable and replace usage.
if ($code -notmatch 'const\s+key\s*=\s*apiKey\s*\?\?') {
  $code = $code -replace 'const resp = await client\.directions\(\{',
                          "const key = apiKey ?? (process.env.GOOGLE_MAPS_API_KEY ?? '');`n  const resp = await client.directions({"
}

# 3) Use the local key variable in the request params
$code = $code -replace 'key:\s*apiKey', 'key: key'

[IO.File]::WriteAllText($path, $code, $utf8)
Write-Host "OK: Made apiKey optional and wired env fallback in $path"
