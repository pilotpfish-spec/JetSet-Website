import * as React from "react";
import * as ui from "./ui.css";
import GooglePlacesInput from "./GooglePlacesInput";

type Mode = "TO_AIRPORT" | "FROM_AIRPORT" | "POINT_TO_POINT";

export default function BookingWizard() {
  const [step, setStep] = React.useState<1|2|3>(1);
  const [pickup, setPickup] = React.useState("");
  const [dropoff, setDropoff] = React.useState("");
  const [mode, setMode] = React.useState<Mode>("TO_AIRPORT");
  const [pickupAt, setPickupAt] = React.useState<string>("");
  const [pax, setPax] = React.useState<number>(2);
  const [vehicle, setVehicle] = React.useState<string>("SEDAN");

  const [quote, setQuote] = React.useState<any>(null);
  const [quoting, setQuoting] = React.useState(false);
  const [quoteErr, setQuoteErr] = React.useState<string | null>(null);

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
        body: JSON.stringify({ pickup, dropoff, mode, pax, vehicle, when: pickupAt || null }),
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
      window.location.href = "/Success";
    } catch (e: any) {
      setBookErr(e.message || "Could not complete booking.");
    } finally {
      setBooking(false);
    }
  }

  const canStep1 = pickup && (mode !== "TO_AIRPORT" ? !!dropoff : true) && pax > 0;

  return (
    <div style={{display:"grid", gap:24}}>
      <ol style={{display:"flex", gap:8, flexWrap:"wrap"}}>
        <li className={step>=1?ui.stepPillActive:ui.stepPill}>1 · Trip</li>
        <li className={step>=2?ui.stepPillActive:ui.stepPill}>2 · Quote</li>
        <li className={step>=3?ui.stepPillActive:ui.stepPill}>3 · Book</li>
      </ol>

      {step === 1 && (
        <section className={ui.grid2}>
          <div style={{display:"grid", gap:16}}>
            <label style={{fontSize:14, fontWeight:500}}>
              Pickup
              <GooglePlacesInput value={pickup} onChange={setPickup} placeholder="Start address" className={ui.input}/>
            </label>

            {mode !== "TO_AIRPORT" && (
              <label style={{fontSize:14, fontWeight:500}}>
                Dropoff
                <GooglePlacesInput value={dropoff} onChange={setDropoff} placeholder="Destination address" className={ui.input}/>
              </label>
            )}

            <label style={{fontSize:14, fontWeight:500}}>
              Date &amp; Time
              <input type="datetime-local" className={ui.input} value={pickupAt} onChange={(e)=>setPickupAt(e.target.value)} />
            </label>
          </div>

          <div className={ui.card} style={{display:"grid", gap:12}}>
            <fieldset style={{display:"grid", gap:8, border:"0", padding:"0"}}>
              <legend style={{fontSize:14, fontWeight:600, marginBottom:4}}>Trip Type</legend>
              <div style={{display:"flex", gap:12}}>
                {(["TO_AIRPORT","FROM_AIRPORT","POINT_TO_POINT"] as const).map(m => (
                  <label key={m} style={{display:"flex", alignItems:"center", gap:6}}>
                    <input type="radio" name="mode" value={m} checked={mode===m} onChange={()=>setMode(m)} />
                    <span>{m.replaceAll("_"," ").toLowerCase()}</span>
                  </label>
                ))}
              </div>
            </fieldset>

            <label style={{fontSize:14, fontWeight:500}}>
              Passengers
              <input type="number" min={1} max={10} className={ui.input} value={pax} onChange={(e)=>setPax(Number(e.target.value || 1))} />
            </label>

            <label style={{fontSize:14, fontWeight:500}}>
              Vehicle
              <select className={ui.select} value={vehicle} onChange={(e)=>setVehicle(e.target.value)}>
                <option value="SEDAN">Sedan (1–3)</option>
                <option value="SUV">SUV (1–6)</option>
                <option value="VAN">Van (1–10)</option>
              </select>
            </label>

            <button className={ui.buttonPrimary} disabled={!canStep1 || quoting} onClick={getQuote}>
              {quoting ? "Getting quote…" : "Get Quote"}
            </button>
            {quoteErr && <p style={{color:"#dc2626", fontSize:14}}>{quoteErr}</p>}
          </div>
        </section>
      )}

      {step === 2 && (
        <section className={ui.card} style={{display:"grid", gap:16}}>
          <h3 style={{fontSize:18, fontWeight:600}}>Your Quote</h3>
          <div style={{display:"flex", justifyContent:"space-between", alignItems:"baseline"}}>
            <div>
              <div style={{fontSize:14, color:"#475569"}}>{mode.replaceAll("_"," ")}</div>
              <div style={{fontWeight:600}}>{pickup}</div>
              {dropoff && <div style={{fontWeight:600}}>→ {dropoff}</div>}
              {pickupAt && <div style={{fontSize:13, color:"#64748b", marginTop:4}}>{new Date(pickupAt).toLocaleString()}</div>}
            </div>
            <div style={{fontSize:24, fontWeight:700}}>${Number(quote?.total ?? 0).toFixed(2)}</div>
          </div>
          {quote?.breakdown && (
            <ul style={{margin:0, paddingLeft:18, color:"#475569", fontSize:14}}>
              {Object.entries(quote.breakdown).map(([k,v]) => (
                <li key={k}>{k}: ${Number(v as any).toFixed(2)}</li>
              ))}
            </ul>
          )}
          <div style={{display:"flex", gap:12}}>
            <button className={ui.buttonSecondary} onClick={()=>setStep(1)}>Back</button>
            <button className={ui.buttonPrimary} onClick={()=>setStep(3)}>Continue to Book</button>
          </div>
        </section>
      )}

      {step === 3 && (
        <section className={ui.grid2}>
          <div style={{display:"grid", gap:16}}>
            <label style={{fontSize:14, fontWeight:500}}>
              Full Name
              <input className={ui.input} value={name} onChange={(e)=>setName(e.target.value)} />
            </label>
            <label style={{fontSize:14, fontWeight:500}}>
              Email
              <input className={ui.input} type="email" value={email} onChange={(e)=>setEmail(e.target.value)} />
            </label>
            <label style={{fontSize:14, fontWeight:500}}>
              Phone
              <input className={ui.input} value={phone} onChange={(e)=>setPhone(e.target.value)} />
            </label>
          </div>

          <div className={ui.card} style={{display:"grid", gap:12}}>
            <div style={{display:"flex", justifyContent:"space-between", alignItems:"baseline"}}>
              <div style={{fontSize:14, color:"#475569"}}>Total</div>
              <div style={{fontSize:24, fontWeight:700}}>${Number(quote?.total ?? 0).toFixed(2)}</div>
            </div>
            <p style={{fontSize:14, color:"#475569"}}>
              You can log in later for faster checkout; for now we’ll book this as a guest.
            </p>
            <div style={{display:"flex", gap:12}}>
              <button className={ui.buttonSecondary} onClick={()=>setStep(2)}>Back</button>
              <button className={ui.buttonPrimary} disabled={booking} onClick={bookNow}>
                {booking ? "Booking…" : "Book Now"}
              </button>
            </div>
            {bookErr && <p style={{color:"#dc2626", fontSize:14}}>{bookErr}</p>}
          </div>
        </section>
      )}
    </div>
  );
}
