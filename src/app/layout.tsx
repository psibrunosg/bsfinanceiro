import type { Metadata, Viewport } from "next";
import "./globals.css";
import "./auth.css";
import "./onboarding.css";
import "./management.css";
import "./category.css";
import "./transaction.css";
import "./card.css";
import "./invoice.css";
import "./projection.css";
import "./planning.css";
import "./settings.css";
import "./dashboard-extra.css";
import "./dialog.css";
import "./compromissos/commitments.css";
import "./components.css";
import "./reports.css";
import "./dark-override.css";
import { ThemeProvider } from "./components/ThemeProvider";
import { MonthProvider } from "./components/MonthContext";

export const metadata: Metadata = {
  title: "BS Financeiro",
  description: "Seu dinheiro explicado de forma simples.",
  manifest: "/manifest.webmanifest",
  icons: {
    icon: "/icon-192.png",
    apple: "/icon-192.png",
  },
};
export const viewport: Viewport = { width: "device-width", initialScale: 1, themeColor: "#173b35" };

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return <html lang="pt-BR" suppressHydrationWarning><head><script dangerouslySetInnerHTML={{ __html: "document.documentElement.dataset.theme=matchMedia('(prefers-color-scheme: dark)').matches?'dark':'light'" }} /><script dangerouslySetInnerHTML={{ __html: "if('serviceWorker' in navigator){window.addEventListener('load',()=>{navigator.serviceWorker.register('/sw.js').catch(()=>{})})}" }} /></head><body><ThemeProvider><MonthProvider>{children}</MonthProvider></ThemeProvider></body></html>;
}
