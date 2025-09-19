param(
  [string]$ProjectRoot = "C:\website"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$path = Join-Path $ProjectRoot "src\app\admin\page.tsx"

# Ensure folder exists
[System.IO.Directory]::CreateDirectory([System.IO.Path]::GetDirectoryName($path)) | Out-Null

# Safe JSX content (uses &rarr; instead of "->")
$content = @'
import React from "react";

export default function AdminHome() {
  return (
    <main className="p-6">
      <h1 className="text-2xl font-semibold mb-4">Admin</h1>
      <ul className="list-disc pl-6 space-y-1">
        <li>Bookings/Quotes (searchable)</li>
        <li>Analytics dashboards</li>
        <li>Pricing Configuration (Draft &rarr; Preview &rarr; Publish &rarr; Rollback)</li>
        <li>Audit log</li>
      </ul>
    </main>
  );
}
'@

# Write file as UTF-8 without BOM
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($path, $content, $utf8NoBom)

Write-Host "OK: admin page fixed at $path"
