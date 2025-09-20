import * as React from "react";
import { ctaButton } from "@/styles/global.css";
import {
  container, steps, step, stepActive, twoCol, card,
  label, input, select, rowActions, bigTotal
} from "@/styles/ui.css";
import dynamic from "next/dynamic";

const GooglePlacesInput = dynamic(() => import("../../components/GooglePlacesInput"), { ssr: false });

type Mode = "TO_AIRPORT" | "FROM_AIRPORT" | "POINT_TO_POINT";

export default function BookingPage() {
  const [stepNo, setStepNo] = React.useState<1|2|3>(1);

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
      setStepNo(2);
    } catch (e:any) { setQuoteErr(e.message || "Could not fetch quote."); }
    finally { setQuoting(false); }
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
    } catch (e:any) { setBookErr(e.message || "Could not complete booking."); }
    finally { setBooking(false); }
  }

  const canStep1 = pickup && (mode !== "TO_AIRPORT" ? dropoff : true) && pax > 0;

  return (
    <div className={container}>
      <h1 style={{fontSize:24, fontWeight:800, marginBottom:14}}>Book your ride</h1>

      <ol className={steps}>
        <li className={stepNo>=1 ? stepActive : step}>1 · Trip</li>
        <li className={stepNo>=2 ? stepActive : step}>2 · Quote</li>
        <li className={stepNo>=3 ? stepActive : step}>3 · Book</li>
      </ol>

      {stepNo === 1 && (
        <section className={twoCol} style={{marginTop:16}}>
          <div className={card}>
            <label className={label}>Pickup</label>
            <GooglePlacesInput value={pickup} onChange={setPickup} placeholder="Start address" className={input} />

            {mode !== "TO_AIRPORT" && (
              <>
                <label className={label} style={{marginTop:12}}>Dropoff</label>
                <GooglePlacesInput value={dropoff} onChange={setDropoff} placeholder="Destination address" className={input} />
              </>
            )}

            <label className={label} style={{marginTop:12}}>Date & Time</label>
            <input type="datetime-local" className={input} value={pickupAt} onChange={(e)=>setPickupAt(e.target.value)} />
          </div>

          <div className={card}>
            <label className={label}>Trip Type</label>
            <div style={{display:"flex", gap:10, marginTop:6, flexWrap:"wrap"}}>
              {(["TO_AIRPORT","FROM_AIRPORT","POINT_TO_POINT"] as const).map(m => (
                <label key={m} style={{display:"flex", alignItems:"center", gap:6, fontSize:14}}>
                  <input type="radio" name="mode" value={m} checked={mode===m} onChange={()=>setMode(m)} />
                  <span>{m.replaceAll("_"," ").toLowerCase()}</span>
                </label>
              ))}
            </div>

            <label className={label} style={{marginTop:12}}>Passengers</label>
            <input type="number" min={1} max={10} className={input} value={pax} onChange={(e)=>setPax(Number(e.target.value || 1))} />

            <label className={label} style={{marginTop:12}}>Vehicle</label>
            <select className={select} value={vehicle} onChange={(e)=>setVehicle(e.target.value)}>
              <option value="SEDAN">Sedan (1–3)</option>
              <option value="SUV">SUV (1–6)</option>
              <option value="VAN">Van (1–10)</option>
            </select>

            <div className={rowActions}>
              <button className={ctaButton} disabled={!canStep1 || quoting} onClick={getQuote}>
                {quoting ? "Getting quote…" : "Get Quote"}
              </button>
              {quoteErr && <span style={{color:"#ef4444", fontSize:13}}>{quoteErr}</span>}
            </div>
          </div>
        </section>
      )}

      {stepNo === 2 && (
        <section className={card} style={{marginTop:16}}>
          <div style={{display:"flex", justifyContent:"space-between", alignItems:"baseline"}}>
            <div>
              <div style={{color:"#64748b", fontSize:13}}>{mode.replaceAll("_"," ")}</div>
              <div style={{fontWeight:700}}>{pickup}</div>
              {dropoff && <div style={{fontWeight:700}}>→ {dropoff}</div>}
              {pickupAt && <div style={{marginTop:6, color:"#64748b", fontSize:13}}>{new Date(pickupAt).toLocaleString()}</div>}
            </div>
            <div className={bigTotal}>${Number(quote?.total ?? 0).toFixed(2)}</div>
          </div>

          {quote?.breakdown && (
            <ul style={{marginTop:12, color:"#475569", fontSize:14}}>
              {Object.entries(quote.breakdown).map(([k,v]) => (
                <li key={k}>{k}: ${Number(v as any).toFixed(2)}</li>
              ))}
            </ul>
          )}

          <div className={rowActions}>
            <button className={outlineButton} onClick={()=>setStepNo(1)}>Back</button>
            <button className={ctaButton} onClick={()=>setStepNo(3)}>Continue to Book</button>
          </div>
        </section>
      )}

      {stepNo === 3 && (
        <section className={twoCol} style={{marginTop:16}}>
          <div className={card}>
            <label className={label}>Full Name</label>
            <input className={input} value={name} onChange={(e)=>setName(e.target.value)} />

            <label className={label} style={{marginTop:12}}>Email</label>
            <input className={input} type="email" value={email} onChange={(e)=>setEmail(e.target.value)} />

            <label className={label} style={{marginTop:12}}>Phone</label>
            <input className={input} value={phone} onChange={(e)=>setPhone(e.target.value)} />
          </div>

          <div className={card}>
            <div style={{display:"flex", justifyContent:"space-between", alignItems:"baseline"}}>
              <div style={{color:"#64748b", fontSize:13}}>Total</div>
              <div className={bigTotal}>${Number(quote?.total ?? 0).toFixed(2)}</div>
            </div>
            <p style={{marginTop:8, color:"#475569", fontSize:14}}>
              We’ll book this as a guest for now. You can create an account later for faster checkout.
            </p>

            <div className={rowActions}>
              <button className={outlineButton} onClick={()=>setStepNo(2)}>Back</button>
              <button className={ctaButton} disabled={booking} onClick={bookNow}>
                {booking ? "Booking…" : "Book Now"}
              </button>
            </div>

            {bookErr && <p style={{color:"#ef4444", fontSize:13}}>{bookErr}</p>}
          </div>
        </section>
      )}
    </div>
  );
}
