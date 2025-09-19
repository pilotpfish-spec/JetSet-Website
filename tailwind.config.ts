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
          900: "#0a1a33", // JetSet Direct navy background
        },
        yellow: {
          600: "#facc15", // highlight for buttons/hover
        }
      }
    }
  },
  plugins: [],
};

export default config;
