"use client";

import React, { useState, useEffect } from "react";
import { User, Lock, X, Check, Loader2, LogOut, ShieldCheck, Briefcase, Calendar, Phone } from "lucide-react";
import { appPath } from "@/lib/app-path";
import { createClient } from "@/lib/supabase/client";

interface ProfileModalProps {
  isOpen: boolean;
  onClose: () => void;
  userEmail: string | null;
  onProfileUpdated?: (newName: string) => void;
}

export function ProfileModal({ isOpen, onClose, userEmail, onProfileUpdated }: ProfileModalProps) {
  const [activeTab, setActiveTab] = useState<"profile" | "password">("profile");

  // Profile Form States
  const [displayName, setDisplayName] = useState("");
  const [age, setAge] = useState<number | "">("");
  const [profession, setProfession] = useState("Psicólogo");
  const [phone, setPhone] = useState("");
  const [avatarColor, setAvatarColor] = useState("#8b5cf6");
  const [profileSaving, setProfileSaving] = useState(false);
  const [profileMsg, setProfileMsg] = useState<{ type: "success" | "error"; text: string } | null>(null);

  // Password Form States
  const [currentPassword, setCurrentPassword] = useState("");
  const [newPassword, setNewPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [passwordSaving, setPasswordSaving] = useState(false);
  const [passwordMsg, setPasswordMsg] = useState<{ type: "success" | "error"; text: string } | null>(null);

  useEffect(() => {
    if (isOpen) {
      setProfileMsg(null);
      setPasswordMsg(null);
      setCurrentPassword("");
      setNewPassword("");
      setConfirmPassword("");

      // Carregar dados locais ou da API
      const stored = typeof window !== "undefined" ? localStorage.getItem("bsfinanceiro_user") : null;
      let uid = "";
      if (stored) {
        try {
          const u = JSON.parse(stored);
          if (u.id) uid = u.id;
          if (u.display_name) setDisplayName(u.display_name);
        } catch {}
      }

      if (!uid && userEmail) {
        setDisplayName(userEmail.split("@")[0]);
      }

      if (uid) {
        fetch(`/api/profile?user_id=${encodeURIComponent(uid)}`)
          .then((res) => res.json())
          .then((data) => {
            if (data.profile) {
              if (data.profile.display_name) setDisplayName(data.profile.display_name);
              if (data.profile.age) setAge(data.profile.age);
              if (data.profile.profession) setProfession(data.profile.profession);
              if (data.profile.phone) setPhone(data.profile.phone);
              if (data.profile.avatar_color) setAvatarColor(data.profile.avatar_color);
            }
          })
          .catch(() => {});
      }
    }
  }, [isOpen, userEmail]);

  if (!isOpen) return null;

  async function handleSaveProfile(e: React.FormEvent) {
    e.preventDefault();
    setProfileSaving(true);
    setProfileMsg(null);

    const stored = typeof window !== "undefined" ? localStorage.getItem("bsfinanceiro_user") : null;
    let uid = "";
    if (stored) {
      try {
        const u = JSON.parse(stored);
        uid = u.id;
      } catch {}
    }

    try {
      const res = await fetch("/api/profile/update", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          user_id: uid,
          display_name: displayName,
          age: age === "" ? null : Number(age),
          profession,
          phone,
          avatar_color: avatarColor,
        }),
      });

      const data = await res.json();
      if (res.ok && data.success) {
        setProfileMsg({ type: "success", text: "Perfil atualizado com sucesso no banco de dados!" });
        if (stored) {
          try {
            const u = JSON.parse(stored);
            u.display_name = displayName;
            localStorage.setItem("bsfinanceiro_user", JSON.stringify(u));
          } catch {}
        }
        if (onProfileUpdated) onProfileUpdated(displayName);
      } else {
        setProfileMsg({ type: "error", text: data.error || "Não foi possível salvar as alterações." });
      }
    } catch {
      // Offline / Local save
      if (stored) {
        try {
          const u = JSON.parse(stored);
          u.display_name = displayName;
          localStorage.setItem("bsfinanceiro_user", JSON.stringify(u));
        } catch {}
      }
      setProfileMsg({ type: "success", text: "Perfil salvo localmente com sucesso." });
      if (onProfileUpdated) onProfileUpdated(displayName);
    } finally {
      setProfileSaving(false);
    }
  }

  async function handleChangePassword(e: React.FormEvent) {
    e.preventDefault();
    setPasswordMsg(null);

    if (newPassword !== confirmPassword) {
      setPasswordMsg({ type: "error", text: "A nova senha e a confirmação não coincidem." });
      return;
    }

    if (newPassword.length < 6) {
      setPasswordMsg({ type: "error", text: "A nova senha deve ter no mínimo 6 caracteres." });
      return;
    }

    setPasswordSaving(true);

    const stored = typeof window !== "undefined" ? localStorage.getItem("bsfinanceiro_user") : null;
    let uid = "";
    if (stored) {
      try {
        const u = JSON.parse(stored);
        uid = u.id;
      } catch {}
    }

    try {
      const res = await fetch("/api/auth/change-password", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          user_id: uid,
          current_password: currentPassword,
          new_password: newPassword,
        }),
      });

      const data = await res.json();
      if (res.ok && data.success) {
        setPasswordMsg({ type: "success", text: "Senha alterada com sucesso no PostgreSQL da VPS!" });
        setCurrentPassword("");
        setNewPassword("");
        setConfirmPassword("");
      } else {
        setPasswordMsg({ type: "error", text: data.error || "Falha ao alterar senha." });
      }
    } catch {
      setPasswordMsg({ type: "error", text: "Erro de conexão ao alterar a senha." });
    } finally {
      setPasswordSaving(false);
    }
  }

  async function handleSignOut() {
    try {
      await createClient().auth.signOut();
    } catch {}
    if (typeof window !== "undefined") {
      localStorage.removeItem("bsfinanceiro_user");
      localStorage.removeItem("bsfinanceiro_workspace");
      localStorage.removeItem("bsfinanceiro_token");
    }
    window.location.replace(appPath("/entrar"));
  }

  return (
    <div
      role="dialog"
      aria-modal="true"
      aria-labelledby="profile-modal-title"
      style={{
        position: "fixed",
        inset: 0,
        backgroundColor: "rgba(0, 0, 0, 0.75)",
        backdropFilter: "blur(6px)",
        WebkitBackdropFilter: "blur(6px)",
        zIndex: 99999,
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        padding: "1rem",
      }}
      onClick={(e) => {
        if (e.target === e.currentTarget) onClose();
      }}
    >
      <div
        className="dashboard-card"
        style={{
          width: "100%",
          maxWidth: "480px",
          maxHeight: "90vh",
          display: "flex",
          flexDirection: "column",
          background: "var(--surface, #11151F)",
          border: "1px solid var(--border, rgba(255, 255, 255, 0.12))",
          borderRadius: "20px",
          padding: 0,
          overflow: "hidden",
          boxShadow: "0 24px 48px rgba(0, 0, 0, 0.6)",
          color: "var(--text, #F8FAFC)",
        }}
      >
        {/* Header */}
        <div
          style={{
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
            padding: "1.25rem 1.5rem",
            borderBottom: "1px solid var(--border, rgba(255, 255, 255, 0.08))",
            background: "rgba(255, 255, 255, 0.02)",
          }}
        >
          <div style={{ display: "flex", alignItems: "center", gap: "12px" }}>
            <div
              style={{
                width: "46px",
                height: "46px",
                borderRadius: "50%",
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                color: "#fff",
                fontWeight: 700,
                fontSize: "1.2rem",
                backgroundColor: avatarColor,
                border: "2px solid rgba(255, 255, 255, 0.2)",
                flexShrink: 0,
                boxShadow: "0 4px 12px rgba(0, 0, 0, 0.3)",
              }}
            >
              {(displayName || userEmail || "B").charAt(0).toUpperCase()}
            </div>
            <div>
              <h2
                id="profile-modal-title"
                style={{ fontSize: "1.1rem", margin: 0, fontWeight: 700, color: "var(--text, #F8FAFC)" }}
              >
                {displayName || "Minha Conta"}
              </h2>
              <span className="muted" style={{ fontSize: "0.8rem", color: "var(--muted, #94A3B8)" }}>
                {userEmail || "brunosg2711@icloud.com"}
              </span>
            </div>
          </div>

          <button
            type="button"
            onClick={onClose}
            aria-label="Fechar"
            style={{
              background: "rgba(255, 255, 255, 0.05)",
              border: "1px solid var(--border, rgba(255, 255, 255, 0.1))",
              color: "var(--muted, #94A3B8)",
              width: "36px",
              height: "36px",
              borderRadius: "50%",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              cursor: "pointer",
            }}
          >
            <X size={18} />
          </button>
        </div>

        {/* Tabs */}
        <div
          style={{
            display: "flex",
            gap: "1.5rem",
            padding: "0 1.5rem",
            borderBottom: "1px solid var(--border, rgba(255, 255, 255, 0.08))",
            background: "rgba(0, 0, 0, 0.2)",
          }}
        >
          <button
            type="button"
            onClick={() => setActiveTab("profile")}
            style={{
              padding: "12px 0",
              border: "none",
              borderBottom: activeTab === "profile" ? "2px solid #8B5CF6" : "2px solid transparent",
              background: "transparent",
              color: activeTab === "profile" ? "#A78BFA" : "var(--muted, #94A3B8)",
              fontWeight: 600,
              fontSize: "0.85rem",
              display: "flex",
              alignItems: "center",
              gap: "8px",
              cursor: "pointer",
              transition: "all 0.2s",
            }}
          >
            <User size={15} />
            Personalizar Perfil
          </button>
          <button
            type="button"
            onClick={() => setActiveTab("password")}
            style={{
              padding: "12px 0",
              border: "none",
              borderBottom: activeTab === "password" ? "2px solid #8B5CF6" : "2px solid transparent",
              background: "transparent",
              color: activeTab === "password" ? "#A78BFA" : "var(--muted, #94A3B8)",
              fontWeight: 600,
              fontSize: "0.85rem",
              display: "flex",
              alignItems: "center",
              gap: "8px",
              cursor: "pointer",
              transition: "all 0.2s",
            }}
          >
            <Lock size={15} />
            Alterar Senha
          </button>
        </div>

        {/* Content */}
        <div style={{ padding: "1.5rem", overflowY: "auto", maxHeight: "65vh" }}>
          {activeTab === "profile" ? (
            <form onSubmit={handleSaveProfile} style={{ display: "flex", flexDirection: "column", gap: "1rem" }} autoComplete="off">
              {profileMsg && (
                <div
                  role={profileMsg.type === "error" ? "alert" : "status"}
                  style={{
                    padding: "10px 14px",
                    borderRadius: "10px",
                    fontSize: "0.85rem",
                    display: "flex",
                    alignItems: "center",
                    gap: "8px",
                    background: profileMsg.type === "success" ? "rgba(34, 197, 94, 0.15)" : "rgba(239, 68, 68, 0.15)",
                    border: profileMsg.type === "success" ? "1px solid rgba(34, 197, 94, 0.3)" : "1px solid rgba(239, 68, 68, 0.3)",
                    color: profileMsg.type === "success" ? "#22C55E" : "#EF4444",
                    fontWeight: 600,
                  }}
                >
                  <Check size={16} />
                  {profileMsg.text}
                </div>
              )}

              <div>
                <label style={{ display: "block", fontSize: "0.75rem", fontWeight: 600, textTransform: "uppercase", letterSpacing: "0.05em", color: "var(--muted, #94A3B8)", marginBottom: "6px" }}>
                  Nome Completo / Exibição
                </label>
                <div style={{ position: "relative", display: "flex", alignItems: "center" }}>
                  <span style={{ position: "absolute", left: "12px", color: "var(--muted, #94A3B8)", display: "flex", alignItems: "center" }}>
                    <User size={16} />
                  </span>
                  <input
                    type="text"
                    value={displayName}
                    onChange={(e) => setDisplayName(e.target.value)}
                    placeholder="Seu nome"
                    autoComplete="off"
                    data-lpignore="true"
                    style={{
                      width: "100%",
                      padding: "10px 14px 10px 38px",
                      borderRadius: "12px",
                      background: "var(--surface-2, rgba(255, 255, 255, 0.05))",
                      border: "1px solid var(--border, rgba(255, 255, 255, 0.12))",
                      color: "var(--text, #F8FAFC)",
                      fontSize: "0.9rem",
                      outline: "none",
                    }}
                  />
                </div>
              </div>

              <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "12px" }}>
                <div>
                  <label style={{ display: "block", fontSize: "0.75rem", fontWeight: 600, textTransform: "uppercase", letterSpacing: "0.05em", color: "var(--muted, #94A3B8)", marginBottom: "6px" }}>
                    Idade / Anos
                  </label>
                  <div style={{ position: "relative", display: "flex", alignItems: "center" }}>
                    <span style={{ position: "absolute", left: "12px", color: "var(--muted, #94A3B8)", display: "flex", alignItems: "center" }}>
                      <Calendar size={16} />
                    </span>
                    <input
                      type="number"
                      value={age}
                      onChange={(e) => setAge(e.target.value ? Number(e.target.value) : "")}
                      placeholder="Ex: 32"
                      min={1}
                      max={120}
                      autoComplete="off"
                      data-lpignore="true"
                      style={{
                        width: "100%",
                        padding: "10px 14px 10px 38px",
                        borderRadius: "12px",
                        background: "var(--surface-2, rgba(255, 255, 255, 0.05))",
                        border: "1px solid var(--border, rgba(255, 255, 255, 0.12))",
                        color: "var(--text, #F8FAFC)",
                        fontSize: "0.9rem",
                        outline: "none",
                      }}
                    />
                  </div>
                </div>

                <div>
                  <label style={{ display: "block", fontSize: "0.75rem", fontWeight: 600, textTransform: "uppercase", letterSpacing: "0.05em", color: "var(--muted, #94A3B8)", marginBottom: "6px" }}>
                    Profissão / Ocupação
                  </label>
                  <div style={{ position: "relative", display: "flex", alignItems: "center" }}>
                    <span style={{ position: "absolute", left: "12px", color: "var(--muted, #94A3B8)", display: "flex", alignItems: "center" }}>
                      <Briefcase size={16} />
                    </span>
                    <input
                      type="text"
                      value={profession}
                      onChange={(e) => setProfession(e.target.value)}
                      placeholder="Ex: Psicólogo"
                      autoComplete="off"
                      data-lpignore="true"
                      style={{
                        width: "100%",
                        padding: "10px 14px 10px 38px",
                        borderRadius: "12px",
                        background: "var(--surface-2, rgba(255, 255, 255, 0.05))",
                        border: "1px solid var(--border, rgba(255, 255, 255, 0.12))",
                        color: "var(--text, #F8FAFC)",
                        fontSize: "0.9rem",
                        outline: "none",
                      }}
                    />
                  </div>
                </div>
              </div>

              <div>
                <label style={{ display: "block", fontSize: "0.75rem", fontWeight: 600, textTransform: "uppercase", letterSpacing: "0.05em", color: "var(--muted, #94A3B8)", marginBottom: "6px" }}>
                  Telefone / WhatsApp
                </label>
                <div style={{ position: "relative", display: "flex", alignItems: "center" }}>
                  <span style={{ position: "absolute", left: "12px", color: "var(--muted, #94A3B8)", display: "flex", alignItems: "center" }}>
                    <Phone size={16} />
                  </span>
                  <input
                    type="tel"
                    value={phone}
                    onChange={(e) => setPhone(e.target.value)}
                    placeholder="(11) 99999-9999"
                    autoComplete="off"
                    data-lpignore="true"
                    style={{
                      width: "100%",
                      padding: "10px 14px 10px 38px",
                      borderRadius: "12px",
                      background: "var(--surface-2, rgba(255, 255, 255, 0.05))",
                      border: "1px solid var(--border, rgba(255, 255, 255, 0.12))",
                      color: "var(--text, #F8FAFC)",
                      fontSize: "0.9rem",
                      outline: "none",
                    }}
                  />
                </div>
              </div>

              <div>
                <label style={{ display: "block", fontSize: "0.75rem", fontWeight: 600, textTransform: "uppercase", letterSpacing: "0.05em", color: "var(--muted, #94A3B8)", marginBottom: "8px" }}>
                  Cor do Avatar
                </label>
                <div style={{ display: "flex", alignItems: "center", gap: "10px" }}>
                  {["#8b5cf6", "#3b82f6", "#10b981", "#f59e0b", "#ef4444", "#ec4899", "#06b6d4"].map((color) => (
                    <button
                      key={color}
                      type="button"
                      onClick={() => setAvatarColor(color)}
                      style={{
                        width: "32px",
                        height: "32px",
                        borderRadius: "50%",
                        backgroundColor: color,
                        border: avatarColor === color ? "3px solid #fff" : "2px solid transparent",
                        boxShadow: avatarColor === color ? `0 0 0 2px ${color}` : "none",
                        cursor: "pointer",
                        transform: avatarColor === color ? "scale(1.15)" : "scale(1)",
                        transition: "transform 0.15s ease",
                      }}
                    />
                  ))}
                </div>
              </div>

              <div style={{ paddingTop: "0.5rem" }}>
                <button
                  type="submit"
                  disabled={profileSaving}
                  style={{
                    width: "100%",
                    padding: "12px",
                    borderRadius: "12px",
                    background: "var(--primary, #8B5CF6)",
                    color: "#fff",
                    border: "none",
                    fontWeight: 600,
                    fontSize: "0.9rem",
                    cursor: profileSaving ? "not-allowed" : "pointer",
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                    gap: "8px",
                    boxShadow: "0 4px 14px rgba(139, 92, 246, 0.35)",
                    transition: "all 0.2s ease",
                  }}
                >
                  {profileSaving ? <Loader2 size={16} className="animate-spin" /> : <Check size={16} />}
                  Salvar Personalização
                </button>
              </div>
            </form>
          ) : (
            <form onSubmit={handleChangePassword} style={{ display: "flex", flexDirection: "column", gap: "1rem" }} autoComplete="off">
              {passwordMsg && (
                <div
                  role={passwordMsg.type === "error" ? "alert" : "status"}
                  style={{
                    padding: "10px 14px",
                    borderRadius: "10px",
                    fontSize: "0.85rem",
                    display: "flex",
                    alignItems: "center",
                    gap: "8px",
                    background: passwordMsg.type === "success" ? "rgba(34, 197, 94, 0.15)" : "rgba(239, 68, 68, 0.15)",
                    border: passwordMsg.type === "success" ? "1px solid rgba(34, 197, 94, 0.3)" : "1px solid rgba(239, 68, 68, 0.3)",
                    color: passwordMsg.type === "success" ? "#22C55E" : "#EF4444",
                    fontWeight: 600,
                  }}
                >
                  <ShieldCheck size={16} />
                  {passwordMsg.text}
                </div>
              )}

              <div>
                <label style={{ display: "block", fontSize: "0.75rem", fontWeight: 600, textTransform: "uppercase", letterSpacing: "0.05em", color: "var(--muted, #94A3B8)", marginBottom: "6px" }}>
                  Senha Atual
                </label>
                <div style={{ position: "relative", display: "flex", alignItems: "center" }}>
                  <span style={{ position: "absolute", left: "12px", color: "var(--muted, #94A3B8)", display: "flex", alignItems: "center" }}>
                    <Lock size={16} />
                  </span>
                  <input
                    type="password"
                    value={currentPassword}
                    onChange={(e) => setCurrentPassword(e.target.value)}
                    placeholder="Digite sua senha atual"
                    required
                    autoComplete="new-password"
                    data-lpignore="true"
                    style={{
                      width: "100%",
                      padding: "10px 14px 10px 38px",
                      borderRadius: "12px",
                      background: "var(--surface-2, rgba(255, 255, 255, 0.05))",
                      border: "1px solid var(--border, rgba(255, 255, 255, 0.12))",
                      color: "var(--text, #F8FAFC)",
                      fontSize: "0.9rem",
                      outline: "none",
                    }}
                  />
                </div>
              </div>

              <div>
                <label style={{ display: "block", fontSize: "0.75rem", fontWeight: 600, textTransform: "uppercase", letterSpacing: "0.05em", color: "var(--muted, #94A3B8)", marginBottom: "6px" }}>
                  Nova Senha (Mínimo 6 caracteres)
                </label>
                <div style={{ position: "relative", display: "flex", alignItems: "center" }}>
                  <span style={{ position: "absolute", left: "12px", color: "var(--muted, #94A3B8)", display: "flex", alignItems: "center" }}>
                    <Lock size={16} />
                  </span>
                  <input
                    type="password"
                    value={newPassword}
                    onChange={(e) => setNewPassword(e.target.value)}
                    placeholder="Digite a nova senha"
                    required
                    minLength={6}
                    autoComplete="new-password"
                    data-lpignore="true"
                    style={{
                      width: "100%",
                      padding: "10px 14px 10px 38px",
                      borderRadius: "12px",
                      background: "var(--surface-2, rgba(255, 255, 255, 0.05))",
                      border: "1px solid var(--border, rgba(255, 255, 255, 0.12))",
                      color: "var(--text, #F8FAFC)",
                      fontSize: "0.9rem",
                      outline: "none",
                    }}
                  />
                </div>
              </div>

              <div>
                <label style={{ display: "block", fontSize: "0.75rem", fontWeight: 600, textTransform: "uppercase", letterSpacing: "0.05em", color: "var(--muted, #94A3B8)", marginBottom: "6px" }}>
                  Confirmar Nova Senha
                </label>
                <div style={{ position: "relative", display: "flex", alignItems: "center" }}>
                  <span style={{ position: "absolute", left: "12px", color: "var(--muted, #94A3B8)", display: "flex", alignItems: "center" }}>
                    <Lock size={16} />
                  </span>
                  <input
                    type="password"
                    value={confirmPassword}
                    onChange={(e) => setConfirmPassword(e.target.value)}
                    placeholder="Repita a nova senha"
                    required
                    minLength={6}
                    autoComplete="new-password"
                    data-lpignore="true"
                    style={{
                      width: "100%",
                      padding: "10px 14px 10px 38px",
                      borderRadius: "12px",
                      background: "var(--surface-2, rgba(255, 255, 255, 0.05))",
                      border: "1px solid var(--border, rgba(255, 255, 255, 0.12))",
                      color: "var(--text, #F8FAFC)",
                      fontSize: "0.9rem",
                      outline: "none",
                    }}
                  />
                </div>
              </div>

              <div style={{ paddingTop: "0.5rem" }}>
                <button
                  type="submit"
                  disabled={passwordSaving}
                  style={{
                    width: "100%",
                    padding: "12px",
                    borderRadius: "12px",
                    background: "linear-gradient(135deg, #6366F1 0%, #4F46E5 100%)",
                    color: "#fff",
                    border: "none",
                    fontWeight: 600,
                    fontSize: "0.9rem",
                    cursor: passwordSaving ? "not-allowed" : "pointer",
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                    gap: "8px",
                    boxShadow: "0 4px 14px rgba(99, 102, 241, 0.35)",
                    transition: "all 0.2s ease",
                  }}
                >
                  {passwordSaving ? <Loader2 size={16} className="animate-spin" /> : <ShieldCheck size={16} />}
                  Atualizar Senha
                </button>
              </div>
            </form>
          )}
        </div>

        {/* Footer with Logout */}
        <div
          style={{
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
            padding: "1rem 1.5rem",
            borderTop: "1px solid var(--border, rgba(255, 255, 255, 0.08))",
            background: "rgba(0, 0, 0, 0.25)",
          }}
        >
          <button
            type="button"
            onClick={handleSignOut}
            style={{
              background: "rgba(239, 68, 68, 0.1)",
              border: "1px solid rgba(239, 68, 68, 0.25)",
              color: "#EF4444",
              padding: "8px 12px",
              borderRadius: "8px",
              fontSize: "0.8rem",
              fontWeight: 600,
              display: "flex",
              alignItems: "center",
              gap: "6px",
              cursor: "pointer",
            }}
          >
            <LogOut size={14} />
            Sair da Conta (Logout)
          </button>
          <button
            type="button"
            onClick={onClose}
            style={{
              background: "var(--surface-2, rgba(255, 255, 255, 0.05))",
              border: "1px solid var(--border, rgba(255, 255, 255, 0.12))",
              color: "var(--text, #F8FAFC)",
              padding: "8px 16px",
              borderRadius: "8px",
              fontSize: "0.85rem",
              fontWeight: 600,
              cursor: "pointer",
            }}
          >
            Fechar
          </button>
        </div>
      </div>
    </div>
  );
}
