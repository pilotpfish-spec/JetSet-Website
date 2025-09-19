"use client";

import Link from "next/link";

export default function Header() {
  return (
    <header className="w-full bg-white shadow-md fixed top-0 left-0 z-50">
      <div className="max-w-7xl mx-auto px-6 py-4 flex items-center justify-between">
        {/* Logo */}
        <Link href="/" className="text-2xl font-bold text-navy-900">
          JETSET DIRECT
        </Link>

        {/* Nav Links */}
        <nav className="flex space-x-6 text-gray-700 font-medium">
          <Link href="/" className="hover:text-blue-600">Home</Link>
          <Link href="/about" className="hover:text-blue-600">About</Link>
          <Link href="/fleet" className="hover:text-blue-600">Fleet</Link>
          <Link href="/booking" className="hover:text-blue-600">Booking</Link>
          <Link href="/contact" className="hover:text-blue-600">Contact</Link>
          <Link href="/login" className="hover:text-blue-600">Login</Link>
          <Link href="/signup" className="hover:text-yellow-600 font-semibold">Sign Up</Link>
        </nav>
      </div>
    </header>
  );
}
