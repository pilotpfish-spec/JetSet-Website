"use client";
import { useEffect, useState } from "react";
import Link from "next/link";
import { ctaButton } from "@/styles/global.css.ts";

export default function Hero() {
  const [heroImage, setHeroImage] = useState<string>("");

  useEffect(() => {
    // Dynamically fetch all files in /public/hero
    async function loadImages() {
      try {
        const res = await fetch("/api/hero-images");
        const images: string[] = await res.json();
        if (images.length > 0) {
          setHeroImage(images[Math.floor(Math.random() * images.length)]);
        }
      } catch (err) {
        console.error("Hero image fetch failed", err);
      }
    }
    loadImages();
  }, []);

  return (
    <section
      style={{
        position: "relative",
        height: "100vh",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        textAlign: "center",
        color: "white",
        backgroundImage: heroImage ? `url(${heroImage})` : "none",
        backgroundSize: "cover",
        backgroundPosition: "center",
      }}
    >
      {/* Overlay */}
      <div
        style={{
          position: "absolute",
          inset: 0,
          backgroundColor: "rgba(0,0,0,0.6)",
          backdropFilter: "blur(6px)",
        }}
      ></div>

      {/* Content */}
      <div style={{ position: "relative", zIndex: 10, padding: "2rem" }}>
        <h1 style={{ fontSize: "3.5rem", fontWeight: 800, marginBottom: "1rem" }}>
          JETSET DIRECT
        </h1>
        <p
          style={{
            fontSize: "1.25rem",
            marginBottom: "1.5rem",
            fontStyle: "italic",
            color: "#e5e7eb",
          }}
        >
          Ground Service Elevated. The Reason We’re Taking Off.
        </p>
        <Link href="/booking" className={ctaButton}>
          Book Your Ride
        </Link>
      </div>
    </section>
  );
}
