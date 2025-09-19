"use client";

import Link from "next/link";

export default function Header() {
  return (
    <header className="fixed top-0 left-0 w-full bg-navy-900 border-b border-yellow-600 z-50">
      <div className="max-w-7xl mx-auto px-6 flex items-center justify-between h-16">
        <h1 className="text-yellow-500 font-bold text-xl">JETSET DIRECT</h1>
        <nav className="space-x-6 text-sm font-medium">
          <Link href="/" className="hover:text-yellow-500">Home</Link>
          <Link href="/about" className="hover:text-yellow-500">About</Link>
          <Link href="/fleet" className="hover:text-yellow-500">Fleet</Link>
          <Link href="/booking" className="hover:text-yellow-500">Booking</Link>
          <Link href="/contact" className="hover:text-yellow-500">Contact</Link>
          <Link href="/login" className="hover:text-yellow-500">Login</Link>
        </nav>
      </div>
    </header>
  );
}
