param(
  [string]$ProjectRoot = "C:\website",
  [string]$ProjectName = "website"   # change if you want a different Vercel project name
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
Set-Location $ProjectRoot

# Prefer .cmd to avoid PowerShell shim quirks
$vercelCmd = Join-Path $env:APPDATA "npm\vercel.cmd"
if (-not (Test-Path $vercelCmd)) { $vercelCmd = "npx.cmd vercel" }

Write-Host "==> Logging in / linking to Vercel (interactive)…"
# This will open a browser; follow prompts. If already logged in, it’ll just link/confirm.
cmd /c "npx vercel login"
cmd /c "npx vercel link --cwd . --project $ProjectName --confirm"

# If you have a Vercel token, we can push env vars non-interactively.
if ($env:VERCEL_TOKEN) {
  Write-Host "==> Pushing env vars from .env.local to Vercel (prod & preview) using VERCEL_TOKEN…"
  $envFile = ".env.local"
  if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
      if ($_ -match '^\s*#') { return }
      if ($_ -match '^\s*$') { return }
      if ($_ -match '^\s*([^=]+)\s*=\s*(.*)\s*$') {
        $name  = $matches[1].Trim()
        $value = $matches[2]
        # Strip surrounding quotes if present
        if ($value.StartsWith('"') -and $value.EndsWith('"')) { $value = $value.Substring(1, $value.Length-2) }
        if ($value.StartsWith("'") -and $value.EndsWith("'")) { $value = $value.Substring(1, $value.Length-2) }

        # Add for Production and Preview
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($value)
        $stdin = [System.IO.MemoryStream]::new($bytes, $false)
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName  = "cmd.exe"
        $psi.Arguments = "/c npx vercel env add $name production --yes"
        $psi.RedirectStandardInput  = $true
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError  = $true
        $psi.UseShellExecute = $false
        $p = [System.Diagnostics.Process]::Start($psi)
        $stdin.CopyTo($p.StandardInput.BaseStream)
        $p.StandardInput.Close()
        $p.WaitForExit()

        $bytes2 = [System.Text.Encoding]::UTF8.GetBytes($value)
        $stdin2 = [System.IO.MemoryStream]::new($bytes2, $false)
        $psi2 = New-Object System.Diagnostics.ProcessStartInfo
        $psi2.FileName  = "cmd.exe"
        $psi2.Arguments = "/c npx vercel env add $name preview --yes"
        $psi2.RedirectStandardInput  = $true
        $psi2.RedirectStandardOutput = $true
        $psi2.RedirectStandardError  = $true
        $psi2.UseShellExecute = $false
        $p2 = [System.Diagnostics.Process]::Start($psi2)
        $stdin2.CopyTo($p2.StandardInput.BaseStream)
        $p2.StandardInput.Close()
        $p2.WaitForExit()
      }
    }
    Write-Host "OK: Env vars pushed."
  } else {
    Write-Host "NOTE: .env.local not found; skipping env push."
  }
} else {
  Write-Host "NOTE: No VERCEL_TOKEN set. Env vars were NOT auto-pushed."
  Write-Host "      You can add them later with:  npx vercel env add NAME production"
}

Write-Host "OK: Vercel setup complete."
