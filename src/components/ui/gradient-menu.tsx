"use client";

import React from "react";
import { Home, PlusCircle, Sparkles, Share2, Heart } from "lucide-react";

export interface GradientMenuItem {
  title: string;
  icon: React.ReactNode;
  gradientFrom: string;
  gradientTo: string;
  onClick?: () => void;
  href?: string;
  ariaLabel?: string;
}

const defaultItems: GradientMenuItem[] = [
  { title: "Início", icon: <Home size={22} />, gradientFrom: "#8B5CF6", gradientTo: "#EC4899" },
  { title: "Novo", icon: <PlusCircle size={22} />, gradientFrom: "#06B6D4", gradientTo: "#3B82F6" },
  { title: "Insights", icon: <Sparkles size={22} />, gradientFrom: "#F59E0B", gradientTo: "#EF4444" },
  { title: "Partilhar", icon: <Share2 size={22} />, gradientFrom: "#10B981", gradientTo: "#06B6D4" },
  { title: "Favoritos", icon: <Heart size={22} />, gradientFrom: "#F43F5E", gradientTo: "#A855F7" },
];

export interface GradientMenuProps {
  items?: GradientMenuItem[];
  className?: string;
}

export function GradientMenu({ items = defaultItems, className = "" }: GradientMenuProps) {
  return (
    <nav className={`gradient-menu-wrap ${className}`} aria-label="Menu de ações rápidas">
      <ul className="gradient-menu-list">
        {items.map(({ title, icon, gradientFrom, gradientTo, onClick, href, ariaLabel }, idx) => {
          const itemStyle = {
            "--gradient-from": gradientFrom,
            "--gradient-to": gradientTo,
          } as React.CSSProperties;

          const content = (
            <>
              {/* Fundo gradiente vibrante revelado no hover */}
              <span className="gradient-menu-pill__bg" aria-hidden="true" />
              {/* Brilho difuso atmosférico (ambient glow) */}
              <span className="gradient-menu-pill__glow" aria-hidden="true" />
              {/* Ícone */}
              <span className="gradient-menu-pill__icon" aria-hidden="true">
                {icon}
              </span>
              {/* Título expandido */}
              <span className="gradient-menu-pill__label">{title}</span>
            </>
          );

          return (
            <li key={idx} style={itemStyle} className="gradient-menu-pill">
              {href ? (
                <a
                  href={href}
                  className="gradient-menu-pill__inner"
                  onClick={onClick}
                  aria-label={ariaLabel || title}
                >
                  {content}
                </a>
              ) : (
                <button
                  type="button"
                  className="gradient-menu-pill__inner"
                  onClick={onClick}
                  aria-label={ariaLabel || title}
                >
                  {content}
                </button>
              )}
            </li>
          );
        })}
      </ul>
    </nav>
  );
}

export default GradientMenu;
