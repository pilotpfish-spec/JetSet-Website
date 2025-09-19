"use client";

import Image from 'next/image';
import { useEffect, useState } from "react";
import Link from "next/link";

const NAVY = "#0F1F39";
const GOLD = "#FBC02D";

export default function Hero() {
  const [bgUrl, setBgUrl] = useState<string | null>(null);

  useEffect(() => {
    let alive = true;
    fetch("/api/hero-images")
      .then(r => r.json())
      .then(({ images }) => {
        const pick = images?.length ? images[Math.floor(Math.random()*images.length)] : null;
        if (!pick) return;
        const img = new window.Image();
        img.onload = () => { if (alive) setBgUrl(pick); };
        img.onerror = () => { if (alive) setBgUrl(null); };
        img.src = pick;
      })
      .catch(() => setBgUrl(null));
    return () => { alive = false; };
  }, []);

  return (
    <section
      style={{ backgroundColor: NAVY, backgroundImage: bgUrl ? `url(${bgUrl})` : "none", backgroundSize: "cover", backgroundPosition: "center" }}
      className="relative h-[70vh] flex items-center justify-center text-white"
    >
      <div className="absolute inset-0 bg-black/40" />
      <div className="relative z-10 max-w-3xl mx-auto text-center px-6">
        <h1 className="text-3xl md:text-5xl font-bold mb-3">
          Ground Service Elevated. The Reason We&amp;apos;re Taking Off.
        </h1>
        <p className="text-base md:text-lg opacity-90">Predictable, insured airport transfers across Texas and neighbors.</p>
        <div className="mt-8 flex gap-4 justify-center">
          <Link href="#quote" className="px-6 py-3 rounded font-semibold" style={{ background: GOLD, color: "#0F1F39" }}>
            Get a Quote (Free)
          </Link>
          <Link href="/admin/login" className="px-6 py-3 rounded font-semibold border" style={{ borderColor: "white" }}>
            Log In / Sign Up
          </Link>
        </div>
      </div>
      <div className="absolute top-6 left-6">
        <Image src="/logo.png" alt="JetSet Direct" width={160} height={48} className="h-10 md:h-12 w-auto" />
      </div>
    </section>
  );
}
