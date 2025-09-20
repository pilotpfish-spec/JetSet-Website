import Link from "next/link";

export default function Home() {
  return (
    <div className="space-y-10">
      <section className="rounded-2xl bg-gradient-to-br from-slate-900 to-slate-800 px-6 py-12 text-white">
        <h1 className="text-3xl font-bold">Private Car Service · On-time Airport Transfers</h1>
        <p className="mt-3 text-slate-300">Transparent pricing, pro drivers, and seamless booking.</p>
        <div className="mt-6 flex gap-3">
          <Link href="/booking" className="rounded-xl bg-white px-5 py-2 text-slate-900 font-medium">Get Quote</Link>
          <Link href="/booking" className="rounded-xl border border-white/30 px-5 py-2">Book Now</Link>
        </div>
      </section>

      <section className="grid gap-6 md:grid-cols-3">
        {[
          ["On-Time Pickup","We track flights & traffic."],
          ["Transparent Pricing","No surprises. Tip optional."],
          ["Pro Vehicles","Sedans, SUVs, and vans."],
        ].map(([t,s]) => (
          <div key={t} className="rounded-2xl border p-6">
            <div className="text-lg font-semibold">{t}</div>
            <div className="mt-1 text-slate-600">{s}</div>
          </div>
        ))}
      </section>
    </div>
  );
}
