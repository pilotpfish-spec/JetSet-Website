export default function NotFound() {
  return (
    <main style={{
      minHeight: "60vh",
      display: "grid",
      placeItems: "center",
      padding: "4rem 1rem",
      background: "#0b1b33",
      color: "#fff",
      textAlign: "center"
    }}>
      <div style={{ maxWidth: 640 }}>
        <h1 style={{ fontSize: "2rem", marginBottom: "0.75rem", letterSpacing: "0.3px" }}>
          Page not found
        </h1>
        <p style={{ opacity: 0.9, lineHeight: 1.6 }}>
          The page you’re looking for doesn’t exist. Head back to the homepage.
        </p>
        <a href="/" style={{
          marginTop: "1.25rem",
          display: "inline-block",
          padding: "0.75rem 1.25rem",
          borderRadius: "999px",
          background: "#fff",
          color: "#0b1b33",
          textDecoration: "none",
          fontWeight: 600
        }}>
          Go Home
        </a>
      </div>
    </main>
  );
}
