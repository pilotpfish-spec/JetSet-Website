import Link from 'next/link';
export default function About() {
  return (
    <main className="max-w-3xl mx-auto p-6">
      <h1 className="text-2xl font-bold mb-3">About JetSet Direct</h1>
      <p className="mb-6">Predictable, professional, insured airport transfers - better than rideshare for time-critical trips.</p>
      <Link href="/#quote"><a className="px-4 py-2 rounded text-[#0F1F39]" style={{ background: "#FBC02D" }}>Get a Quote</a></Link>
    </main>
  );
}
