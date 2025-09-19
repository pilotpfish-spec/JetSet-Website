param([string]$ProjectRoot = "C:\website")
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
Set-Location $ProjectRoot

# Hero.tsx
Set-Content -Encoding UTF8 -Path "src\components\Hero.tsx" -Value @'
"use client";
import { useEffect, useState } from "react";
import Link from "next/link";

const NAVY = "#0F1F39";
const GOLD = "#FBC02D";

export default function Hero() {
  const [bgUrl, setBgUrl] = useState<string | null>(null);

  useEffect(() => {
    let alive = true;
    fetch("/api/hero-images")
      .then(r => r.json())
      .then(({ images }) => {
        const pick = images?.length ? images[Math.floor(Math.random()*images.length)] : null;
        if (!pick) return;
        const img = new Image();
        img.onload = () => { if (alive) setBgUrl(pick); };
        img.onerror = () => { if (alive) setBgUrl(null); };
        img.src = pick;
      })
      .catch(() => setBgUrl(null));
    return () => { alive = false; };
  }, []);

  return (
    <section
      style={{ backgroundColor: NAVY, backgroundImage: bgUrl ? `url(${bgUrl})` : "none", backgroundSize: "cover", backgroundPosition: "center" }}
      className="relative h-[70vh] flex items-center justify-center text-white"
    >
      <div className="absolute inset-0 bg-black/40" />
      <div className="relative z-10 max-w-3xl mx-auto text-center px-6">
        <h1 className="text-3xl md:text-5xl font-bold mb-3">
          Ground Service Elevated. The Reason We’re Taking Off.
        </h1>
        <p className="text-base md:text-lg opacity-90">Predictable, insured airport transfers across Texas and neighbors.</p>
        <div className="mt-8 flex gap-4 justify-center">
          <Link href="#quote" className="px-6 py-3 rounded font-semibold" style={{ background: GOLD, color: "#0F1F39" }}>
            Get a Quote (Free)
          </Link>
          <Link href="/admin/login" className="px-6 py-3 rounded font-semibold border" style={{ borderColor: "white" }}>
            Log In / Sign Up
          </Link>
        </div>
      </div>
      <div className="absolute top-6 left-6">
        <img src="/logo.svg" alt="JetSet Direct" className="h-10 md:h-12" />
      </div>
    </section>
  );
}
'@

# QuoteForm.tsx
Set-Content -Encoding UTF8 -Path "src\components\QuoteForm.tsx" -Value @'
"use client";
/* global google */
import { useLoadScript, Autocomplete } from "@react-google-maps/api";
import { useRef, useState } from "react";
import { AIRPORTS } from "@/lib/airports";

type Mode = "TO_AIRPORT" | "FROM_AIRPORT" | "POINT_TO_POINT";

export default function QuoteForm() {
  const { isLoaded } = useLoadScript({
    googleMapsApiKey: process.env.NEXT_PUBLIC_GOOGLE_MAPS_API_KEY as string,
    libraries: ["places"]
  });

  const [mode, setMode] = useState<Mode>("TO_AIRPORT");
  const [airport, setAirport] = useState("DFW");
  const originRef = useRef<google.maps.places.Autocomplete|null>(null);
  const destRef = useRef<google.maps.places.Autocomplete|null>(null);
  const waitInputRef = useRef<HTMLInputElement|null>(null);

  const [quote, setQuote] = useState<any>(null);
  const [loading, setLoading] = useState(false);

  const onSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!isLoaded) return;

    const originPlace = originRef.current?.getPlace();
    const destPlace = destRef.current?.getPlace();

    const origin = originPlace?.formatted_address ?? (document.getElementById("origin") as HTMLInputElement)?.value;
    const dest = destPlace?.formatted_address ?? (document.getElementById("dest") as HTMLInputElement)?.value;
    const waitMins = parseInt(waitInputRef.current?.value || "0", 10) || 0;

    setLoading(true);
    setQuote(null);
    try {
      const resp = await fetch("/api/quote", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          mode,
          airportCode: mode === "POINT_TO_POINT" ? undefined : airport,
          origin,
          dest,
          p2pWaitMinutes: mode === "POINT_TO_POINT" ? waitMins : 0
        })
      });
      const data = await resp.json();
      setQuote(data);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div id="quote" className="bg-white rounded-xl shadow p-5 md:p-6 -mt-10 mx-4 md:mx-auto md:max-w-3xl">
      <form onSubmit={onSubmit} className="space-y-4">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
          <select className="border rounded p-2" value={mode} onChange={e=>setMode(e.target.value as Mode)}>
            <option value="TO_AIRPORT">To Airport</option>
            <option value="FROM_AIRPORT">From Airport</option>
            <option value="POINT_TO_POINT">Point-to-Point</option>
          </select>

        {mode !== "POINT_TO_POINT" ? (
          <select className="border rounded p-2" value={airport} onChange={e=>setAirport(e.target.value)}>
            {AIRPORTS.map(a => <option key={a.code} value={a.code}>{a.display}</option>)}
          </select>
        ) : (
          <div className="text-sm text-gray-600 self-center">No airport fee. Wait time applies if used.</div>
        )}

          <input type="datetime-local" className="border rounded p-2" required />
        </div>

        {isLoaded && (
          <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
            <Autocomplete onLoad={ac => (originRef.current = ac)} options={{ fields: ["formatted_address", "geometry"] }}>
              <input id="origin" className="border rounded p-2" placeholder="Pickup (start typing...)" required />
            </Autocomplete>
            <Autocomplete onLoad={ac => (destRef.current = ac)} options={{ fields: ["formatted_address", "geometry"] }}>
              <input id="dest" className="border rounded p-2" placeholder="Drop-off (start typing...)" required />
            </Autocomplete>
          </div>
        )}

        <div className="grid grid-cols-3 gap-3">
          <input className="border rounded p-2" type="number" min={1} defaultValue={1} placeholder="Pax" />
          <input className="border rounded p-2" type="number" min={0} defaultValue={0} placeholder="Bags" />
          <input ref={waitInputRef} className="border rounded p-2" type="number" min={0} defaultValue={0} placeholder="Wait (min, P2P)" />
        </div>

        <button className="px-6 py-3 rounded font-semibold text-[#0F1F39]" style={{ background: "#FBC02D" }} disabled={loading}>
          {loading ? "Calculating..." : "Get Instant Quote"}
        </button>
      </form>

      {quote && (
        <div className="mt-5 border-t pt-4">
          <h3 className="font-semibold mb-2">Instant Quote</h3>
          <div className="text-sm text-gray-700">
            <div>Distance: {(quote.distanceMiles).toFixed(1)} mi • Time: {(quote.durationMinutes).toFixed(0)} min</div>
            <ul className="mt-2 space-y-1">
              <li>Base: ${ (quote.breakdown.baseCents/100).toFixed(2) }</li>
              <li>Per-mile: ${ (quote.breakdown.distanceCents/100).toFixed(2) }</li>
              <li>Per-minute: ${ (quote.breakdown.timeCents/100).toFixed(2) }</li>
              {quote.breakdown.airportFeeCents ? <li>Airport fee: ${ (quote.breakdown.airportFeeCents/100).toFixed(2) }</li> : null}
              {quote.breakdown.waitCents ? <li>Wait time: ${ (quote.breakdown.waitCents/100).toFixed(2) } <span className="text-gray-500">(Point-to-Point only)</span></li> : null}
            </ul>
            <div className="mt-3 text-lg font-bold">Total: ${ (quote.totalCents/100).toFixed(2) }</div>
            <div className="text-xs text-gray-500 mt-1">Rules: no extra stops; no airport wait; no night surcharge; no cancellation fee.</div>
            <a href="/booking" className="inline-block mt-4 px-4 py-2 rounded text-white" style={{ background: "#0F1F39" }}>
              Book This Ride
            </a>
          </div>
        </div>
      )}
    </div>
  );
}
'@

Write-Host "OK: Components written."
