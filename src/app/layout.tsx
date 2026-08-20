import type { Metadata, Viewport } from "next";
import { Lexend, Source_Sans_3 } from "next/font/google";
import "./globals.css";
import "./auth.css";
import "./onboarding.css";
import "./management.css";
import "./transaction.css";
import "./card.css";
import "./dialog.css";
import "./components.css";
import "./reports.css";
import { MonthProvider } from "./components/MonthContext";

// next/font baixa e auto-hospeda as fontes no build estatico: sem request a
// terceiro em runtime e sem @import bloqueante. As variaveis alimentam
// --font-lexend / --font-sans usadas em globals.css.
const lexend = Lexend({ subsets: ["latin"], weight: ["400","500","600","700"], variable: "--font-lexend", display: "swap" });
const sourceSans = Source_Sans_3({ subsets: ["latin"], weight: ["400","600","700"], variable: "--font-sans", display: "swap" });

export const metadata: Metadata = {
  title: "BS Financeiro",
  description: "Seu dinheiro explicado de forma simples.",
  manifest: "/manifest.webmanifest",
  icons: {
    icon: "/icon-192.png",
    apple: "/icon-192.png",
  },
};
export const viewport: Viewport = { width: "device-width", initialScale: 1, themeColor: "#0B0E14" };

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return <html lang="pt-BR" data-theme="dark" className={`${lexend.variable} ${sourceSans.variable}`} suppressHydrationWarning><head><script dangerouslySetInnerHTML={{ __html: "document.documentElement.style.setProperty('--sidebar',localStorage.getItem('bsf-nav-collapsed')==='true'?'84px':'264px')" }} /><script dangerouslySetInnerHTML={{ __html: "if('serviceWorker' in navigator){window.addEventListener('load',()=>{navigator.serviceWorker.register('/sw.js').catch(()=>{})})}" }} /></head><body><MonthProvider>{children}</MonthProvider></body></html>;
}
