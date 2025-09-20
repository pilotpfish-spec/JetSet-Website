"use client";
import { useState } from "react";
import Script from "next/script";
import { ctaButton, colors } from "@/styles/global.css";

export default function BookingPage() {
  const [step, setStep] = useState(1);
  const [pickup, setPickup] = useState("");
  const [dropoff, setDropoff] = useState("");
  const [mode, setMode] = useState("to-airport");

  // Initialize Google Autocomplete
  const initAutocomplete = () => {
    const options = { types: ["address"] };
    const pickupInput = document.getElementById("pickup") as HTMLInputElement;
    const dropoffInput = document.getElementById("dropoff") as HTMLInputElement;
    if (pickupInput) {
      const auto1 = new google.maps.places.Autocomplete(pickupInput, options);
      auto1.addListener("place_changed", () => {
        const place = auto1.getPlace();
        setPickup(place.formatted_address || "");
      });
    }
    if (dropoffInput) {
      const auto2 = new google.maps.places.Autocomplete(dropoffInput, options);
      auto2.addListener("place_changed", () => {
        const place = auto2.getPlace();
        setDropoff(place.formatted_address || "");
      });
    }
  };

  return (
    <div
      style={{
        minHeight: "100vh",
        backgroundColor: colors.navy,
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        padding: "2rem",
      }}
    >
      {/* Google Places Script */}
      <Script
        src={`https://maps.googleapis.com/maps/api/js?key=${process.env.NEXT_PUBLIC_GOOGLE_MAPS_KEY}&libraries=places`}
        onLoad={initAutocomplete}
      />

      {/* Title */}
      <h2 style={{ fontSize: "2.5rem", fontWeight: "bold", marginBottom: "2rem", color: colors.white }}>
        Book Your Airport Ride
      </h2>

      {/* Stepper */}
      <div style={{ display: "flex", justifyContent: "center", marginBottom: "3rem" }}>
        {["Address", "Quote", "Confirm"].map((label, index) => {
          const current = index + 1;
          return (
            <div key={label} style={{ display: "flex", alignItems: "center" }}>
              <div
                style={{
                  width: "2.5rem",
                  height: "2.5rem",
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                  borderRadius: "50%",
                  fontWeight: "bold",
                  backgroundColor: step >= current ? colors.yellow : "#374151",
                  color: step >= current ? colors.navy : "#9ca3af",
                }}
              >
                {current}
              </div>
              {current < 3 && <div style={{ width: "4rem", height: "2px", backgroundColor: "#4b5563" }}></div>}
            </div>
          );
        })}
      </div>

      {/* Step Content */}
      <div
        style={{
          maxWidth: "500px",
          width: "100%",
          backgroundColor: "rgba(10, 25, 47, 0.9)",
          backdropFilter: "blur(6px)",
          borderRadius: "0.75rem",
          padding: "2rem",
          boxShadow: "0 10px 30px rgba(0,0,0,0.6)",
        }}
      >
        {step === 1 && (
          <div>
            <h3 style={{ fontSize: "1.5rem", fontWeight: "600", marginBottom: "1rem" }}>
              Step 1: Enter Details
            </h3>

            {/* Mode Selector */}
            <div style={{ marginBottom: "1.5rem" }}>
              <label style={{ marginRight: "1rem" }}>
                <input type="radio" checked={mode === "to-airport"} onChange={() => setMode("to-airport")} /> To Airport
              </label>
              <label style={{ marginRight: "1rem" }}>
                <input type="radio" checked={mode === "from-airport"} onChange={() => setMode("from-airport")} /> From Airport
              </label>
              <label>
                <input type="radio" checked={mode === "non-airport"} onChange={() => setMode("non-airport")} /> Non-Airport
              </label>
            </div>

            <input
              id="pickup"
              type="text"
              placeholder="Pickup Address"
              defaultValue={pickup}
              style={{ width: "100%", padding: "0.75rem", borderRadius: "0.5rem", marginBottom: "1rem" }}
            />
            <input
              id="dropoff"
              type="text"
              placeholder="Drop-off Address"
              defaultValue={dropoff}
              style={{ width: "100%", padding: "0.75rem", borderRadius: "0.5rem", marginBottom: "1.5rem" }}
            />

            <button className={ctaButton} onClick={() => setStep(2)}>Next</button>
          </div>
        )}

        {step === 2 && (
          <div>
            <h3 style={{ fontSize: "1.5rem", fontWeight: "600", marginBottom: "1rem" }}>
              Step 2: Get Quote
            </h3>
            <p style={{ marginBottom: "1.5rem" }}>
              Mode: <strong>{mode.replace("-", " ")}</strong><br/>
              Pickup: <strong>{pickup}</strong><br/>
              Drop-off: <strong>{dropoff}</strong>
            </p>
            <p style={{ marginBottom: "1.5rem" }}>Estimated fare: <span style={{ fontWeight: "bold" }}>$75</span></p>
            <button className={ctaButton} style={{ marginRight: "1rem" }} onClick={() => setStep(1)}>Back</button>
            <button className={ctaButton} onClick={() => setStep(3)}>Next</button>
          </div>
        )}

        {step === 3 && (
          <div>
            <h3 style={{ fontSize: "1.5rem", fontWeight: "600", marginBottom: "1rem" }}>
              Step 3: Confirm & Book
            </h3>
            <p style={{ marginBottom: "1.5rem" }}>
              Confirm your booking and we’ll send you an email confirmation.
            </p>
            <button className={ctaButton} style={{ marginRight: "1rem" }} onClick={() => setStep(2)}>Back</button>
            <button className={ctaButton}>Confirm Booking</button>
          </div>
        )}
      </div>
    </div>
  );
}
