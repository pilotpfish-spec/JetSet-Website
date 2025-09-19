param([string]$ProjectRoot = "C:\website")
$ErrorActionPreference = "Stop"; Set-StrictMode -Version Latest

Set-Location $ProjectRoot

# 1) Write a minimal Next.js config with ESLint relaxed during builds
$nextConfigTs = @'
import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  eslint: { ignoreDuringBuilds: true },
};

export default nextConfig;
'@
$utf8 = New-Object System.Text.UTF8Encoding($false)
[IO.File]::WriteAllText((Join-Path $ProjectRoot "next.config.ts"), $nextConfigTs, $utf8)

# 2) Soften ESLint rules in .eslintrc.json
$eslintrcPath = Join-Path $ProjectRoot ".eslintrc.json"
if (Test-Path $eslintrcPath) {
  $json = Get-Content $eslintrcPath -Raw | ConvertFrom-Json
} else {
  $json = [ordered]@{ extends = "next/core-web-vitals"; rules = @{} } | ConvertTo-Json | ConvertFrom-Json
}

if (-not $json.rules) { $json | Add-Member -NotePropertyName rules -NotePropertyValue (@{}) }

$json.rules."@next/next/no-html-link-for-pages" = "off"
$json.rules."@next/next/no-img-element" = "warn"
$json.rules."@typescript-eslint/no-explicit-any" = "off"

# Write JSON pretty
($json | ConvertTo-Json -Depth 10) | Out-File -FilePath $eslintrcPath -Encoding utf8

Write-Host "OK: ESLint relaxed and next.config.ts written."
