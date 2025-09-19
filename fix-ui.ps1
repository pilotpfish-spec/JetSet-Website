cd C:\website

Write-Host "🔥 Applying UI + Booking Flow Fixes"

# 1. Fix navigation: remove stretched logo, align links
(Get-Content src/components/Header.tsx -Raw) `
  -replace '<Image[^>]+>', '' `
  -replace 'justify-end', 'justify-center' `
  | Set-Content src/components/Header.tsx -Encoding UTF8

# 2. Update Hero: change font + fix button link
(Get-Content src/app/Hero.tsx -Raw) `
  -replace 'className="text-4xl font-bold md:text-6xl"', 'className="font-[Montserrat] text-6xl font-extrabold tracking-tight"' `
  -replace '<Link href="#booking">', '<Link href="/booking">' `
  | Set-Content src/app/Hero.tsx -Encoding UTF8

# 3. Reinstate stepper UI + airport dropdown in booking page
Set-Content src/app/booking/page.tsx -Encoding UTF8 @'
"use client";

import { useState, useEffect, useRef } from "react";

type RideType = "to-airport" | "from-airport" | "non-airport";

const AIRPORTS = [
  "Dallas/Fort Worth International Airport (DFW)",
  "Dallas Love Field (DAL)",
  "Waco Regional Airport (ACT)",
  "Tyler Pounds Regional Airport (TYR)",
  "Abilene Regional Airport (ABI)",
  "Austin-Bergstrom International Airport (AUS)",
];

export default function BookingPage() {
  const [step, setStep] = useState(1);
  const [rideType, setRideType] = useState<RideType>("to-airport");
  const [pickup, setPickup] = useState("");
  const [dropoff, setDropoff] = useState("");
  const [airport, setAirport] = useState("");

  const pickupRef = useRef<HTMLInputElement>(null);
  const dropoffRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    const loader = new google.maps.places.Autocomplete(pickupRef.current!);
    loader.addListener("place_changed", () => {
      const place = loader.getPlace();
      setPickup(place.formatted_address || "");
    });
    if (dropoffRef.current) {
      const loader2 = new google.maps.places.Autocomplete(dropoffRef.current);
      loader2.addListener("place_changed", () => {
        const place = loader2.getPlace();
        setDropoff(place.formatted_address || "");
      });
    }
  }, []);

  const handleNext = () => setStep(step + 1);

  return (
    <div className="min-h-screen bg-jetblue text-white flex flex-col items-center justify-center">
      <h1 className="text-3xl font-bold mb-6">Book Your Airport Ride</h1>

      {/* Stepper */}
      <div className="flex items-center mb-6 space-x-4">
        {[1, 2, 3].map((s) => (
          <div
            key={s}
            className={`w-8 h-8 flex items-center justify-center rounded-full ${
              step === s ? "bg-jetyellow text-black" : "bg-gray-600"
            }`}
          >
            {s}
          </div>
        ))}
      </div>

      {/* Step 1 */}
      {step === 1 && (
        <div className="bg-jetdark p-6 rounded-2xl shadow-lg w-full max-w-md">
          <h2 className="text-xl font-semibold mb-4">Step 1: Enter Details</h2>
          <div className="flex space-x-4 mb-4">
            <label><input type="radio" checked={rideType === "to-airport"} onChange={() => setRideType("to-airport")} /> To Airport</label>
            <label><input type="radio" checked={rideType === "from-airport"} onChange={() => setRideType("from-airport")} /> From Airport</label>
            <label><input type="radio" checked={rideType === "non-airport"} onChange={() => setRideType("non-airport")} /> Non-Airport</label>
          </div>

          {rideType !== "from-airport" && (
            <input ref={pickupRef} placeholder="Pickup Address" className="w-full p-2 rounded text-black mb-3" />
          )}

          {rideType !== "to-airport" && (
            <input ref={dropoffRef} placeholder="Dropoff Address" className="w-full p-2 rounded text-black mb-3" />
          )}

          {(rideType === "to-airport" || rideType === "from-airport") && (
            <select
              className="w-full p-2 rounded text-black mb-3"
              value={airport}
              onChange={(e) => setAirport(e.target.value)}
            >
              <option value="">Select Airport</option>
              {AIRPORTS.map((a) => (
                <option key={a}>{a}</option>
              ))}
            </select>
          )}

          <button onClick={handleNext} className="bg-jetyellow text-black font-semibold px-4 py-2 rounded">
            Next
          </button>
        </div>
      )}

      {/* Step 2 */}
      {step === 2 && (
        <div className="bg-jetdark p-6 rounded-2xl shadow-lg w-full max-w-md text-center">
          <h2 className="text-xl font-semibold mb-4">Step 2: Quote</h2>
          <p>Your quote will be calculated here.</p>
          <button onClick={handleNext} className="mt-4 bg-jetyellow text-black px-4 py-2 rounded">Proceed to Booking</button>
        </div>
      )}

      {/* Step 3 */}
      {step === 3 && (
        <div className="bg-jetdark p-6 rounded-2xl shadow-lg w-full max-w-md text-center">
          <h2 className="text-xl font-semibold mb-4">Step 3: Booking Confirmation</h2>
          <p>Confirm your ride details and complete booking.</p>
        </div>
      )}
    </div>
  );
}
'@

Write-Host "✅ All fixes applied. Ready to build."
