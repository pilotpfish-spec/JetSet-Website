import Link from "next/link";
import type { ReactNode } from "react";
import * as ui from "./ui.css";

export default function SiteShell({ children }: { children: ReactNode }) {
  return (
    <div style={{minHeight:"100%", display:"flex", flexDirection:"column"}}>
      <header className={ui.headerBar}>
        <div className={`${ui.container} ${ui.headerInner}`}>
          <Link href="/" className={ui.brand}>JETSET DIRECT</Link>
          <nav className={ui.navLinks}>
            <Link href="/booking">Book</Link>
            <Link href="/about">About</Link>
            <Link href="/testimonials">Testimonials</Link>
            <Link href="/reviews">Reviews</Link>
            <Link href="/contact">Contact</Link>
            <Link href="/login" className={ui.buttonPrimary} style={{textDecoration:"none"}}>Login</Link>
          </nav>
        </div>
      </header>

      <main className={ui.container} style={{paddingTop:24, paddingBottom:24, flex:1}}>
        {children}
      </main>

      <footer className={ui.footer}>
        <div className={ui.container} style={{padding:"12px 0"}}>© {new Date().getFullYear()} JetSet Direct</div>
      </footer>
    </div>
  );
}
