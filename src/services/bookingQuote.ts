// s../services/bookingQuote.ts
import { calculateFare } from "../utils/fareCalculation"
import type { FareInput } from "../utils/fareCalculation"
import { RATES } from "../config/rates"

export function getQuote(
  input: Omit<FareInput, "baseRateNonAirport" | "baseRateToAirport" | "baseRateFromAirport" | "perMileRate">
) {
  return calculateFare({
    ...input,
    ...RATES,
  })
}
