# 54-fix-tsconfig-alias.ps1
# Robustly ensure tsconfig has: compilerOptions.baseUrl=".", paths: {"@/*": ["src/*"]}.
# Keeps all other fields intact. Then rebuild.

$ErrorActionPreference = "Stop"
Set-Location "C:\website"

$tsconfigPath = "C:\website\tsconfig.json"

function Ensure-PSObject($obj) {
  if ($null -eq $obj) { return [pscustomobject]@{} }
  if ($obj -is [System.Collections.IDictionary]) {
    # Convert hashtable to PSCustomObject
    $ps = [pscustomobject]@{}
    foreach ($k in $obj.Keys) { Add-Member -InputObject $ps -NotePropertyName $k -NotePropertyValue $obj[$k] }
    return $ps
  }
  if ($obj -isnot [pscustomobject]) {
    # Last resort: stringify and parse back as PSCustomObject
    $jsonStr = $obj | ConvertTo-Json -Depth 100
    return ($jsonStr | ConvertFrom-Json)
  }
  return $obj
}

if (-not (Test-Path $tsconfigPath)) {
  # Create a minimal tsconfig if missing
  $ts = @{
    "compilerOptions" = @{
      "target" = "ES2020"
      "module" = "ESNext"
      "strict" = $true
      "jsx" = "preserve"
      "moduleResolution" = "Bundler"
      "baseUrl" = "."
      "paths" = @{
        "@/*" = @("src/*")
      }
    }
    "include" = @("next-env.d.ts", "**/*.ts", "**/*.tsx")
    "exclude" = @("node_modules")
  } | ConvertTo-Json -Depth 100
  Set-Content $tsconfigPath $ts -Encoding UTF8
  Write-Host "🆕 Created tsconfig.json with @/* alias."
}
else {
  $stamp = Get-Date -Format "yyyyMMddHHmmss"
  Copy-Item $tsconfigPath "$tsconfigPath.bak.$stamp"

  $raw = Get-Content $tsconfigPath -Raw
  try {
    $json = $raw | ConvertFrom-Json
  } catch {
    # If current file is malformed JSON, replace with a safe default
    Write-Host "⚠️  Existing tsconfig.json is malformed. Replacing with a safe default."
    $json = [pscustomobject]@{}
  }

  $json = Ensure-PSObject $json

  if (-not ($json.PSObject.Properties.Name -contains "compilerOptions")) {
    Add-Member -InputObject $json -NotePropertyName "compilerOptions" -NotePropertyValue ([pscustomobject]@{})
  }
  $co = Ensure-PSObject $json.compilerOptions

  if (-not ($co.PSObject.Properties.Name -contains "baseUrl")) {
    Add-Member -InputObject $co -NotePropertyName "baseUrl" -NotePropertyValue "."
  } else {
    $co.baseUrl = "."
  }

  if (-not ($co.PSObject.Properties.Name -contains "paths")) {
    Add-Member -InputObject $co -NotePropertyName "paths" -NotePropertyValue ([pscustomobject]@{})
  }
  $paths = Ensure-PSObject $co.paths
  if (-not ($paths.PSObject.Properties.Name -contains "@/*")) {
    Add-Member -InputObject $paths -NotePropertyName "@/*" -NotePropertyValue @("src/*")
  } else {
    $paths."@/*" = @("src/*")
  }

  # Reassign in case we replaced objects
  $co.paths = $paths
  $json.compilerOptions = $co

  ($json | ConvertTo-Json -Depth 100) | Set-Content $tsconfigPath -Encoding UTF8
  Write-Host "🔧 Ensured tsconfig.json alias: '@/*' → 'src/*' and baseUrl='.'."
}

# Rebuild (no deps changed)
if (Test-Path "C:\website\pnpm-lock.yaml") {
  corepack enable pnpm | Out-Null
  pnpm build
} elseif (Test-Path "C:\website\package-lock.json") {
  npm run build
} else {
  yarn build
}

Write-Host "`n✅ tsconfig alias fixed and build attempted."
