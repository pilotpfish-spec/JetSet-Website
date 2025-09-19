"use client";
import { useEffect, useState } from "react";
import Link from "next/link";
import Image from "next/image";
import { ctaButton } from "@/styles/global.css";

export default function Hero() {
  const [heroImage, setHeroImage] = useState<string>("");

  useEffect(() => {
    const images = [
      "/hero/public-flex-exterior.jpg",
      "/hero/hero1.jpg",
      "/hero/hero2.png",
      "/hero/hero3.jpeg",
    ];
    setHeroImage(images[Math.floor(Math.random() * images.length)]);
  }, []);

  return (
    <section
      style={{
        position: "relative", height: "100vh", display: "flex",
        alignItems: "center", justifyContent: "center", textAlign: "center",
        backgroundImage: heroImage ? `url(${heroImage})` : "none",
        backgroundSize: "cover", backgroundPosition: "center"
      }}
    >
      <div style={{
        position: "absolute", inset: 0,
        backgroundColor: "rgba(0,0,0,0.6)", backdropFilter: "blur(6px)"
      }}></div>

      <div style={{ position: "relative", zIndex: 10, padding: "2rem" }}>
        <h1 style={{ marginBottom: "1rem" }}>
          <Image src="/logo.png" alt="JetSet Direct" width={200} height={80} priority />
        </h1>
        <p style={{ fontSize: "1.25rem", marginBottom: "1.5rem", fontStyle: "italic", color: "#e5e7eb" }}>
          Ground Service Elevated. The Reason We’re Taking Off.
        </p>
        <Link href="/booking" className={ctaButton}>
          Book Your Ride
        </Link>
      </div>
    </section>
  );
}

