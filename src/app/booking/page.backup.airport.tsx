"use client";
import { useState, useEffect } from "react";
import Script from "next/script";
import { ctaButton, colors } from "@/styles/global.css";

declare global {
  interface Window {
    google: typeof google;
  }
  interface HTMLInputElement {
    _autocomplete?: google.maps.places.Autocomplete;
  }
}

export default function BookingPage() {
  const [step, setStep] = useState(1);
  const [tripType, setTripType] = useState<"to" | "from" | "non">("to");

  useEffect(() => {
    if (typeof window !== "undefined" && window.google) {
      const attachAutocomplete = (id: string) => {
        const input = document.getElementById(id) as HTMLInputElement | null;
        if (input && !input._autocomplete) {
          const ac = new window.google.maps.places.Autocomplete(input, { types: ["geocode"] });
          input._autocomplete = ac;

          input.addEventListener("keydown", (e: KeyboardEvent) => {
            if (e.key === "Enter" && !(ac.getPlace instanceof Function)) {
              e.preventDefault();
            }
          });
        }
      };
      if (tripType !== "from") attachAutocomplete("pickup");
      if (tripType !== "to") attachAutocomplete("dropoff");
    }
  }, [step, tripType]);

  return (
    <div style={{ padding: "3rem 1rem" }}>
      <h2 style={{ fontSize: "2rem", fontWeight: 700, textAlign: "center", marginBottom: "2rem" }}>
        Book Your Airport Ride
      </h2>

      <div style={{ display: "flex", justifyContent: "center", marginBottom: "3rem" }}>
        {[1, 2, 3].map((num) => (
          <div key={num} style={{ display: "flex", alignItems: "center" }}>
            <div
              style={{
                width: "2.5rem",
                height: "2.5rem",
                borderRadius: "50%",
                backgroundColor: step === num ? colors.yellow : "#374151",
                color: step === num ? colors.navy : "#9ca3af",
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                fontWeight: "bold",
                fontSize: "1.2rem",
              }}
            >
              {num}
            </div>
            {num < 3 && <div style={{ width: "4rem", height: "2px", background: "#6b7280" }} />}
          </div>
        ))}
      </div>

      {step === 1 && (
        <div style={{
          maxWidth: "28rem",
          margin: "0 auto",
          backgroundColor: "rgba(10,25,47,0.85)",
          borderRadius: "0.75rem",
          padding: "2rem",
          boxShadow: "0 8px 24px rgba(0,0,0,0.4)",
          transition: "all 0.3s ease"
        }}>
          <h3 style={{ fontSize: "1.5rem", fontWeight: 600, marginBottom: "1rem" }}>Step 1: Enter Details</h3>

          <div style={{ display: "flex", justifyContent: "center", gap: "1rem", marginBottom: "1.5rem" }}>
            <label><input type="radio" name="trip" checked={tripType==="to"} onChange={() => setTripType("to")} /> To Airport</label>
            <label><input type="radio" name="trip" checked={tripType==="from"} onChange={() => setTripType("from")} /> From Airport</label>
            <label><input type="radio" name="trip" checked={tripType==="non"} onChange={() => setTripType("non")} /> Non-Airport</label>
          </div>

          {tripType !== "from" && (
            <input id="pickup" type="text" placeholder="Pickup Address"
              style={{ width: "100%", padding: "0.75rem", borderRadius: "0.5rem", marginBottom: "1rem", color: "black" }} />
          )}

          {tripType !== "to" && (
            <input id="dropoff" type="text" placeholder="Drop-off Address"
              style={{ width: "100%", padding: "0.75rem", borderRadius: "0.5rem", marginBottom: "1.5rem", color: "black" }} />
          )}

          <button className={ctaButton} onClick={() => setStep(2)}>Next</button>
        </div>
      )}

      <Script
        src={`https://maps.googleapis.com/maps/api/js?key=${process.env.NEXT_PUBLIC_GOOGLE_MAPS_API_KEY}&libraries=places`}
        strategy="afterInteractive"
      />
    </div>
  );
}
