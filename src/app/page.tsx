"use client";

export default function Home() {
  return (
    <section className="min-h-screen flex flex-col items-center justify-center text-center bg-navy text-white px-6">
      <h1 className="text-5xl font-bold mb-4">JETSET DIRECT</h1>
      <p className="text-xl mb-8">Ground Service Elevated. The Reason We’re Taking Off.</p>
      <a
        href="/booking"
        className="bg-yellow-600 hover:bg-yellow-500 text-black font-semibold px-6 py-3 rounded-lg transition"
      >
        Book Your Ride
      </a>
    </section>
  );
}
