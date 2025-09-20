import { style } from "@vanilla-extract/css";
import { vars } from "../styles/theme.css.ts";

export const container = style({
  maxWidth: "960px",
  margin: "0 auto",
  padding: "0 16px",
});

export const headerBar = style({
  background: vars.color.surface,
  borderBottom: `1px solid ${vars.color.border}`,
});

export const headerInner = style({
  height: "56px",
  display: "flex",
  alignItems: "center",
  justifyContent: "space-between",
});

export const brand = style({
  fontWeight: 700,
  letterSpacing: ".02em",
});

export const navLinks = style({
  display: "flex",
  gap: "16px",
  fontSize: "14px",
});

export const footer = style({
  background: vars.color.surface,
  borderTop: `1px solid ${vars.color.border}`,
  color: vars.color.subtle,
});

export const card = style({
  background: vars.color.surface,
  border: `1px solid ${vars.color.border}`,
  borderRadius: vars.radius.xl,
  boxShadow: vars.shadow.card,
  padding: "16px",
});

export const input = style({
  width: "100%",
  padding: "10px 12px",
  borderRadius: vars.radius.md,
  border: `1px solid ${vars.color.border}`,
  background: "#fff",
  outline: "none",
});

export const select = input;

export const buttonPrimary = style({
  background: vars.color.primary,
  color: vars.color.primaryText,
  border: "none",
  borderRadius: vars.radius.md,
  padding: "10px 14px",
  cursor: "pointer",
});

export const buttonSecondary = style({
  background: vars.color.surface,
  color: vars.color.text,
  border: `1px solid ${vars.color.border}`,
  borderRadius: vars.radius.md,
  padding: "10px 14px",
  cursor: "pointer",
});

export const stepPillActive = style({
  background: vars.color.text,
  color: "#fff",
  borderRadius: "9999px",
  padding: "6px 10px",
  fontSize: "12px",
});
export const stepPill = style({
  background: "#e5e7eb",
  color: "#111827",
  borderRadius: "9999px",
  padding: "6px 10px",
  fontSize: "12px",
});

export const grid2 = style({
  display: "grid",
  gap: 16,
  gridTemplateColumns: "1fr",
  "@media": { "screen and (min-width: 900px)": { gridTemplateColumns: "1fr 1fr" } },
});
