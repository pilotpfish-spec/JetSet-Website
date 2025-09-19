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
          900: "#0a1a33", // JetSet Direct navy
        },
        yellow: {
          600: "#facc15", // JetSet Direct yellow
        }
      }
    }
  },
  plugins: [],
};

export default config;
