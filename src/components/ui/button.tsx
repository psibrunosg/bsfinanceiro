import React, { forwardRef } from "react";

export type ButtonVariant = "primary" | "secondary" | "glass" | "ghost" | "danger" | "outline";
export type ButtonSize = "sm" | "md" | "lg" | "pill" | "icon";

export interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: ButtonVariant;
  size?: ButtonSize;
  glow?: boolean;
  icon?: React.ReactNode;
  iconRight?: React.ReactNode;
}

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(function Button(
  {
    children,
    className = "",
    variant = "primary",
    size = "md",
    glow = false,
    icon,
    iconRight,
    type = "button",
    disabled,
    ...props
  },
  ref
) {
  const classes = [
    "ui-button",
    `ui-button--${variant}`,
    `ui-button--${size}`,
    glow ? "ui-button--glow" : "",
    className,
  ]
    .filter(Boolean)
    .join(" ");

  return (
    <button ref={ref} type={type} className={classes} disabled={disabled} {...props}>
      {icon && <span className="ui-button__icon">{icon}</span>}
      {children && <span className="ui-button__label">{children}</span>}
      {iconRight && <span className="ui-button__icon ui-button__icon--right">{iconRight}</span>}
    </button>
  );
});
