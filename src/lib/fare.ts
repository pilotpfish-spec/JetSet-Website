export type RideMode = "toAirport" | "fromAirport" | "nonAirport";

export interface FareInput {
  mode: RideMode;
  distanceMiles: number;
  durationMinutes: number;
  pickupAt?: string;
}

const BASE_FLAG = 7.5;
const PER_MILE = 2.85;
const PER_MIN = 0.45;
const AIRPORT_SURCHARGE = 8.0;
const MIN_FARE = 35;

export function calculateFare(input: FareInput): number {
  const miles = Math.max(0, input.distanceMiles || 0);
  const mins  = Math.max(0, input.durationMinutes || 0);

  let fare = BASE_FLAG + (miles * PER_MILE) + (mins * PER_MIN);

  if (input.mode === "toAirport" || input.mode === "fromAirport") {
    fare += AIRPORT_SURCHARGE;
  }

  if (fare < MIN_FARE) fare = MIN_FARE;
  return Math.round(fare * 100) / 100;
}
