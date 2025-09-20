# 52-migrate-mailgun.ps1
# Replace mailgun-js in bookings API with direct Mailgun REST call, then rebuild.

$ErrorActionPreference = "Stop"
Set-Location "C:\website"

$bookingApi = "C:\website\src\app\api\bookings\route.ts"

if (!(Test-Path $bookingApi)) {
  throw "Missing file: $bookingApi"
}

# 1) Backup
$stamp = Get-Date -Format "yyyyMMddHHmmss"
Copy-Item $bookingApi "$bookingApi.bak.$stamp"

# 2) Overwrite the bookings route to use fetch -> Mailgun (no mailgun-js)
$ts = @'
import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";
import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

/**
 * Requires env:
 * - MAILGUN_DOMAIN
 * - MAILGUN_API_KEY
 * - BOOKINGS_TO_EMAIL (or OWNER_EMAIL fallback)
 * Optional:
 * - BRAND_NAME (defaults: JetSet Direct)
 */
export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    // Basic shape validation (extend as needed)
    const {
      customerName,
      customerEmail,
      phone,
      pickupAddress,
      dropoffAddress,
      mode, // "toAirport" | "fromAirport" | "nonAirport"
      distanceMiles,
      durationMinutes,
      quotedTotal,
      pickupAt,      // ISO string
      notes,
    } = body || {};

    if (!customerName || !pickupAddress || !dropoffAddress || !mode || quotedTotal == null) {
      return NextResponse.json({ error: "Invalid booking payload" }, { status: 400 });
    }

    // Persist booking
    const booking = await prisma.booking.create({
      data: {
        customerName,
        customerEmail: customerEmail ?? null,
        phone: phone ?? null,
        pickupAddress,
        dropoffAddress,
        mode,
        distanceMiles: Number(distanceMiles ?? 0),
        durationMinutes: Number(durationMinutes ?? 0),
        quotedTotal: Number(quotedTotal),
        pickupAt: pickupAt ? new Date(pickupAt) : null,
        notes: notes ?? null,
        status: "pending",
      },
    });

    // Fail-closed email gate
    const domain = process.env.MAILGUN_DOMAIN;
    const apiKey = process.env.MAILGUN_API_KEY;
    const to = process.env.BOOKINGS_TO_EMAIL || process.env.OWNER_EMAIL;
    const brand = process.env.BRAND_NAME || "JetSet Direct";

    if (!domain || !apiKey || !to) {
      return NextResponse.json(
        {
          error:
            "FAIL-CLOSED: Email notification blocked — Mailgun configuration incomplete (missing API key, domain, or destination). Booking saved but cannot be confirmed.",
          bookingId: booking.id,
        },
        { status: 503 }
      );
    }

    // Compose email
    const subject = `New Booking — ${brand} — ${customerName}`;
    const text = [
      `New booking received`,
      ``,
      `Name: ${customerName}`,
      customerEmail ? `Email: ${customerEmail}` : null,
      phone ? `Phone: ${phone}` : null,
      ``,
      `Mode: ${mode}`,
      `Pickup: ${pickupAddress}`,
      `Dropoff: ${dropoffAddress}`,
      pickupAt ? `Pickup At: ${pickupAt}` : null,
      `Distance: ${distanceMiles ?? 0} mi`,
      `Duration: ${durationMinutes ?? 0} min`,
      `Quoted Total: $${Number(quotedTotal).toFixed(2)}`,
      ``,
      notes ? `Notes: ${notes}` : null,
      ``,
      `Booking ID: ${booking.id}`,
    ]
      .filter(Boolean)
      .join("\n");

    // Send via Mailgun REST
    const form = new FormData();
    form.set("from", `${brand} <no-reply@${domain}>`);
    form.set("to", to);
    form.set("subject", subject);
    form.set("text", text);

    const auth = "Basic " + Buffer.from(`api:${apiKey}`).toString("base64");
    const resp = await fetch(`https://api.mailgun.net/v3/${domain}/messages`, {
      method: "POST",
      headers: { Authorization: auth },
      body: form,
    });

    if (!resp.ok) {
      const msg = await resp.text();
      return NextResponse.json(
        {
          error: `Mailgun send failed: ${resp.status} ${resp.statusText}`,
          details: msg,
          bookingId: booking.id,
        },
        { status: 502 }
      );
    }

    return NextResponse.json({ ok: true, bookingId: booking.id });
  } catch (err: any) {
    console.error("Bookings route error:", err);
    return NextResponse.json({ error: "Booking failed" }, { status: 500 });
  }
}
'@

Set-Content -Path $bookingApi -Value $ts -Encoding UTF8
Write-Host "🔧 Replaced mailgun-js with Mailgun REST in src/app/api/bookings/route.ts"

# 3) Remove mailgun-js if present (optional cleanup, avoids types error):
if (Test-Path "C:\website\package-lock.json") {
  npm remove mailgun-js 2>$null | Out-Null
} elseif (Test-Path "C:\website\pnpm-lock.yaml") {
  corepack enable pnpm | Out-Null
  pnpm remove mailgun-js 2>$null | Out-Null
} else {
  yarn remove mailgun-js 2>$null | Out-Null
}

# 4) Rebuild
if (Test-Path "C:\website\pnpm-lock.yaml") {
  pnpm install
  pnpm build
} elseif (Test-Path "C:\website\package-lock.json") {
  npm ci
  npm run build
} else {
  yarn install --frozen-lockfile
  yarn build
}

Write-Host "`n✅ Bookings API migrated off mailgun-js and build attempted."

Write-Host @"
If you see 'FAIL-CLOSED' at runtime:
- Set MAILGUN_DOMAIN
- Set MAILGUN_API_KEY
- Set BOOKINGS_TO_EMAIL (or OWNER_EMAIL)
Then redeploy.

Deploy steps (one-time login/link, then deploy):
  vercel login
  vercel link --yes
  vercel whoami
  vercel deploy --yes
"@
