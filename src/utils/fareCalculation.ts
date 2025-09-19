// src/utils/fareCalculation.ts
export interface FareInput {
  distanceMiles: number
  isToAirport: boolean
  isFromAirport?: boolean
  isNonAirport?: boolean
  baseRateNonAirport: number
  baseRateToAirport: number
  baseRateFromAirport: number
  perMileRate: number
}

export interface FareResult {
  fare: number
}

export function calculateFare(input: FareInput): FareResult {
  let baseRate = 0
  if (input.isToAirport) baseRate = input.baseRateToAirport
  else if (input.isFromAirport) baseRate = input.baseRateFromAirport
  else if (input.isNonAirport) baseRate = input.baseRateNonAirport

  const fare = baseRate + input.distanceMiles * input.perMileRate
  return { fare }
}
