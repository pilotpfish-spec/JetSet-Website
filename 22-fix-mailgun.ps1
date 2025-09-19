# 22-fix-mailgun.ps1
param(
  [string]$ProjectRoot = "C:\website"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# Ensure we're in the project root
if (-not (Test-Path $ProjectRoot)) {
  throw "Project root not found: $ProjectRoot"
}
Set-Location $ProjectRoot

# Paths
$libDir = Join-Path $ProjectRoot "src\lib"
$mailLibPath = Join-Path $libDir "mail.ts"

# Ensure directory exists
if (-not (Test-Path $libDir)) {
  New-Item -ItemType Directory -Path $libDir -Force | Out-Null
}

# Write mail.ts with single-quoted here-string (no PowerShell interpolation)
$ts = @'
import formData from "form-data";
import Mailgun from "mailgun.js";

/**
 * Mailgun client setup.
 * Required env:
 *  - MAILGUN_API_KEY
 *  - MAILGUN_DOMAIN
 * Optional:
 *  - MAILGUN_BASE_URL (defaults to "https://api.mailgun.net")
 *  - MAILGUN_FROM (fallbacks to `No-Reply <noreply@${MAILGUN_DOMAIN}>`)
 */

const mg = new Mailgun(formData);

const apiKey = process.env.MAILGUN_API_KEY;
const domain = process.env.MAILGUN_DOMAIN;
const baseUrl = process.env.MAILGUN_BASE_URL || "https://api.mailgun.net";

if (!apiKey) {
  throw new Error("MAILGUN_API_KEY is not set");
}
if (!domain) {
  throw new Error("MAILGUN_DOMAIN is not set");
}

export const mailgunClient = mg.client({
  username: "api",
  key: apiKey,
  url: baseUrl,
});

export type SendBookingEmailInput = {
  to: string;
  subject: string;
  html: string;
  text?: string;
  fromOverride?: string;
};

/**
 * Sends a booking email via Mailgun.
 * If MAILGUN_FROM is not set, falls back to `No-Reply <noreply@${domain}>`.
 */
export async function sendBookingEmail(input: SendBookingEmailInput) {
  const from =
    input.fromOverride ||
    process.env.MAILGUN_FROM ||
    (domain ? `No-Reply <noreply@${domain}>` : "No-Reply <noreply@example.com>");

  return mailgunClient.messages.create(domain, {
    from,
    to: [input.to],
    subject: input.subject,
    html: input.html,
    text: input.text || undefined,
  });
}
'@

# Write the file (UTF-8 without BOM)
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($mailLibPath, $ts, $utf8NoBom)

Write-Host "OK: Wrote $mailLibPath"
