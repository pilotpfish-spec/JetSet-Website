Write-Host "Fixing tagline and verifying Maps key..."

# Load the main page.tsx under src\app
$text = Get-Content ".\src\app\page.tsx" -Raw

# Replace any bad apostrophe encoding with the correct version
$text = $text -replace "We[^a-zA-Z0-9\s]?re", "We're"

# Save it back
Set-Content ".\src\app\page.tsx" $text -Encoding UTF8

# Ensure .env.local exists
if (!(Test-Path ".env.local")) {
  throw "Missing .env.local - please add your Google Maps API key before continuing."
}

Write-Host "OK: Fixed src\app\page.tsx encoding and verified .env.local for Google Maps."
