import Link from "next/link";
import * as ui from "../components/ui.css";

export default function Home() {
  return (
    <div style={{display:"grid", gap:24}}>
      <section className={ui.card} style={{background:"#0f172a", color:"#fff"}}>
        <h1 style={{fontSize:"28px", marginBottom:8}}>Private Car Service · On-time Airport Transfers</h1>
        <p style={{opacity:.9}}>Transparent pricing, pro drivers, and seamless booking.</p>
        <div style={{display:"flex", gap:12, marginTop:16}}>
          <Link href="/booking" className={ui.buttonPrimary} style={{textDecoration:"none"}}>Get Quote</Link>
          <Link href="/booking" className={ui.buttonSecondary} style={{textDecoration:"none"}}>Book Now</Link>
        </div>
      </section>

      <section className={ui.grid2}>
        {[
          ["On-Time Pickup","We track flights & traffic."],
          ["Transparent Pricing","No surprises. Tip optional."],
          ["Pro Vehicles","Sedans, SUVs, and vans."],
        ].map(([t,s]) => (
          <div key={t} className={ui.card}>
            <div style={{fontWeight:600}}>{t}</div>
            <div style={{color:"#475569", marginTop:6}}>{s}</div>
          </div>
        ))}
      </section>
    </div>
  );
}
