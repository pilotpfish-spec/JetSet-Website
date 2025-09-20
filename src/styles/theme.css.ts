import { createGlobalTheme } from "@vanilla-extract/css";

export const vars = createGlobalTheme(":root", {
  color: {
    bg: "#f8fafc",
    surface: "#ffffff",
    text: "#0f172a",
    subtle: "#475569",
    link: "#2563eb",
    border: "#e2e8f0",
    brand: "#0f172a",
    primary: "#0f172a",
    primaryText: "#ffffff",
    danger: "#dc2626",
  },
  radius: { sm: "8px", md: "12px", xl: "16px" },
  space:  { 0:"0", 1:"4px", 2:"8px", 3:"12px", 4:"16px", 6:"24px", 8:"32px" },
  shadow: { card: "0 1px 2px rgba(0,0,0,.06), 0 6px 20px rgba(0,0,0,.06)" },
  font:   { body: 'ui-sans-serif, system-ui, -apple-system, "Segoe UI", Roboto, Helvetica, Arial, "Apple Color Emoji","Segoe UI Emoji"' }
});
