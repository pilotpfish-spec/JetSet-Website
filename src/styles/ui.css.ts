import { style } from "@vanilla-extract/css";
import { colors } from "./global.css.ts";

export const container = style({
  maxWidth: 1100,
  margin: "0 auto",
  padding: "24px 20px",
});

export const hero = style({
  borderRadius: 18,
  background: "linear-gradient(135deg,#0b1224,#0e1729 55%,#101a2e)",
  padding: "40px 28px",
  border: "1px solid rgba(255,255,255,0.06)",
  boxShadow: "0 10px 30px rgba(0,0,0,0.25)",
});

export const heroTitle = style({ fontSize: 34, fontWeight: 800, margin: 0, lineHeight: 1.15 });
export const heroSub = style({ marginTop: 10, color: "rgba(255,255,255,0.75)" });

export const heroActions = style({ display: "flex", gap: 12, marginTop: 22, flexWrap: "wrap" });

export const outlineButton = style({
  display: "inline-flex",
  alignItems: "center",
  justifyContent: "center",
  borderRadius: 12,
  padding: "10px 16px",
  fontWeight: 600,
  backgroundColor: "transparent",
  color: "#fff",
  border: "1px solid rgba(255,255,255,0.25)",
  cursor: "pointer",
  transition: "transform .06s ease, box-shadow .06s ease",
  selectors: {
    "&:hover": { transform: "translateY(-1px)" },
  },
});

export const features = style({
  display: "grid",
  gridTemplateColumns: "repeat(3, minmax(0,1fr))",
  gap: 16,
  marginTop: 20,
});
export const featureCard = style({
  borderRadius: 14,
  backgroundColor: "#0f172a",
  border: "1px solid rgba(255,255,255,0.06)",
  padding: 18,
});

export const steps = style({ display: "flex", gap: 8, flexWrap: "wrap" });
export const step = style({
  borderRadius: 999,
  backgroundColor: "rgba(255,255,255,0.1)",
  color: "#fff",
  padding: "6px 12px",
  fontSize: 13,
});
export const stepActive = style({
  borderRadius: 999,
  backgroundColor: "#fff",
  color: colors.text,
  padding: "6px 12px",
  fontSize: 13,
  fontWeight: 700,
});

export const twoCol = style({
  display: "grid",
  gridTemplateColumns: "1fr",
  gap: 18,
  "@media": { "(min-width: 880px)": { gridTemplateColumns: "1fr 1fr" } },
});

export const card = style({
  borderRadius: 14,
  backgroundColor: colors.surface,
  color: colors.text,
  border: "1px solid rgba(15,23,42,0.08)",
  padding: 16,
});

export const label = style({ fontSize: 13, fontWeight: 600, color: colors.muted });
export const input = style({
  marginTop: 6,
  width: "100%",
  borderRadius: 12,
  border: "1px solid rgba(15,23,42,0.15)",
  padding: "10px 12px",
  fontSize: 15,
});
export const select = input;
export const field = style({});

export const rowActions = style({ display: "flex", gap: 10, marginTop: 14, flexWrap: "wrap" });

export const bigTotal = style({ fontSize: 28, fontWeight: 800 });

