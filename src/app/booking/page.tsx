"use client";
import { useEffect, useRef, useState } from "react";
import Script from "next/script";
import { ctaButton } from "@/styles/global.css";

type Mode = "to-airport" | "from-airport" | "non-airport";

declare global {
  interface Window {
    google: typeof google;
  }
}

const fareTable: Record<Mode, { base: number; perMile: number }> = {
  "to-airport": { base: 50, perMile: 3 },
  "from-airport": { base: 55, perMile: 3.2 },
  "non-airport": { base: 40, perMile: 2.5 },
};

export default function BookingPage() {
  const [step, setStep] = useState<number>(1);
  const [mode, setMode] = useState<Mode>("to-airport");

  const pickupRef = useRef<HTMLInputElement | null>(null);
  const dropoffRef = useRef<HTMLInputElement | null>(null);

  const [fare, setFare] = useState<number | null>(null);

  // Autocomplete setup
  useEffect(() => {
    if (typeof window === "undefined" || !window.google?.maps?.places) return;

    const opts: google.maps.places.AutocompleteOptions = { types: ["geocode"] };
    if (pickupRef.current) new google.maps.places.Autocomplete(pickupRef.current, opts);
    if (dropoffRef.current) new google.maps.places.Autocomplete(dropoffRef.current, opts);
  }, [step, mode]);

  // Distance Matrix fare calculation
  const calculateFare = () => {
    const pickup = pickupRef.current?.value ?? "";
    const dropoff = dropoffRef.current?.value ?? "";

    if (!pickup || !dropoff) {
      setFare(null);
      return;
    }

    const service = new window.google.maps.DistanceMatrixService();
    service.getDistanceMatrix(
      {
        origins: [pickup],
        destinations: [dropoff],
        travelMode: window.google.maps.TravelMode.DRIVING,
      },
      (response, status) => {
        if (status !== "OK" || !response?.rows[0]?.elements[0]?.distance) {
          console.error("DistanceMatrix failed", status, response);
          setFare(null);
          return;
        }

        const distanceMeters = response.rows[0].elements[0].distance.value;
        const miles = distanceMeters / 1609.34; // meters → miles

        const fareInfo = fareTable[mode];
        const total = fareInfo.base + fareInfo.perMile * miles;

        setFare(Math.round(total));
      }
    );
  };

  return (
    <div className="py-12">
      <Script
        src={`https://maps.googleapis.com/maps/api/js?key=${process.env.NEXT_PUBLIC_GOOGLE_MAPS_API_KEY}&libraries=places`}
        strategy="beforeInteractive"
      />

      <h2 className="text-4xl font-bold text-center mb-12">Book Your Ride</h2>

      {/* Stepper */}
      <div className="flex justify-center mb-12">
        {["Address", "Quote", "Confirm"].map((label, index) => {
          const current = index + 1;
          return (
            <div key={label} className="flex items-center">
              <div
                className={`w-10 h-10 flex items-center justify-center rounded-full font-bold ${
                  step >= current
                    ? "bg-yellow-400 text-navy"
                    : "bg-gray-700 text-gray-400"
                }`}
              >
                {current}
              </div>
              {current < 3 && <div className="w-16 h-[2px] bg-gray-500"></div>}
            </div>
          );
        })}
      </div>

      {/* Step 1: Address entry */}
      {step === 1 && (
        <div className="max-w-xl mx-auto bg-navy/70 backdrop-blur-sm rounded-lg p-8 shadow-xl">
          <h3 className="text-2xl font-semibold mb-6">Step 1: Enter Address</h3>

          <div className="flex space-x-4 mb-6">
            <button
              className={`${ctaButton} ${mode === "to-airport" ? "opacity-100" : "opacity-60"}`}
              onClick={() => setMode("to-airport")}
            >
              To Airport
            </button>
            <button
              className={`${ctaButton} ${mode === "from-airport" ? "opacity-100" : "opacity-60"}`}
              onClick={() => setMode("from-airport")}
            >
              From Airport
            </button>
            <button
              className={`${ctaButton} ${mode === "non-airport" ? "opacity-100" : "opacity-60"}`}
              onClick={() => setMode("non-airport")}
            >
              Non-airport
            </button>
          </div>

          {mode !== "from-airport" && (
            <input
              ref={pickupRef}
              type="text"
              placeholder="Pickup Address"
              className="w-full p-3 rounded mb-4 text-black"
            />
          )}
          {mode !== "to-airport" && (
            <input
              ref={dropoffRef}
              type="text"
              placeholder="Drop-off Address"
              className="w-full p-3 rounded mb-6 text-black"
            />
          )}

          <button
            className={ctaButton}
            onClick={() => {
              calculateFare();
              setStep(2);
            }}
          >
            Next
          </button>
        </div>
      )}

      {/* Step 2: Quote */}
      {step === 2 && (
        <div className="max-w-xl mx-auto bg-navy/70 backdrop-blur-sm rounded-lg p-8 shadow-xl">
          <h3 className="text-2xl font-semibold mb-4">Step 2: Get Quote</h3>
          {fare !== null ? (
            <p className="mb-6">
              Estimated fare: <span className="font-bold">${fare}</span>
            </p>
          ) : (
            <p className="mb-6 text-red-400">Unable to calculate fare.</p>
          )}
          <button className={`${ctaButton} mr-4`} onClick={() => setStep(1)}>
            Back
          </button>
          <button className={ctaButton} onClick={() => setStep(3)}>
            Next
          </button>
        </div>
      )}

      {/* Step 3: Confirm */}
      {step === 3 && (
        <div className="max-w-xl mx-auto bg-navy/70 backdrop-blur-sm rounded-lg p-8 shadow-xl">
          <h3 className="text-2xl font-semibold mb-4">Step 3: Confirm & Book</h3>
          <p className="mb-6">Confirm your booking and we’ll send you an email confirmation.</p>
          <button className={`${ctaButton} mr-4`} onClick={() => setStep(2)}>
            Back
          </button>
          <button className={ctaButton}>Confirm Booking</button>
        </div>
      )}
    </div>
  );
}
