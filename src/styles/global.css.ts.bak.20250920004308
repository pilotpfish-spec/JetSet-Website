import { globalStyle, style } from "@vanilla-extract/css";

export const colors = {
  bg: "#0b0f1a",
  surface: "#ffffff",
  text: "#0f172a",
  muted: "#64748b",
  primary: "#111827",
  accent: "#2563eb",
  ring: "rgba(37,99,235,0.35)"
};

// Reset-ish + base
globalStyle("html,body,#__next", { height: "100%" });
globalStyle("body", {
  margin: 0,
  backgroundColor: colors.bg,
  color: colors.surface,
  fontFamily:
    '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, "Noto Sans", "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol", "Noto Color Emoji"',
});

globalStyle("a", { color: "inherit", textDecoration: "none" });
globalStyle("*", { boxSizing: "border-box" });

// Reusable CTA button
export const ctaButton = style({
  display: "inline-flex",
  alignItems: "center",
  justifyContent: "center",
  borderRadius: 12,
  padding: "10px 16px",
  fontWeight: 600,
  border: "1px solid transparent",
  backgroundColor: colors.accent,
  color: "#fff",
  cursor: "pointer",
  transition: "transform .06s ease, box-shadow .06s ease",
  selectors: {
    "&:hover": { transform: "translateY(-1px)" },
    "&:focus-visible": { outline: "none", boxShadow: `0 0 0 3px ${colors.ring}` },
    "&:disabled": { opacity: 0.6, cursor: "not-allowed" },
  },
});
