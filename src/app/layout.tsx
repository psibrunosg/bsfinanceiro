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
  return <html lang="pt-BR"><body>{children}</body></html>;
}
