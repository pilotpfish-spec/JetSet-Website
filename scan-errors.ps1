param([string]$Path = "src")

Write-Host "🔍 Scanning $Path for TypeScript/JSX syntax errors..."

# Run tsc type-checker only (no emit)
tsc --noEmit --project tsconfig.json | ForEach-Object {
  if ($_ -match "error") {
    Write-Host "❌ $_" -ForegroundColor Red
  } elseif ($_ -match "warning") {
    Write-Host "⚠ $_" -ForegroundColor Yellow
  }
}

Write-Host "✅ Scan complete"
