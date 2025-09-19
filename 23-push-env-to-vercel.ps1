# 23-push-env-to-vercel.ps1
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# --- Resolve vercel CLI (prefer vercel.cmd on Windows) ---
$vercel = $null
$cmdCandidate = (Get-Command "vercel.cmd" -ErrorAction SilentlyContinue)
if ($cmdCandidate) { $vercel = $cmdCandidate.Source }
if (-not $vercel) {
  $binCandidate = (Get-Command "vercel" -ErrorAction SilentlyContinue)
  if ($binCandidate) { $vercel = $binCandidate.Source }
}
if (-not $vercel) {
  throw "Vercel CLI not found on PATH. Install with: npm i -g vercel"
}

# --- Project root & env file ---
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $root) { $root = (Get-Location).Path }
Set-Location $root

$envFile = ".env.local"
if (-not (Test-Path $envFile)) {
  throw "Missing $envFile. Create it first."
}

Write-Host "Reading .env.local ..."

# --- Read and parse .env.local ---
$lines = Get-Content $envFile -Raw | Out-String
$kv = @{}
$lines -split "`n" | ForEach-Object {
  $line = $_.Trim()
  if (-not $line) { return }
  if ($line.StartsWith("#")) { return }
  $eq = $line.IndexOf("=")
  if ($eq -lt 1) { return }
  $key = $line.Substring(0, $eq).Trim()
  $val = $line.Substring($eq + 1).Trim()
  # Strip surrounding quotes if present
  if (($val.StartsWith('"') -and $val.EndsWith('"')) -or ($val.StartsWith("'") -and $val.EndsWith("'"))) {
    $val = $val.Substring(1, $val.Length - 2)
  }
  $kv[$key] = $val
}

# --- Allow-list (add more if you want all of them pushed) ---
$allow = @(
  "GOOGLE_MAPS_API_KEY",
  "STRIPE_SECRET_KEY",
  "STRIPE_WEBHOOK_SECRET",
  "MAILGUN_API_KEY",
  "MAILGUN_DOMAIN",
  "MAILGUN_FROM"
)

# Filter present keys
$toPush = @()
foreach ($k in $allow) {
  if ($kv.ContainsKey($k) -and $kv[$k]) { $toPush += $k }
}

if ($toPush.Count -eq 0) {
  throw "No allowed env vars found in .env.local. Add them, then re-run."
}

Write-Host "Pushing $($toPush.Count) key(s) to Vercel (production) ..."

function Invoke-Vercel {
  param(
    [string[]] $Args,
    [string] $StdinValue = $null,
    [switch] $IgnoreExitCode
  )
  # Try native piping first
  try {
    if ($null -ne $StdinValue) {
      $null = $StdinValue | & $vercel @Args
    } else {
      $null = & $vercel @Args
    }
    if (-not $IgnoreExitCode -and $LASTEXITCODE -ne 0) {
      throw "Vercel exited with code $LASTEXITCODE"
    }
    return $true
  } catch {
    # Fallback: cmd.exe /c "echo value | vercel ..."
    $argLine = $Args -join " "
    if ($null -ne $StdinValue) {
      $cmdLine = "echo " + ($StdinValue -replace '"','\"') + " | `"$vercel`" " + $argLine
    } else {
      $cmdLine = "`"$vercel`" " + $argLine
    }
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = "cmd.exe"
    $psi.Arguments = "/c $cmdLine"
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.UseShellExecute = $false
    $p = [System.Diagnostics.Process]::Start($psi)
    $out = $p.StandardOutput.ReadToEnd()
    $err = $p.StandardError.ReadToEnd()
    $p.WaitForExit()
    if (-not $IgnoreExitCode -and $p.ExitCode -ne 0) {
      Write-Host $out
      Write-Host $err
      throw "Vercel (cmd) exited with code $($p.ExitCode)"
    }
    return $true
  }
}

foreach ($name in $toPush) {
  $value = $kv[$name]
  Write-Host "→ $name"

  # 1) Remove existing (ignore errors if not found)
  try {
    Invoke-Vercel @("env","rm",$name,"production","--yes") -IgnoreExitCode
  } catch {
    # ignore
  }

  # 2) Add new
  Invoke-Vercel @("env","add",$name,"production","--yes") -StdinValue $value
}

Write-Host "✅ Done. Env vars are in Vercel (production)."
Write-Host "Tip: redeploy to apply them: PowerShell -ExecutionPolicy Bypass -File .\21-vercel-deploy.ps1"
