import Link from "next/link";
import { container, hero, heroTitle, heroSub, heroActions, features, featureCard, outlineButton } from "../styles/ui.css.ts";
import { ctaButton } from "../styles/global.css.ts";

export default function Home() {
  return (
    <div className={container}>
      <section className={hero}>
        <h1 className={heroTitle}>Private Car Service — DFW Airport Transfers</h1>
        <p className={heroSub}>Transparent pricing, professional drivers, easy 1-2-3 booking.</p>
        <div className={heroActions}>
          <Link className={ctaButton} href="/booking">Get Quote</Link>
          <Link className={outlineButton} href="/booking">Book Now</Link>
        </div>
      </section>

      <section className={features}>
        {[
          ["On-Time Pickup","We track flights & traffic."],
          ["Transparent Pricing","No surprises. Tip optional."],
          ["Pro Vehicles","Sedans, SUVs, and vans."],
        ].map(([t,s]) => (
          <div key={t} className={featureCard}>
            <div style={{fontWeight:700}}>{t}</div>
            <div style={{marginTop:6, color:"#334155"}}>{s}</div>
          </div>
        ))}
      </section>
    </div>
  );
}


