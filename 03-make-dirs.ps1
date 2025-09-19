param([string]$ProjectRoot = "C:\website")
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
Set-Location $ProjectRoot

$dirs = @(
  "src\lib","src\components",
  "src\app","src\app\about","src\app\mission","src\app\fleet","src\app\insured","src\app\contact",
  "src\app\admin","src\app\admin\login","src\app\booking",
  "src\app\api\quote","src\app\api\checkout","src\app\api\stripe\webhook","src\app\api\mail\booking","src\app\api\hero-images",
  "public","public\hero","prisma"
)
foreach ($d in $dirs) { if (-not (Test-Path $d)) { New-Item -ItemType Directory -Path $d -Force | Out-Null } }
Write-Host "OK: Directories ready."
