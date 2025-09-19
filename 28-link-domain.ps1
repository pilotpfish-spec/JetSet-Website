# 28-link-domain.ps1
Write-Host "Linking JetSetDirect.com domain to this project..."

# Add root domain
vercel domains add jetsetdirect.com

# Add www subdomain
vercel domains add www.jetsetdirect.com

# Alias production deployment to the domain
vercel alias set website-nwfs4misd-patrick-fishers-projects-c306d667.vercel.app jetsetdirect.com
vercel alias set website-nwfs4misd-patrick-fishers-projects-c306d667.vercel.app www.jetsetdirect.com

Write-Host "✅ Domain linked: jetsetdirect.com + www.jetsetdirect.com"
Write-Host "⚠️ Make sure your DNS A record points to 76.76.21.21 (Vercel)"
