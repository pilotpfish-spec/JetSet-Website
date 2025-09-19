import "@/styles/global.css";
import Image from "next/image";
import Link from "next/link";
import Hero from "./Hero";
import { navLink, footerLink } from "@/styles/global.css";

export const metadata = {
  title: "JetSet Direct",
  description: "Ground Service Elevated. The Reason We’re Taking Off.",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        {/* Header */}
        <header style={{
          position: "fixed", top: 0, left: 0, width: "100%",
          display: "flex", justifyContent: "space-between", alignItems: "center",
          padding: "1rem 2rem", backgroundColor: "#0a192f",
          backdropFilter: "blur(8px)", boxShadow: "0 2px 6px rgba(0,0,0,0.4)", zIndex: 50
        }}>
          <div>
            <Image src="/logo.png" alt="JetSet Direct Logo"
              width={140} height={40} priority style={{ objectFit: "contain" }} />
          </div>
          <nav>
            <ul style={{ display: "flex", gap: "2rem" }}>
              <li><Link href="/" className={navLink}>Home</Link></li>
              <li><Link href="/about" className={navLink}>About</Link></li>
              <li><Link href="/fleet" className={navLink}>Fleet</Link></li>
              <li><Link href="/booking" className={navLink}>Booking</Link></li>
              <li><Link href="/contact" className={navLink}>Contact</Link></li>
              <li><Link href="/login" className={navLink}>Login</Link></li>
            </ul>
          </nav>
        </header>

        {/* Main */}
        <main style={{ marginTop: "80px" }}>
          <Hero />
          <div style={{ maxWidth: "1200px", margin: "0 auto", padding: "3rem 1rem" }}>
            {children}
          </div>
        </main>

        {/* Footer */}
        <footer style={{
          backgroundColor: "#0a192f", backdropFilter: "blur(6px)",
          borderTop: "1px solid #374151", padding: "2rem 1rem", marginTop: "2rem"
        }}>
          <div style={{
            maxWidth: "1200px", margin: "0 auto",
            display: "flex", flexDirection: "column", gap: "1.5rem", alignItems: "center"
          }}>
            <Image src="/logo.png" alt="JetSet Direct Logo" width={140} height={35} />
            <nav>
              <ul style={{ display: "flex", gap: "1.5rem" }}>
                <li><Link href="/" className={footerLink}>Home</Link></li>
                <li><Link href="/about" className={footerLink}>About</Link></li>
                <li><Link href="/fleet" className={footerLink}>Fleet</Link></li>
                <li><Link href="/booking" className={footerLink}>Booking</Link></li>
                <li><Link href="/contact" className={footerLink}>Contact</Link></li>
              </ul>
            </nav>
            <p style={{ fontSize: "0.8rem", color: "#9ca3af", fontStyle: "italic" }}>
              Ground Service Elevated. The Reason We’re Taking Off.
            </p>
          </div>
        </footer>
      </body>
    </html>
  );
}
