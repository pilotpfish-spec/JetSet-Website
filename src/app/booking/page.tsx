"use client";
import { useState, useEffect, useRef } from "react";
import Script from "next/script";
import { ctaButton } from "@/styles/global.css";

type RideType = "toAirport" | "fromAirport" | "nonAirport";

// Tell TypeScript about Google Maps API
declare global {
  interface Window {
    google: typeof google;
  }
}

const airports = [
  "Dallas/Fort Worth International Airport (DFW)",
  "Dallas Love Field (DAL)",
  "Fort Worth Meacham International (FTW)",
  "Dallas Executive Airport (RBD)",
  "Arlington Municipal Airport (GKY)"
];

export default function BookingPage() {
  const [step, setStep] = useState(1);
  const [rideType, setRideType] = useState<RideType>("toAirport");
  const pickupRef = useRef<HTMLInputElement | null>(null);
  const dropoffRef = useRef<HTMLInputElement | null>(null);

  useEffect(() => {
    if (typeof window !== "undefined" && window.google?.maps?.places) {
      const options: google.maps.places.AutocompleteOptions = { types: ["geocode"] };
      if (pickupRef.current) new google.maps.places.Autocomplete(pickupRef.current, options);
      if (dropoffRef.current) new google.maps.places.Autocomplete(dropoffRef.current, options);
    }
  }, [rideType]);

  const renderStep1 = () => (
    <div style={{
      background: "#0a192f", padding: "2rem", borderRadius: "1rem",
      boxShadow: "0 6px 12px rgba(0,0,0,0.3)", maxWidth: "500px", margin: "0 auto"
    }}>
      <h2 style={{ marginBottom: "1rem" }}>Step 1: Enter Details</h2>
      <div style={{ display: "flex", gap: "1rem", marginBottom: "1rem" }}>
        <label><input type="radio" checked={rideType==="toAirport"} onChange={() => setRideType("toAirport")} /> To Airport</label>
        <label><input type="radio" checked={rideType==="fromAirport"} onChange={() => setRideType("fromAirport")} /> From Airport</label>
        <label><input type="radio" checked={rideType==="nonAirport"} onChange={() => setRideType("nonAirport")} /> Non-Airport</label>
      </div>

      {rideType !== "fromAirport" && (
        <input ref={pickupRef} placeholder="Pickup Address" style={{ width: "100%", padding: "0.75rem", marginBottom: "1rem" }} required />
      )}

      {rideType !== "toAirport" && (
        <input ref={dropoffRef} placeholder="Drop-off Address" style={{ width: "100%", padding: "0.75rem", marginBottom: "1rem" }} required />
      )}

      <select style={{ width: "100%", padding: "0.75rem", marginBottom: "1rem" }} required>
        <option value="">Select Airport</option>
        {airports.map((airport) => <option key={airport}>{airport}</option>)}
      </select>

      <button className={ctaButton} onClick={() => setStep(2)}>Next</button>
    </div>
  );

  return (
    <>
      <Script src={`https://maps.googleapis.com/maps/api/js?key=${process.env.NEXT_PUBLIC_GOOGLE_MAPS_API_KEY}&libraries=places`} strategy="afterInteractive" />
      <h1 style={{ textAlign: "center", margin: "2rem 0" }}>Book Your Airport Ride</h1>
      <div style={{ display: "flex", justifyContent: "center", gap: "1rem", marginBottom: "2rem" }}>
        {[1,2,3].map((s) => (
          <div key={s} style={{
            width: "40px", height: "40px", borderRadius: "50%",
            backgroundColor: s===step ? "#facc15" : "#374151",
            display: "flex", alignItems: "center", justifyContent: "center", color: "black"
          }}>{s}</div>
        ))}
      </div>
      {step===1 && renderStep1()}
    </>
  );
}
