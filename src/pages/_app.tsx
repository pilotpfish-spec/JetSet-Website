import type { AppProps } from "next/app";
import "@/styles/global.css.ts";

export default function App({ Component, pageProps }: AppProps) {
  return <Component {...pageProps} />;
}

