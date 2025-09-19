# 22b-fix-mailgun-types.ps1
param([string]$ProjectRoot = "C:\website")
$ErrorActionPreference = "Stop"; Set-StrictMode -Version Latest
Set-Location $ProjectRoot
$libDir = Join-Path $ProjectRoot "src\lib"
$mailLibPath = Join-Path $libDir "mail.ts"
if (-not (Test-Path $libDir)) { New-Item -ItemType Directory -Path $libDir -Force | Out-Null }

$ts = @'
import formData from "form-data";
import Mailgun from "mailgun.js";

/** Require an env var and return it as a string (never undefined). */
function requireEnv(name: string): string {
  const v = process.env[name];
  if (!v) throw new Error(`${name} is not set`);
  return v;
}

const mg = new Mailgun(formData);

const apiKey = requireEnv("MAILGUN_API_KEY");
const domain = requireEnv("MAILGUN_DOMAIN");
const baseUrl = process.env.MAILGUN_BASE_URL || "https://api.mailgun.net";

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
    `No-Reply <noreply@${domain}>`;

  return mailgunClient.messages.create(domain, {
    from,
    to: [input.to],
    subject: input.subject,
    html: input.html,
    text: input.text || undefined,
  });
}
'@

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($mailLibPath, $ts, $utf8NoBom)
Write-Host "OK: Wrote $mailLibPath (typed-safe env helpers)"
