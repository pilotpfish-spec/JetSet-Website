cd C:\website
Write-Host "==> Cleaning Prisma schema for Postgres..."

(Get-Content prisma\schema.prisma) `
  -replace "@db\.Text", "" `
  | Set-Content -Encoding utf8 prisma\schema.prisma

Write-Host "==> Formatting schema..."
npx prisma format

Write-Host "==> Migrating (local)..."
npx prisma migrate dev --name init-postgres

Write-Host "==> Deploying to Neon (remote DB)..."
npx prisma migrate deploy

Write-Host "✅ Done. Schema fixed and synced with Postgres."
Write-Host "👉 Run: npx prisma studio (to check tables)"
