import * as React from "react";
import GooglePlacesInput from "./GooglePlacesInput";

type Mode = "TO_AIRPORT" | "FROM_AIRPORT" | "POINT_TO_POINT";

export default function BookingWizard() {
  const [step, setStep] = React.useState<1|2|3>(1);

  // Step 1 data
  const [pickup, setPickup] = React.useState("");
  const [dropoff, setDropoff] = React.useState("");
  const [mode, setMode] = React.useState<Mode>("TO_AIRPORT");
  const [pickupAt, setPickupAt] = React.useState<string>("");
  const [pax, setPax] = React.useState<number>(2);
  const [vehicle, setVehicle] = React.useState<string>("SEDAN");

  // Step 2 data (quote)
  const [quote, setQuote] = React.useState<any>(null);
  const [quoting, setQuoting] = React.useState(false);
  const [quoteErr, setQuoteErr] = React.useState<string | null>(null);

  // Step 3 data (contact + book)
  const [name, setName] = React.useState("");
  const [email, setEmail] = React.useState("");
  const [phone, setPhone] = React.useState("");
  const [booking, setBooking] = React.useState(false);
  const [bookErr, setBookErr] = React.useState<string | null>(null);

  async function getQuote() {
    setQuoteErr(null);
    setQuoting(true);
    try {
      const res = await fetch("/api/quote", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          pickup,
          dropoff,
          mode,
          pax,
          vehicle,
          when: pickupAt || null
        }),
      });
      if (!res.ok) throw new Error(`Quote failed (${res.status})`);
      const data = await res.json();
      setQuote(data);
      setStep(2);
    } catch (e: any) {
      setQuoteErr(e.message || "Could not fetch quote.");
    } finally {
      setQuoting(false);
    }
  }

  async function bookNow() {
    if (!quote?.total) { setBookErr("Missing quote."); return; }
    setBookErr(null);
    setBooking(true);
    try {
      const res = await fetch("/api/bookings", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          customerName: name,
          customerEmail: email,
          phone,
          pickupAddress: pickup,
          dropoffAddress: dropoff || null,
          mode,
          pickupAt: pickupAt || null,
          quotedTotal: Number(quote.total),
          pax,
          vehicle,
          breakdown: quote.breakdown ?? null
        }),
      });
      if (!res.ok) throw new Error(`Booking failed (${res.status})`);
      // Optional: parse response for booking id
      window.location.href = "/Success";
    } catch (e: any) {
      setBookErr(e.message || "Could not complete booking.");
    } finally {
      setBooking(false);
    }
  }

  const canStep1 = pickup && (mode !== "TO_AIRPORT" ? dropoff : true) && pax > 0;

  return (
    <div className="space-y-8">
      <ol className="flex flex-wrap items-center gap-3 text-sm">
        <li className={`rounded-full px-3 py-1 ${step>=1?"bg-slate-900 text-white":"bg-slate-100"}`}>1 · Trip</li>
        <li className={`rounded-full px-3 py-1 ${step>=2?"bg-slate-900 text-white":"bg-slate-100"}`}>2 · Quote</li>
        <li className={`rounded-full px-3 py-1 ${step>=3?"bg-slate-900 text-white":"bg-slate-100"}`}>3 · Book</li>
      </ol>

      {step === 1 && (
        <section className="grid gap-6 md:grid-cols-2">
          <div className="space-y-4">
            <label className="block text-sm font-medium">
              Pickup
              <GooglePlacesInput
                value={pickup}
                onChange={setPickup}
                placeholder="Start address"
                required
              />
            </label>

            {mode !== "TO_AIRPORT" && (
              <label className="block text-sm font-medium">
                Dropoff
                <GooglePlacesInput
                  value={dropoff}
                  onChange={setDropoff}
                  placeholder="Destination address"
                  required
                />
              </label>
            )}

            <label className="block text-sm font-medium">
              Date & Time
              <input
                type="datetime-local"
                className="mt-1 w-full rounded-xl border px-3 py-2"
                value={pickupAt}
                onChange={(e)=>setPickupAt(e.target.value)}
              />
            </label>
          </div>

          <div className="space-y-4">
            <fieldset className="space-y-2">
              <legend className="text-sm font-medium">Trip Type</legend>
              <div className="flex gap-3">
                {(["TO_AIRPORT","FROM_AIRPORT","POINT_TO_POINT"] as const).map(m => (
                  <label key={m} className="flex items-center gap-2">
                    <input
                      type="radio"
                      name="mode"
                      value={m}
                      checked={mode===m}
                      onChange={()=>setMode(m)}
                    />
                    <span>{m.replaceAll("_"," ").toLowerCase()}</span>
                  </label>
                ))}
              </div>
            </fieldset>

            <label className="block text-sm font-medium">
              Passengers
              <input
                type="number"
                min={1}
                max={10}
                className="mt-1 w-full rounded-xl border px-3 py-2"
                value={pax}
                onChange={(e)=>setPax(Number(e.target.value || 1))}
              />
            </label>

            <label className="block text-sm font-medium">
              Vehicle
              <select
                className="mt-1 w-full rounded-xl border px-3 py-2"
                value={vehicle}
                onChange={(e)=>setVehicle(e.target.value)}
              >
                <option value="SEDAN">Sedan (1–3)</option>
                <option value="SUV">SUV (1–6)</option>
                <option value="VAN">Van (1–10)</option>
              </select>
            </label>

            <button
              className="mt-4 w-full rounded-xl bg-slate-900 px-4 py-2 text-white disabled:opacity-50"
              disabled={!canStep1 || quoting}
              onClick={getQuote}
            >
              {quoting ? "Getting quote…" : "Get Quote"}
            </button>

            {quoteErr && <p className="text-sm text-red-600">{quoteErr}</p>}
          </div>
        </section>
      )}

      {step === 2 && (
        <section className="space-y-4">
          <h3 className="text-lg font-semibold">Your Quote</h3>
          <div className="rounded-xl border p-4">
            <div className="flex items-baseline justify-between">
              <div>
                <div className="text-sm text-slate-600">{mode.replaceAll("_"," ")}</div>
                <div className="font-medium">{pickup}</div>
                {dropoff && <div className="font-medium">→ {dropoff}</div>}
                {pickupAt && <div className="text-sm text-slate-500 mt-1">{new Date(pickupAt).toLocaleString()}</div>}
              </div>
              <div className="text-2xl font-bold">${Number(quote?.total ?? 0).toFixed(2)}</div>
            </div>
            {quote?.breakdown && (
              <ul className="mt-3 text-sm text-slate-600 list-disc pl-5">
                {Object.entries(quote.breakdown).map(([k,v]) => (
                  <li key={k}>{k}: ${Number(v as any).toFixed(2)}</li>
                ))}
              </ul>
            )}
          </div>

          <div className="flex gap-3">
            <button className="rounded-xl border px-4 py-2" onClick={()=>setStep(1)}>Back</button>
            <button className="rounded-xl bg-slate-900 px-4 py-2 text-white" onClick={()=>setStep(3)}>Continue to Book</button>
          </div>
        </section>
      )}

      {step === 3 && (
        <section className="grid gap-6 md:grid-cols-2">
          <div className="space-y-4">
            <label className="block text-sm font-medium">
              Full Name
              <input className="mt-1 w-full rounded-xl border px-3 py-2" value={name} onChange={(e)=>setName(e.target.value)} />
            </label>
            <label className="block text-sm font-medium">
              Email
              <input className="mt-1 w-full rounded-xl border px-3 py-2" type="email" value={email} onChange={(e)=>setEmail(e.target.value)} />
            </label>
            <label className="block text-sm font-medium">
              Phone
              <input className="mt-1 w-full rounded-xl border px-3 py-2" value={phone} onChange={(e)=>setPhone(e.target.value)} />
            </label>
          </div>

          <div className="space-y-4">
            <div className="rounded-xl border p-4">
              <div className="flex items-baseline justify-between">
                <div className="text-sm text-slate-600">Total</div>
                <div className="text-2xl font-bold">${Number(quote?.total ?? 0).toFixed(2)}</div>
              </div>
              <p className="mt-2 text-sm text-slate-600">
                You can log in later for faster checkout; for now we’ll book this as a guest.
              </p>
            </div>

            <div className="flex gap-3">
              <button className="rounded-xl border px-4 py-2" onClick={()=>setStep(2)}>Back</button>
              <button className="rounded-xl bg-slate-900 px-4 py-2 text-white disabled:opacity-50" disabled={booking} onClick={bookNow}>
                {booking ? "Booking…" : "Book Now"}
              </button>
            </div>

            {bookErr && <p className="text-sm text-red-600">{bookErr}</p>}
          </div>
        </section>
      )}
    </div>
  );
}
