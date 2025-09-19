import "./globals.css";
import Image from "next/image";
import Link from "next/link";
import { useEffect, useState } from "react";

export const metadata = {
  title: "JetSet Direct",
  description: "Ground Service Elevated. The Reason We’re Taking Off.",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  const [heroImage, setHeroImage] = useState<string>("");

  useEffect(() => {
    // Pick random hero image from /public/hero/
    const images = [
      "/hero/public-flex-exterior.jpg",
      "/hero/hero1.jpg",
      "/hero/hero2.png",
      "/hero/hero3.jpeg",
    ];
    setHeroImage(images[Math.floor(Math.random() * images.length)]);
  }, []);

  return (
    <html lang="en">
      <body className="bg-navy text-white min-h-screen flex flex-col">
        {/* Navbar */}
        <header className="fixed top-0 left-0 w-full z-50 flex items-center justify-between px-8 py-4 bg-navy shadow">
          <div className="flex items-center">
            <Image src="/logo.png" alt="JetSet Direct Logo" width={160} height={40} priority />
          </div>
          <nav>
            <ul className="flex space-x-8">
              <li><Link href="/" className="nav-link">Home</Link></li>
              <li><Link href="/about" className="nav-link">About</Link></li>
              <li><Link href="/fleet" className="nav-link">Fleet</Link></li>
              <li><Link href="/booking" className="nav-link">Booking</Link></li>
              <li><Link href="/contact" className="nav-link">Contact</Link></li>
              <li><Link href="/login" className="nav-link">Login</Link></li>
            </ul>
          </nav>
        </header>

        {/* Hero */}
        <main className="flex-1 mt-[80px]">
          <section
            className="relative h-screen flex flex-col items-center justify-center text-center text-white"
            style={{
              backgroundImage: heroImage ? `url(${heroImage})` : "none",
              backgroundSize: "cover",
              backgroundPosition: "center",
            }}
          >
            {/* Overlay */}
            <div className="absolute inset-0 bg-black/60 backdrop-blur-sm"></div>

            {/* Hero Content */}
            <div className="relative z-10 px-8">
              <h1 className="text-6xl font-extrabold tracking-wide mb-4">JETSET DIRECT</h1>
              <p className="text-xl mb-6 italic text-gray-200">
                Ground Service Elevated. The Reason We’re Taking Off.
              </p>
              <Link
                href="/booking"
                className="cta-btn"
              >
                Book Your Ride
              </Link>
            </div>
          </section>
          {children}
        </main>
      </body>
    </html>
  );
}
