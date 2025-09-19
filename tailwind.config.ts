import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        navy: {
          900: "#0a1a2f", // JetSet brand navy
        },
        yellow: {
          600: "#facc15", // JetSet yellow
          500: "#fde047",
        },
      },
    },
  },
  plugins: [],
};
export default config;
