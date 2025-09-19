// scratchTest.mts
import { calculateFare } from "./src/utils/fareCalculation.ts"

const result = calculateFare({
  mode: "to-airport",
  distanceMiles: 10,
  baseRateNonAirport: 15,
  baseRateToAirport: 25,
  baseRateFromAirport: 30,
  perMileRate: 2.5,
})

console.log(result)
