"use client";
/* global google */
import { useLoadScript, Autocomplete } from "@react-google-maps/api";
import { useRef, useState } from "react";
import { AIRPORTS } from "@/lib/airports";

type Mode = "TO_AIRPORT" | "FROM_AIRPORT" | "POINT_TO_POINT";

const LIBS: ("places")[] = ["places"];

function getInputValue(id: string) {
  const el = document.getElementById(id) as HTMLInputElement | null;
  return (el?.value ?? "").trim();
}

export default function QuoteForm() {
  const { isLoaded, loadError } = useLoadScript({
    googleMapsApiKey: process.env.NEXT_PUBLIC_GOOGLE_MAPS_API_KEY as string,
    libraries: LIBS,
  });

  const [mode, setMode] = useState<Mode>("TO_AIRPORT");
  const [airport, setAirport] = useState("DFW");

  const [pax, setPax] = useState(1);
  const [bags, setBags] = useState(0);
  const [wait, setWait] = useState(0);

  const originAC = useRef<google.maps.places.Autocomplete | null>(null);
  const destAC   = useRef<google.maps.places.Autocomplete | null>(null);

  const showOrigin = mode !== "FROM_AIRPORT"; // need street for origin unless From Airport
  const showDest   = mode !== "TO_AIRPORT";   // need street for dest unless To Airport

  const [quote, setQuote] = useState<any>(null);
  const [loading, setLoading] = useState(false);

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();

    // Text from Autocomplete (if user picked a suggestion) or raw input
    const originText =
      originAC.current?.getPlace()?.formatted_address || getInputValue("origin");
    const destText =
      destAC.current?.getPlace()?.formatted_address || getInputValue("dest");

    // Resolve final origin/destination based on mode
    const origin =
      mode === "FROM_AIRPORT" ? airport : originText;
    const dest =
      mode === "TO_AIRPORT" ? airport : destText;

    if (!origin || !dest) {
      alert("Please enter a valid address.");
      return;
    }

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
          pax,
          bags,
          p2pWaitMinutes: mode === "POINT_TO_POINT" ? wait : 0,
        }),
      });
      setQuote(await resp.json());
    } finally {
      setLoading(false);
    }
  }

  return (
    <div id="quote" className="bg-white rounded-xl shadow p-5 md:p-6 -mt-10 mx-4 md:mx-auto md:max-w-3xl">
      <form onSubmit={onSubmit} className="space-y-4">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
          <select
            className="border rounded p-2"
            value={mode}
            onChange={(e) => setMode(e.target.value as Mode)}
          >
            <option value="TO_AIRPORT">To Airport</option>
            <option value="FROM_AIRPORT">From Airport</option>
            <option value="POINT_TO_POINT">Point-to-Point</option>
          </select>

          <select
            className="border rounded p-2"
            value={airport}
            onChange={(e) => setAirport(e.target.value)}
            disabled={mode === "POINT_TO_POINT"}
          >
            {AIRPORTS.map((a) => (
              <option key={a.code} value={a.code}>
                {a.display}
              </option>
            ))}
          </select>

          <input type="datetime-local" className="border rounded p-2" required />
        </div>

        {loadError && (
          <div className="text-sm text-red-600">
            Google Maps failed to load. Check{" "}
            <code>NEXT_PUBLIC_GOOGLE_MAPS_API_KEY</code> and allowed referrers
            for <strong>jetsetdirect.com</strong> and <strong>www.jetsetdirect.com</strong>.
          </div>
        )}

        {isLoaded && (
          <div
            className={`grid grid-cols-1 ${
              showOrigin && showDest ? "md:grid-cols-2" : ""
            } gap-3`}
          >
            {showOrigin && (
              <div className="flex flex-col gap-1">
                <label className="text-sm font-medium">
                  {mode === "TO_AIRPORT" ? "Pickup Address" : "Origin Address"}
                </label>
                <Autocomplete
                  onLoad={(ac) => {
                    originAC.current = ac;
                    ac.setFields?.(["formatted_address", "geometry"]);
                  }}
                  options={{
                    fields: ["formatted_address", "geometry"],
                    componentRestrictions: { country: ["us"] },
                  }}
                >
                  <input
                    id="origin"
                    className="border rounded p-2 w-full"
                    placeholder="Start typing…"
                  />
                </Autocomplete>
              </div>
            )}

            {showDest && (
              <div className="flex flex-col gap-1">
                <label className="text-sm font-medium">
                  {mode === "FROM_AIRPORT" ? "Drop-off Address" : "Destination Address"}
                </label>
                <Autocomplete
                  onLoad={(ac) => {
                    destAC.current = ac;
                    ac.setFields?.(["formatted_address", "geometry"]);
                  }}
                  options={{
                    fields: ["formatted_address", "geometry"],
                    componentRestrictions: { country: ["us"] },
                  }}
                >
                  <input
                    id="dest"
                    className="border rounded p-2 w-full"
                    placeholder="Start typing…"
                  />
                </Autocomplete>
              </div>
            )}
          </div>
        )}

        <div className="grid grid-cols-3 gap-3">
          <div className="flex flex-col gap-1">
            <label className="text-sm font-medium">Passengers</label>
            <input
              className="border rounded p-2"
              type="number"
              min={1}
              value={pax}
              onChange={(e) => setPax(+e.target.value)}
            />
          </div>

          <div className="flex flex-col gap-1">
            <label className="text-sm font-medium">Bags</label>
            <input
              className="border rounded p-2"
              type="number"
              min={0}
              value={bags}
              onChange={(e) => setBags(+e.target.value)}
            />
          </div>

          {mode === "POINT_TO_POINT" ? (
            <div className="flex flex-col gap-1">
              <label className="text-sm font-medium">Wait (min)</label>
              <input
                className="border rounded p-2"
                type="number"
                min={0}
                value={wait}
                onChange={(e) => setWait(+e.target.value)}
              />
            </div>
          ) : (
            <div className="flex items-end text-sm text-gray-500">
              No wait time for airport trips
            </div>
          )}
        </div>

        <button
          className="px-6 py-3 rounded font-semibold text-[#0F1F39]"
          style={{ background: "#FBC02D" }}
          disabled={loading}
        >
          {loading ? "Calculating..." : "Get Instant Quote"}
        </button>
      </form>

      {quote && (
        <div className="mt-5 border-t pt-4">
          <h3 className="font-semibold mb-2">Instant Quote</h3>
          <div className="text-sm text-gray-700">
            <div>
              Distance: {quote.distanceMiles.toFixed(1)} mi • Time:{" "}
              {quote.durationMinutes.toFixed(0)} min
            </div>
            <ul className="mt-2 space-y-1">
              <li>Base: ${(quote.breakdown.baseCents / 100).toFixed(2)}</li>
              <li>Per-mile: ${(quote.breakdown.distanceCents / 100).toFixed(2)}</li>
              <li>Per-minute: ${(quote.breakdown.timeCents / 100).toFixed(2)}</li>
              {quote.breakdown.airportFeeCents ? (
                <li>
                  Airport fee: ${(quote.breakdown.airportFeeCents / 100).toFixed(2)}
                </li>
              ) : null}
              {quote.breakdown.waitCents ? (
                <li>
                  Wait time: ${(quote.breakdown.waitCents / 100).toFixed(2)}{" "}
                  <span className="text-gray-500">(Point‑to‑Point only)</span>
                </li>
              ) : null}
            </ul>
            <div className="mt-3 text-lg font-bold">
              Total: ${(quote.totalCents / 100).toFixed(2)}
            </div>
            <a
              href="/booking"
              className="inline-block mt-4 px-4 py-2 rounded text-white"
              style={{ background: "#0F1F39" }}
            >
              Book This Ride
            </a>
          </div>
        </div>
      )}
    </div>
  );
}
