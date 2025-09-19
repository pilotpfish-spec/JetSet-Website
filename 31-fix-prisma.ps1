# 31-fix-prisma.ps1
cd C:\website

Write-Host "==> Stripping BOM and normalizing encoding..."
$raw = Get-Content .\prisma\schema.prisma -Raw
# Strip BOM if present
$utf8 = [System.Text.Encoding]::UTF8.GetBytes($raw)
[System.IO.File]::WriteAllBytes("C:\website\prisma\schema.prisma", $utf8)

Write-Host "==> Running Prisma format..."
npx prisma format

Write-Host "==> Deploying Prisma migrations..."
npx prisma migrate deploy

Write-Host "==> Done. Schema fixed, migrations deployed."
