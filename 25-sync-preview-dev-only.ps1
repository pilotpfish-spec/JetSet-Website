param(
  [string[]]$Targets = @("preview","development")
)

Write-Host "Reading .env.local ..."

$envFile = Join-Path (Get-Location) ".env.local"
if (!(Test-Path $envFile)) { throw "Missing .env.local" }

$lines = Get-Content $envFile | Where-Object {$_ -match "=" -and -not $_.StartsWith("#")}
$envVars = @{}
foreach ($line in $lines) {
  $parts = $line -split "=",2
  $key = $parts[0].Trim()
  $val = $parts[1].Trim('"').Trim("'")
  $envVars[$key] = $val
}

foreach ($target in $Targets) {
  Write-Host ""
  Write-Host "Pushing $($envVars.Count) keys to Vercel ($target) ..."

  foreach ($kv in $envVars.GetEnumerator()) {
    $key = $kv.Key
    $val = $kv.Value

    Write-Host "→ Removing $key ($target) ..."
    vercel env rm $key $target --yes 2>$null

    Write-Host "→ Adding $key ($target) ..."
    echo $val | vercel env add $key $target
  }
}
