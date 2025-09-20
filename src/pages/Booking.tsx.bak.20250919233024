import React, { useState } from "react"
import { getQuote } from "../services/bookingQuote"
import type { FareResult } from "../utils/fareCalculation"

export default function Booking() {
  const [quote, setQuote] = useState<FareResult | null>(null)

  const handleGetQuote = () => {
    const result = getQuote({
      isToAirport: true,   // ✅ matches FareInput type
      distanceMiles: 12,
    })
    setQuote(result)
  }

  const handleBook = async () => {
    alert("Booking flow not yet implemented.")
  }

  return (
    <div>
      <h1>Booking</h1>
      <button onClick={handleGetQuote}>Get Quote</button>
      {quote && (
        <div>
          <p>Total: ${quote.fare.toFixed(2)}</p>
          <button onClick={handleBook}>Book Now</button>
        </div>
      )}
    </div>
  )
}
