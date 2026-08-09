import type { Metadata, Viewport } from "next";
import "./globals.css";
import "./app.css";
import { ThemeProvider } from "./components/ThemeProvider";
import { InstallPrompt } from "./components/InstallPrompt";
import { ToastProvider } from "./components/Toast";

export const metadata: Metadata = {
  title: "BS Financeiro",
  description: "Seu dinheiro explicado de forma simples.",
};
export const viewport: Viewport = { width: "device-width", initialScale: 1, themeColor: "#173b35" };

// Manifest, icones e service worker sao injetados em runtime porque o app e
// servido tanto na raiz quanto sob /bsfinanceiro (GitHub Pages), e o basePath
// nao pode ser fixado (mesma logica de src/lib/app-path.ts).
const pwaBootstrap = `(function(){var b=location.pathname.indexOf('/bsfinanceiro')===0?'/bsfinanceiro':'';
function l(rel,href,type){var e=document.querySelector('link[rel="'+rel+'"]');if(!e){e=document.createElement('link');e.rel=rel;document.head.appendChild(e)}if(type){e.type=type}e.href=href}
l('manifest',b+'/manifest.webmanifest');
l('icon',b+'/icon-192.png','image/png');
l('apple-touch-icon',b+'/icon-192.png');
if('serviceWorker' in navigator){window.addEventListener('load',function(){navigator.serviceWorker.register(b+'/sw.js',{scope:b+'/'}).catch(function(){})})}})();`;

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return <html lang="pt-BR" suppressHydrationWarning><head><script dangerouslySetInnerHTML={{ __html: "document.documentElement.dataset.theme=matchMedia('(prefers-color-scheme: dark)').matches?'dark':'light'" }} /><script dangerouslySetInnerHTML={{ __html: pwaBootstrap }} /></head><body><ThemeProvider><ToastProvider>{children}<InstallPrompt /></ToastProvider></ThemeProvider></body></html>;
}
