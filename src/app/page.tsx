"use client";

import Header from "@/components/Header";

export default function Home() {
  return (
    <div className="bg-navy-900 text-white min-h-screen flex flex-col">
      <Header />

      {/* Hero Section */}
      <section className="relative flex flex-col items-center justify-center flex-1 bg-[url('/hero/business.jpg')] bg-cover bg-center text-center px-4">
        <h1 className="text-4xl md:text-6xl font-bold mb-4 drop-shadow-lg">
          Ground Service Elevated. The Reason We’re Taking Off.
        </h1>
        <p className="text-lg md:text-xl mb-8 drop-shadow-md">
          Predictable, insured airport transfers across Texas and neighbors.
        </p>
        <a
          href="/booking"
          className="bg-yellow-600 text-navy-900 font-semibold px-6 py-3 rounded-lg shadow hover:bg-yellow-500"
        >
          Get a Free Quote
        </a>
      </section>

      {/* Quote Form Section */}
      <section className="bg-gray-100 text-navy-900 py-12 px-6">
        <div className="max-w-4xl mx-auto bg-white shadow-lg rounded-lg p-8">
          <h2 className="text-2xl font-bold mb-6">Book Your Ride</h2>
          <form className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium mb-1">To Airport</label>
              <select className="w-full border border-gray-300 rounded-md p-2">
                <option>DFW - Dallas/Fort Worth</option>
                <option>DAL - Love Field</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium mb-1">Date</label>
              <input type="date" className="w-full border border-gray-300 rounded-md p-2" />
            </div>
            <div className="md:col-span-2">
              <label className="block text-sm font-medium mb-1">Pickup Address</label>
              <input type="text" placeholder="Start typing..." className="w-full border border-gray-300 rounded-md p-2" />
            </div>
            <div>
              <label className="block text-sm font-medium mb-1">Passengers</label>
              <input type="number" min="1" defaultValue="1" className="w-full border border-gray-300 rounded-md p-2" />
            </div>
            <div>
              <label className="block text-sm font-medium mb-1">Bags</label>
              <input type="number" min="0" defaultValue="0" className="w-full border border-gray-300 rounded-md p-2" />
            </div>
            <div className="md:col-span-2 text-right">
              <button className="bg-yellow-600 text-navy-900 font-semibold px-6 py-3 rounded-lg shadow hover:bg-yellow-500">
                Get Instant Quote
              </button>
            </div>
          </form>
        </div>
      </section>
    </div>
  );
}
