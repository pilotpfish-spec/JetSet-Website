// scratchQuote.mts
import { getQuote } from "./src/services/bookingQuote.ts"

const quote = getQuote({
  mode: "to-airport",
  distanceMiles: 12,
})

console.log("Quote Result:", quote)
