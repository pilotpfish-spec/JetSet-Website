param([string]$ProjectRoot = "C:\website")
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
Set-Location $ProjectRoot

# airports.ts
Set-Content -Encoding UTF8 -Path "src\lib\airports.ts" -Value @'
export type Airport = { code: string; name: string; display: string };
export const AIRPORTS: Airport[] = [
  { code: "DFW", name: "Dallas/Fort Worth International Airport", display: "DFW - Dallas/Fort Worth" },
  { code: "DAL", name: "Dallas Love Field", display: "DAL - Dallas Love Field" },
  { code: "IAH", name: "George Bush Intercontinental", display: "IAH - Houston Intercontinental" },
  { code: "HOU", name: "William P. Hobby", display: "HOU - Houston Hobby" },
  { code: "AUS", name: "Austin-Bergstrom International", display: "AUS - Austin" },
  { code: "SAT", name: "San Antonio International", display: "SAT - San Antonio" },
  { code: "OKC", name: "Will Rogers World Airport", display: "OKC - Oklahoma City" },
  { code: "SHV", name: "Shreveport Regional", display: "SHV - Shreveport" }
];
export const airportDisplay = (code: string) => AIRPORTS.find(a => a.code === code)?.display ?? code;
export const airportFullName = (code: string) => AIRPORTS.find(a => a.code === code)?.name ?? code;
'@

# google.ts
Set-Content -Encoding UTF8 -Path "src\lib\google.ts" -Value @'
import { Client } from "@googlemaps/google-maps-services-js";

const client = new Client({});
const apiKey = process.env.GOOGLE_MAPS_API_KEY!;

export type LatLng = { lat: number; lng: number };

export async function routeMetrics(origin: string|LatLng, destination: string|LatLng) {
  const toText = (p: string|LatLng) => typeof p === "string" ? p : `${p.lat},${p.lng}`;
  const resp = await client.directions({
    params: { origin: toText(origin), destination: toText(destination), key: apiKey, mode: "driving" }
  });
  const leg = resp.data.routes?.[0]?.legs?.[0];
  if (!leg) throw new Error("No route found");
  return {
    distanceMeters: leg.distance!.value,
    durationSeconds: leg.duration!.value,
    startAddress: leg.start_address,
    endAddress: leg.end_address
  };
}

export const milesFromMeters = (m: number) => m / 1609.344;
export const minutesFromSeconds = (s: number) => s / 60;
'@

# pricing.ts
Set-Content -Encoding UTF8 -Path "src\lib\pricing.ts" -Value @'
import { milesFromMeters, minutesFromSeconds } from "./google";

export type Mode = "TO_AIRPORT" | "FROM_AIRPORT" | "POINT_TO_POINT";

export type ToFromAirportRates = {
  baseCents: number; perMileCents: number; perMinuteCents: number; minimumCents: number; airportFeeCents: number;
};
export type PointToPointRates = {
  baseCents: number; perMileCents: number; perMinuteCents: number; minimumCents: number; waitPerHourCents: number;
};
export type AirportOverride = {
  airportCode: string; airportFeeCents?: number; perMileCents?: number; perMinuteCents?: number; baseCents?: number; minimumCents?: number;
};
export type PricingConfig = { toFromAirport: ToFromAirportRates; pointToPoint: PointToPointRates; airportOverrides?: AirportOverride[]; };
export type FareInput = { mode: Mode; distanceMeters: number; durationSeconds: number; airportCode?: string; p2pWaitMinutes?: number; };
export type FareBreakdown = {
  baseCents: number; distanceCents: number; timeCents: number; airportFeeCents: number; waitCents: number; appliedMinimumCents: number; totalCents: number;
};

function applyAirportOverride(cfg: PricingConfig, code?: string) {
  if (!code) return { toFromAirport: cfg.toFromAirport, pointToPoint: cfg.pointToPoint };
  const ov = cfg.airportOverrides?.find(o => o.airportCode === code);
  if (!ov) return { toFromAirport: cfg.toFromAirport, pointToPoint: cfg.pointToPoint };
  const tfa = { ...cfg.toFromAirport, ...ov, airportFeeCents: ov.airportFeeCents ?? cfg.toFromAirport.airportFeeCents };
  return { toFromAirport: tfa, pointToPoint: cfg.pointToPoint };
}

export function computeFare(cfg: PricingConfig, input: FareInput): FareBreakdown {
  const miles = milesFromMeters(input.distanceMeters);
  const minutes = minutesFromSeconds(input.durationSeconds);
  const { toFromAirport, pointToPoint } = applyAirportOverride(cfg, input.airportCode);

  if (input.mode === "POINT_TO_POINT") {
    const base = pointToPoint.baseCents;
    const distanceCents = Math.round(pointToPoint.perMileCents * miles);
    const timeCents = Math.round(pointToPoint.perMinuteCents * minutes);
    const waitHours = Math.max(0, (input.p2pWaitMinutes ?? 0) / 60);
    const waitCents = Math.round(pointToPoint.waitPerHourCents * waitHours);
    let total = base + distanceCents + timeCents + waitCents;
    const min = Math.max(pointToPoint.minimumCents, 0);
    if (total < min) total = min;
    return { baseCents: base, distanceCents, timeCents, airportFeeCents: 0, waitCents, appliedMinimumCents: min, totalCents: total };
  }

  if (!input.airportCode) throw new Error("airportCode required for airport trips");
  const base = toFromAirport.baseCents;
  const distanceCents = Math.round(toFromAirport.perMileCents * miles);
  const timeCents = Math.round(toFromAirport.perMinuteCents * minutes);
  const airportFeeCents = toFromAirport.airportFeeCents;
  let total = base + distanceCents + timeCents + airportFeeCents;
  const min = Math.max(toFromAirport.minimumCents, 0);
  if (total < min) total = min;
  return { baseCents: base, distanceCents, timeCents, airportFeeCents, waitCents: 0, appliedMinimumCents: min, totalCents: total };
}

export const DEFAULT_CONFIG: PricingConfig = {
  toFromAirport: { baseCents: 400, perMileCents: 200, perMinuteCents: 75, minimumCents: 2000, airportFeeCents: 500 },
  pointToPoint: { baseCents: 2500, perMileCents: 300, perMinuteCents: 200, minimumCents: 2000, waitPerHourCents: 1200 },
  airportOverrides: []
};
'@

# stripe.ts
Set-Content -Encoding UTF8 -Path "src\lib\stripe.ts" -Value @'
import Stripe from "stripe";
export const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, { apiVersion: "2024-06-20" });
'@

# mailgun.ts
Set-Content -Encoding UTF8 -Path "src\lib\mailgun.ts" -Value @'
import formData from "form-data";
import Mailgun from "mailgun.js";
const mg = new Mailgun(formData);
export const mailgun = mg.client({ username: "api", key: process.env.MAILGUN_API_KEY! });
export async function sendEmail(to: string, subject: string, html: string) {
  const domain = process.env.MAILGUN_DOMAIN!;
  const from = process.env.MAILGUN_FROM!;
  return mailgun.messages.create(domain, { from, to, subject, html });
}
'@

Write-Host "OK: Core libs written."
