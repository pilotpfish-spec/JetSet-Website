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
