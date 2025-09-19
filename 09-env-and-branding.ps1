param([string]$ProjectRoot = "C:\website")
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
Set-Location $ProjectRoot

if (-not (Test-Path ".env.local")) {
  Set-Content -Encoding UTF8 -Path ".env.local" -Value @'
# Google Maps
GOOGLE_MAPS_API_KEY=replace-with-server-key
NEXT_PUBLIC_GOOGLE_MAPS_API_KEY=replace-with-browser-key

# Stripe
STRIPE_SECRET_KEY=sk_test_replace
STRIPE_PUBLISHABLE_KEY=pk_test_replace
STRIPE_WEBHOOK_SECRET=whsec_replace

# Mailgun
MAILGUN_API_KEY=key-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
MAILGUN_DOMAIN=mg.example.com
MAILGUN_FROM=JetSet Direct <noreply@mg.example.com>
'@
}

Set-Content -Encoding UTF8 -Path "public\logo.svg" -Value @'
<svg width="420" height="90" viewBox="0 0 420 90" xmlns="http://www.w3.org/2000/svg">
  <rect width="420" height="90" fill="#0F1F39"/>
  <text x="24" y="58" font-family="Montserrat, Arial, sans-serif" font-size="36" font-weight="700" fill="#FFFFFF">JetSet Direct</text>
  <polygon points="380,45 360,30 360,60" fill="#FFFFFF"/>
</svg>
'@

Write-Host "OK: .env.local (if missing) and logo.svg written."
