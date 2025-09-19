"use client";
import { useState } from "react";
import Script from "next/script";
import { ctaButton } from "@/styles/global.css";

declare global {
  interface Window {
    google: typeof google;
  }
}

type RideType = "to-airport" | "from-airport" | "non-airport";

const AIRPORTS = [
  { code: "DFW", name: "Dallas/Fort Worth International Airport (DFW)" },
  { code: "DAL", name: "Dallas Love Field (DAL)" },
  { code: "ACT", name: "Waco Regional Airport (ACT)" },
  { code: "ABI", name: "Abilene Regional Airport (ABI)" },
  { code: "LAW", name: "Lawton–Fort Sill Regional Airport (LAW)" },
];

export default function BookingPage() {
  const [step, setStep] = useState<number>(1);
  const [rideType, setRideType] = useState<RideType>("to-airport");
  const [pickup, setPickup] = useState<string>("");
  const [dropoff, setDropoff] = useState<string>("");
  const [airport, setAirport] = useState<string>("");
  const [fare, setFare] = useState<number | null>(null);

  const initAutocomplete = (id: string) => {
    const input = document.getElementById(id) as HTMLInputElement;
    if (!input) return;
    const autocomplete = new window.google.maps.places.Autocomplete(input, {
      fields: ["formatted_address"],
    });
    autocomplete.addListener("place_changed", () => {
      const place = autocomplete.getPlace();
      if (id === "pickup") setPickup(place.formatted_address || "");
      if (id === "dropoff") setDropoff(place.formatted_address || "");
    });
  };

  const handleNext = () => {
    if (rideType === "to-airport" && (!pickup || !airport)) {
      return alert("Please enter a valid pickup and select an airport.");
    }
    if (rideType === "from-airport" && (!dropoff || !airport)) {
      return alert("Please enter a valid drop-off and select an airport.");
    }
    if (rideType === "non-airport" && (!pickup || !dropoff)) {
      return alert("Please enter valid pickup and drop-off addresses.");
    }
    setFare(95); // TODO: replace with real fare calculation
    setStep(2);
  };

  return (
    <div className="py-12">
      <h2 className="text-4xl font-bold text-center mb-12">Book Your Airport Ride</h2>

      {/* Stepper */}
      <div className="flex justify-center mb-12">
        {[1, 2, 3].map((s) => (
          <div key={s} className="flex items-center">
            <div className={`w-10 h-10 flex items-center justify-center rounded-full font-bold ${
              step >= s ? "bg-yellow-400 text-navy" : "bg-gray-700 text-gray-400"
            }`}>
              {s}
            </div>
            {s < 3 && <div className="w-16 h-[2px] bg-gray-500"></div>}
          </div>
        ))}
      </div>

      {/* Steps */}
      <div className="max-w-xl mx-auto bg-navy/70 backdrop-blur-sm rounded-lg p-8 shadow-xl">
        {step === 1 && (
          <div>
            <h3 className="text-2xl font-semibold mb-4">Step 1: Enter Details</h3>

            {/* Ride type */}
            <div className="flex gap-6 mb-6">
              <label>
                <input type="radio" name="rideType" value="to-airport"
                  checked={rideType === "to-airport"}
                  onChange={() => setRideType("to-airport")} />
                <span className="ml-2">To Airport</span>
              </label>
              <label>
                <input type="radio" name="rideType" value="from-airport"
                  checked={rideType === "from-airport"}
                  onChange={() => setRideType("from-airport")} />
                <span className="ml-2">From Airport</span>
              </label>
              <label>
                <input type="radio" name="rideType" value="non-airport"
                  checked={rideType === "non-airport"}
                  onChange={() => setRideType("non-airport")} />
                <span className="ml-2">Non-Airport</span>
              </label>
            </div>

            {/* Address / Airport fields */}
            {rideType === "to-airport" && (
              <>
                <input id="pickup" type="text" placeholder="Pickup Address"
                  defaultValue={pickup}
                  className="w-full p-3 rounded mb-4 text-black" />
                <select className="w-full p-3 rounded mb-6 text-black"
                  value={airport}
                  onChange={(e) => setAirport(e.target.value)}>
                  <option value="">Select Airport</option>
                  {AIRPORTS.map((a) => (
                    <option key={a.code} value={a.name}>{a.name}</option>
                  ))}
                </select>
              </>
            )}

            {rideType === "from-airport" && (
              <>
                <select className="w-full p-3 rounded mb-4 text-black"
                  value={airport}
                  onChange={(e) => setAirport(e.target.value)}>
                  <option value="">Select Airport</option>
                  {AIRPORTS.map((a) => (
                    <option key={a.code} value={a.name}>{a.name}</option>
                  ))}
                </select>
                <input id="dropoff" type="text" placeholder="Drop-off Address"
                  defaultValue={dropoff}
                  className="w-full p-3 rounded mb-6 text-black" />
              </>
            )}

            {rideType === "non-airport" && (
              <>
                <input id="pickup" type="text" placeholder="Pickup Address"
                  defaultValue={pickup}
                  className="w-full p-3 rounded mb-4 text-black" />
                <input id="dropoff" type="text" placeholder="Drop-off Address"
                  defaultValue={dropoff}
                  className="w-full p-3 rounded mb-6 text-black" />
              </>
            )}

            <button className={ctaButton} onClick={handleNext}>Next</button>
          </div>
        )}

        {step === 2 && fare && (
          <div>
            <h3 className="text-2xl font-semibold mb-4">Step 2: Get Quote</h3>
            <p className="mb-6">Estimated fare: <span className="font-bold">${fare}</span></p>
            <button className={ctaButton} onClick={() => setStep(3)}>Proceed to Booking</button>
          </div>
        )}

        {step === 3 && (
          <div>
            <h3 className="text-2xl font-semibold mb-4">Step 3: Confirm & Book</h3>
            <p className="mb-6">
              {rideType === "to-airport" && `From ${pickup} → ${airport}`}<br />
              {rideType === "from-airport" && `${airport} → ${dropoff}`}<br />
              {rideType === "non-airport" && `${pickup} → ${dropoff}`}
            </p>
            <button className={ctaButton}>Confirm Booking</button>
          </div>
        )}
      </div>

      {/* Google Maps Places */}
      <Script src={`https://maps.googleapis.com/maps/api/js?key=${process.env.NEXT_PUBLIC_GOOGLE_MAPS_API_KEY}&libraries=places`}
        onLoad={() => { initAutocomplete("pickup"); initAutocomplete("dropoff"); }
}/>
    </div>
  );
}




