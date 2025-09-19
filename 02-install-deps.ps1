param([string]$ProjectRoot = "C:\website")
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
Set-Location $ProjectRoot

npm i @googlemaps/google-maps-services-js @react-google-maps/api zod stripe @stripe/stripe-js mailgun.js form-data @prisma/client bcryptjs
npm i -D prisma @types/google.maps
Write-Host "OK: Dependencies installed."
