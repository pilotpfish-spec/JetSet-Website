cd C:\Users\PATRICK\jetset-direct
cd C:\website

Write-Host "==> Building project locally..."
npm run build

Write-Host "==> Starting local preview at http://localhost:3000/"
Start-Process "http://localhost:3000"
Start-Job { npm run start }

Write-Host "==> Press Enter after checking the site locally to continue deployment..."
[void][System.Console]::ReadLine()

Write-Host "==> Deploying to Vercel (production)..."
vercel --prod

Write-Host "✅ Deploy complete. JetSetDirect.com should now point to the latest build."
