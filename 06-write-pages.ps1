param([string]$ProjectRoot = "C:\website")
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
Set-Location $ProjectRoot

# Landing
Set-Content -Encoding UTF8 -Path "src\app\page.tsx" -Value @'
import Hero from "@/components/Hero";
import QuoteForm from "@/components/QuoteForm";

export default function Landing() {
  return (
    <main>
      <Hero />
      <section className="py-12 bg-[#F5F6F8]">
        <div className="max-w-5xl mx-auto">
          <QuoteForm />
        </div>
      </section>
    </main>
  );
}
'@

# About
Set-Content -Encoding UTF8 -Path "src\app\about\page.tsx" -Value @'
export default function About() {
  return (
    <main className="max-w-3xl mx-auto p-6">
      <h1 className="text-2xl font-bold mb-3">About JetSet Direct</h1>
      <p className="mb-6">Predictable, professional, insured airport transfers - better than rideshare for time-critical trips.</p>
      <a href="/#quote" className="px-4 py-2 rounded text-[#0F1F39]" style={{ background: "#FBC02D" }}>Get a Quote</a>
    </main>
  );
}
'@

# Mission
Set-Content -Encoding UTF8 -Path "src\app\mission\page.tsx" -Value @'
export default function Mission() {
  return (
    <main className="max-w-3xl mx-auto p-6">
      <h1 className="text-2xl font-bold mb-3">Mission</h1>
      <p>Predictable, comfortable, on-time transfers across TX + neighboring states.</p>
      <ul className="list-disc ml-6 my-4">
        <li>Airport-Only</li><li>Predictable Pricing</li><li>Comfort</li><li>On-Time Culture</li>
      </ul>
      <a href="/#quote" className="px-4 py-2 rounded text-[#0F1F39]" style={{ background: "#FBC02D" }}>Get a Quote</a>
    </main>
  );
}
'@

# Fleet
Set-Content -Encoding UTF8 -Path "src\app\fleet\page.tsx" -Value @'
export default function Fleet() {
  return (
    <main className="max-w-3xl mx-auto p-6">
      <h1 className="text-2xl font-bold mb-3">Fleet</h1>
      <p className="mb-2">Silver Ford Flex Limited (6 pax, luggage, premium interior)</p>
      <p className="mb-6 text-sm text-gray-600">Future: Bolt EUV eco option</p>
      <a href="/booking" className="px-4 py-2 rounded text-white" style={{ background: "#0F1F39" }}>Book This Vehicle</a>
    </main>
  );
}
'@

# Insured
Set-Content -Encoding UTF8 -Path "src\app\insured\page.tsx" -Value @'
export default function Insured() {
  return (
    <main className="max-w-3xl mx-auto p-6">
      <h1 className="text-2xl font-bold mb-3">Commercially Insured & Permitted</h1>
      <p className="mb-6">Licensed, insured, and permitted; proof available on request.</p>
      <a href="/#quote" className="px-4 py-2 rounded text-[#0F1F39]" style={{ background: "#FBC02D" }}>Get a Free Quote</a>
    </main>
  );
}
'@

# Contact
Set-Content -Encoding UTF8 -Path "src\app\contact\page.tsx" -Value @'
export default function Contact() {
  return (
    <main className="max-w-4xl mx-auto p-6">
      <h1 className="text-2xl font-bold mb-4">Contact JetSet Direct</h1>
      <form className="grid gap-3">
        <input className="border rounded p-2" placeholder="Name" required />
        <input className="border rounded p-2" placeholder="Email" type="email" required />
        <input className="border rounded p-2" placeholder="Phone" />
        <textarea className="border rounded p-2" placeholder="Message" rows={5} />
        <button className="px-5 py-3 rounded text-[#0F1F39]" style={{ background: "#FBC02D" }}>Submit</button>
      </form>
      <div className="mt-8 aspect-video rounded overflow-hidden">
        <iframe title="Coverage" width="100%" height="100%" loading="lazy"
          src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d857879.629!2d-97.5!3d32.8!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x864e82c6%3A0x9c429f!2sDallas%2FFort%20Worth%20Metroplex!5e0!3m2!1sen!2sus!4v000000000"
          referrerPolicy="no-referrer-when-downgrade" />
      </div>
    </main>
  );
}
'@

# Admin login
Set-Content -Encoding UTF8 -Path "src\app\admin\login\page.tsx" -Value @'
export default function AdminLogin() {
  return (
    <main className="min-h-[60vh] flex items-center justify-center">
      <div className="w-full max-w-sm border rounded-lg p-6">
        <div className="flex justify-center mb-4"><img src="/logo.svg" alt="JetSet Direct" className="h-10" /></div>
        <h1 className="text-xl font-semibold mb-4 text-center">Admin Login</h1>
        <form className="grid gap-3">
          <input className="border rounded p-2" type="email" placeholder="Email" required />
          <input className="border rounded p-2" type="password" placeholder="Password" required />
          <button className="px-4 py-2 rounded text-white" style={{ background: "#0F1F39" }}>Sign In</button>
        </form>
      </div>
    </main>
  );
}
'@

# Admin console placeholder
Set-Content -Encoding UTF8 -Path "src\app\admin\page.tsx" -Value @'
export default function Admin() {
  return (
    <main className="max-w-5xl mx-auto p-6">
      <h1 className="text-2xl font-bold mb-4">Admin Console</h1>
      <ul className="list-disc ml-6">
        <li>Accounts (view/search)</li>
        <li>Bookings/Quotes (searchable)</li>
        <li>Analytics dashboards</li>
        <li>Pricing Configuration (Draft -> Preview -> Publish -> Rollback)</li>
        <li>Audit log</li>
      </ul>
    </main>
  );
}
'@

# Booking placeholder
Set-Content -Encoding UTF8 -Path "src\app\booking\page.tsx" -Value @'
export default function Booking() {
  return (
    <main className="max-w-3xl mx-auto p-6">
      <h1 className="text-2xl font-bold mb-3">Booking</h1>
      <p>After login, this will prefill your last quote, let you confirm addresses, pick a wallet, and pay.</p>
    </main>
  );
}
'@

Write-Host "OK: Pages written."
