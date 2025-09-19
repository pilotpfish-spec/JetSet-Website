param([string]$ProjectRoot = "C:\website")
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
Set-Location $ProjectRoot

# /api/hero-images
Set-Content -Encoding UTF8 -Path "src\app\api\hero-images\route.ts" -Value @'
import { NextResponse } from "next/server";
import { promises as fs } from "fs";
import path from "path";

export async function GET() {
  const dir = path.join(process.cwd(), "public", "hero");
  try {
    const files = await fs.readdir(dir);
    const urls = files.filter(f => /\.(jpe?g|png|webp|avif)$/i.test(f)).map(f => "/hero/" + f);
    return NextResponse.json({ images: urls });
  } catch {
    return NextResponse.json({ images: [] });
  }
}
'@

# /api/quote
Set-Content -Encoding UTF8 -Path "src\app\api\quote\route.ts" -Value @'
import { NextResponse } from "next/server";
import { z } from "zod";
import { routeMetrics } from "@/lib/google";
import { DEFAULT_CONFIG, computeFare } from "@/lib/pricing";
import { airportFullName } from "@/lib/airports";

const schema = z.object({
  mode: z.enum(["TO_AIRPORT","FROM_AIRPORT","POINT_TO_POINT"]),
  airportCode: z.string().optional(),
  origin: z.string(),
  dest: z.string(),
  p2pWaitMinutes: z.number().int().nonnegative().optional()
});

export async function POST(req: Request) {
  const body = await req.json();
  const { mode, airportCode, origin, dest, p2pWaitMinutes } = schema.parse(body);

  let originAddr = origin, destAddr = dest, airportName = "";
  if (mode !== "POINT_TO_POINT") {
    if (!airportCode) return NextResponse.json({ error: "airportCode required" }, { status: 400 });
    airportName = airportFullName(airportCode);
    if (mode === "TO_AIRPORT") destAddr = airportName;
    if (mode === "FROM_AIRPORT") originAddr = airportName;
  }

  const { distanceMeters, durationSeconds, startAddress, endAddress } = await routeMetrics(originAddr, destAddr);

  const fare = computeFare(DEFAULT_CONFIG, {
    mode,
    airportCode: mode === "POINT_TO_POINT" ? undefined : airportCode,
    distanceMeters,
    durationSeconds,
    p2pWaitMinutes: mode === "POINT_TO_POINT" ? (p2pWaitMinutes ?? 0) : 0
  });

  return NextResponse.json({
    distanceMeters,
    durationSeconds,
    distanceMiles: distanceMeters / 1609.344,
    durationMinutes: durationSeconds / 60,
    originAddress: startAddress,
    destAddress: endAddress,
    breakdown: fare,
    totalCents: fare.totalCents,
    expiresAt: new Date(Date.now() + 15*60*1000).toISOString()
  });
}
'@

# /api/checkout
Set-Content -Encoding UTF8 -Path "src\app\api\checkout\route.ts" -Value @'
import { NextResponse } from "next/server";
import { stripe } from "@/lib/stripe";

export async function POST(req: Request) {
  const { totalCents, customerId } = await req.json();

  const pi = await stripe.paymentIntents.create({
    amount: totalCents,
    currency: "usd",
    customer: customerId,
    automatic_payment_methods: { enabled: true },
    capture_method: "automatic"
  });

  return NextResponse.json({ clientSecret: pi.client_secret });
}
'@

# /api/stripe/webhook
Set-Content -Encoding UTF8 -Path "src\app\api\stripe\webhook\route.ts" -Value @'
import { NextResponse } from "next/server";
import { stripe } from "@/lib/stripe";

export async function POST(req: Request) {
  const sig = req.headers.get("stripe-signature")!;
  const text = await req.text();
  let event;
  try {
    event = stripe.webhooks.constructEvent(text, sig, process.env.STRIPE_WEBHOOK_SECRET!);
  } catch (err: any) {
    return new NextResponse(`Webhook Error: ${err.message}`, { status: 400 });
  }

  // TODO: mark booking paid/failed + send emails
  return NextResponse.json({ received: true });
}
'@

# /api/mail/booking
Set-Content -Encoding UTF8 -Path "src\app\api\mail\booking\route.ts" -Value @'
import { NextResponse } from "next/server";
import { sendEmail } from "@/lib/mailgun";

export async function POST(req: Request) {
  const { to, summaryHtml } = await req.json();
  try {
    const result = await sendEmail(to, "Your JetSet Direct Booking", summaryHtml);
    if (!result?.id) throw new Error("Mailgun did not return message id");
    return NextResponse.json({ ok: true });
  } catch {
    return NextResponse.json({ ok: false, error: "Email not sent. Please try again." }, { status: 502 });
  }
}
'@

Write-Host "OK: API routes written."
