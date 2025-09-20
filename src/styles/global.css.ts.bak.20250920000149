import { style, globalStyle } from "@vanilla-extract/css";

// Brand colors
export const colors = {
  navy: "#0a192f",
  yellow: "#facc15",
  white: "#ffffff",
  gray: "#9ca3af",
};

// CTA Button
export const ctaButton = style({
  backgroundColor: colors.yellow,
  color: colors.navy,
  fontWeight: "bold",
  padding: "1rem 2rem",
  borderRadius: "0.5rem",
  boxShadow: "0 4px 6px rgba(0,0,0,0.2)",
  transition: "all 0.2s ease-in-out",
  selectors: {
    "&:hover": {
      backgroundColor: "#fde047",
      transform: "scale(1.05)",
    },
  },
});

// Nav Link
export const navLink = style({
  position: "relative",
  color: colors.white,
  fontWeight: "500",
  transition: "color 0.2s ease-in-out",
  selectors: {
    "&:hover": { color: colors.yellow },
  },
});

// Footer Link
export const footerLink = style({
  color: colors.gray,
  fontSize: "0.9rem",
  transition: "color 0.2s ease-in-out",
  selectors: {
    "&:hover": { color: colors.yellow },
  },
});

// Global base styles
globalStyle("body", {
  margin: 0,
  fontFamily: "system-ui, sans-serif",
  backgroundColor: colors.navy,
  color: colors.white,
});
