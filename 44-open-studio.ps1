# 44-open-studio.ps1
# Auto cd to C:\website and open Prisma Studio

$root = "C:\website"
Set-Location $root

Write-Host "==> Opening Prisma Studio for project at $root..."
npx prisma studio
