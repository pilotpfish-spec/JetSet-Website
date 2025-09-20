import Image from "next/image";
import Link from "next/link";
import "./globals.css";

export const metadata = {
  title: "JetSet Direct",
  description: "Ground Service Elevated. The Reason We’re Taking Off.",
};

// Randomly choose a hero from /public/hero folder
const heroImages = [
  "/hero/public-flex-exterior.jpg",
  "/hero/hero1.jpg",
  "/hero/hero2.png",
  "/hero/hero3.jpeg"
];
const randomHero = heroImages[Math.floor(Math.random() * heroImages.length)];

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className="bg-navy text-white min-h-screen flex flex-col">
        {/* Navbar */}
        <header className="flex items-center justify-between px-8 py-4 bg-navy shadow-lg">
          <div className="flex items-center space-x-4">
            <Image src="/logo.png" alt="JetSet Direct Logo" width={180} height={50} priority />
          </div>
          <nav>
            <ul className="flex space-x-8 text-lg font-medium">
              <li><Link href="/" className="hover:text-gold">Home</Link></li>
              <li><Link href="/about" className="hover:text-gold">About</Link></li>
              <li><Link href="/fleet" className="hover:text-gold">Fleet</Link></li>
              <li><Link href="/booking" className="hover:text-gold">Booking</Link></li>
              <li><Link href="/contact" className="hover:text-gold">Contact</Link></li>
              <li><Link href="/login" className="hover:text-gold">Login</Link></li>
            </ul>
          </nav>
        </header>

        {/* Hero */}
        <main className="flex-1">
          <section
            className="relative h-screen flex flex-col items-center justify-center text-center text-white"
            style={{
              backgroundImage: `url('${randomHero}')`,
              backgroundSize: "cover",
              backgroundPosition: "center",
            }}
          >
            <div className="hero-overlay p-10 rounded-2xl max-w-3xl mx-auto">
              <h1 className="text-6xl font-bold mb-6">JETSET DIRECT</h1>
              <p className="text-xl mb-8">Ground Service Elevated. The Reason We’re Taking Off.</p>
              <Link
                href="/booking"
                className="px-8 py-4 bg-gold text-navy font-semibold rounded-lg shadow-lg hover:bg-yellow-400 transition"
              >
                Book Your Ride
              </Link>
            </div>
          </section>
          {children}
        </main>

        {/* Footer */}
        <footer className="bg-navy py-6 text-center text-sm text-gray-400">
          © {new Date().getFullYear()} JetSet Direct. All Rights Reserved.
        </footer>
      </body>
    </html>
  );
}
