# 43-fix-prisma-client.ps1
# Cleans node_modules/@prisma and regenerates Prisma client

$root = "C:\website"
Set-Location $root

Write-Host "==> Removing old Prisma client..."
Remove-Item -Recurse -Force .\node_modules\@prisma -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force .\prisma\.cache -ErrorAction SilentlyContinue

Write-Host "==> Reinstalling @prisma/client..."
npm install @prisma/client

Write-Host "==> Regenerating Prisma client..."
npx prisma generate
if ($LASTEXITCODE -ne 0) { throw "Prisma generate failed" }

Write-Host "==> Building Next.js app..."
npm run build
if ($LASTEXITCODE -ne 0) { throw "Build failed" }

Write-Host "==> Deploying to Vercel..."
vercel --prod --yes

Write-Host "`n✅ Prisma client rebuilt, app compiled, and deployed."
