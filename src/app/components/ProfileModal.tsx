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
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4 animate-in fade-in duration-200">
      <div className="bg-slate-900 border border-slate-800 rounded-2xl w-full max-w-lg shadow-2xl overflow-hidden text-slate-100 flex flex-col">
        {/* Header */}
        <div className="p-6 border-b border-slate-800/80 flex items-center justify-between bg-slate-950/40">
          <div className="flex items-center gap-3">
            <div
              className="w-12 h-12 rounded-full flex items-center justify-center text-white font-bold text-lg shadow-md border-2 border-white/20"
              style={{ backgroundColor: avatarColor }}
            >
              {(displayName || userEmail || "B").charAt(0).toUpperCase()}
            </div>
            <div>
              <h2 className="text-xl font-bold tracking-tight text-white">{displayName || "Minha Conta"}</h2>
              <p className="text-xs text-slate-400 font-medium">{userEmail || "brunosg2711@icloud.com"}</p>
            </div>
          </div>
          <button
            type="button"
            onClick={onClose}
            className="p-2 text-slate-400 hover:text-white rounded-xl hover:bg-slate-800 transition-colors"
          >
            <X size={20} />
          </button>
        </div>

        {/* Tabs */}
        <div className="flex border-b border-slate-800 bg-slate-950/20 px-6 pt-2 gap-6">
          <button
            type="button"
            onClick={() => setActiveTab("profile")}
            className={`pb-3 text-sm font-semibold flex items-center gap-2 border-b-2 transition-all ${
              activeTab === "profile"
                ? "border-purple-500 text-purple-400"
                : "border-transparent text-slate-400 hover:text-slate-200"
            }`}
          >
            <User size={16} />
            Personalizar Perfil
          </button>
          <button
            type="button"
            onClick={() => setActiveTab("password")}
            className={`pb-3 text-sm font-semibold flex items-center gap-2 border-b-2 transition-all ${
              activeTab === "password"
                ? "border-purple-500 text-purple-400"
                : "border-transparent text-slate-400 hover:text-slate-200"
            }`}
          >
            <Lock size={16} />
            Alterar Senha
          </button>
        </div>

        {/* Content */}
        <div className="p-6 overflow-y-auto max-h-[70vh]">
          {activeTab === "profile" ? (
            <form onSubmit={handleSaveProfile} className="space-y-4" autoComplete="off">
              {profileMsg && (
                <div
                  className={`p-3 rounded-xl text-sm flex items-center gap-2 ${
                    profileMsg.type === "success"
                      ? "bg-emerald-500/10 border border-emerald-500/30 text-emerald-300"
                      : "bg-rose-500/10 border border-rose-500/30 text-rose-300"
                  }`}
                >
                  <Check size={16} />
                  {profileMsg.text}
                </div>
              )}

              <div>
                <label className="block text-xs font-semibold uppercase tracking-wider text-slate-400 mb-1.5">
                  Nome Completo / Exibição
                </label>
                <div className="relative">
                  <User className="absolute left-3.5 top-3 text-slate-500" size={16} />
                  <input
                    type="text"
                    value={displayName}
                    onChange={(e) => setDisplayName(e.target.value)}
                    placeholder="Seu nome"
                    autoComplete="off"
                    data-lpignore="true"
                    className="w-full bg-slate-800/80 border border-slate-700 rounded-xl py-2.5 pl-10 pr-4 text-sm text-white placeholder-slate-500 focus:outline-none focus:border-purple-500 transition-colors"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-semibold uppercase tracking-wider text-slate-400 mb-1.5">
                    Idade / Anos
                  </label>
                  <div className="relative">
                    <Calendar className="absolute left-3.5 top-3 text-slate-500" size={16} />
                    <input
                      type="number"
                      value={age}
                      onChange={(e) => setAge(e.target.value ? Number(e.target.value) : "")}
                      placeholder="Ex: 32"
                      min={1}
                      max={120}
                      autoComplete="off"
                      data-lpignore="true"
                      className="w-full bg-slate-800/80 border border-slate-700 rounded-xl py-2.5 pl-10 pr-4 text-sm text-white placeholder-slate-500 focus:outline-none focus:border-purple-500 transition-colors"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-semibold uppercase tracking-wider text-slate-400 mb-1.5">
                    Profissão / Ocupação
                  </label>
                  <div className="relative">
                    <Briefcase className="absolute left-3.5 top-3 text-slate-500" size={16} />
                    <input
                      type="text"
                      value={profession}
                      onChange={(e) => setProfession(e.target.value)}
                      placeholder="Ex: Psicólogo"
                      autoComplete="off"
                      data-lpignore="true"
                      className="w-full bg-slate-800/80 border border-slate-700 rounded-xl py-2.5 pl-10 pr-4 text-sm text-white placeholder-slate-500 focus:outline-none focus:border-purple-500 transition-colors"
                    />
                  </div>
                </div>
              </div>

              <div>
                <label className="block text-xs font-semibold uppercase tracking-wider text-slate-400 mb-1.5">
                  Telefone / WhatsApp
                </label>
                <div className="relative">
                  <Phone className="absolute left-3.5 top-3 text-slate-500" size={16} />
                  <input
                    type="tel"
                    value={phone}
                    onChange={(e) => setPhone(e.target.value)}
                    placeholder="(11) 99999-9999"
                    autoComplete="off"
                    data-lpignore="true"
                    className="w-full bg-slate-800/80 border border-slate-700 rounded-xl py-2.5 pl-10 pr-4 text-sm text-white placeholder-slate-500 focus:outline-none focus:border-purple-500 transition-colors"
                  />
                </div>
              </div>

              <div>
                <label className="block text-xs font-semibold uppercase tracking-wider text-slate-400 mb-1.5">
                  Cor do Avatar
                </label>
                <div className="flex items-center gap-3">
                  {["#8b5cf6", "#3b82f6", "#10b981", "#f59e0b", "#ef4444", "#ec4899", "#06b6d4"].map((color) => (
                    <button
                      key={color}
                      type="button"
                      onClick={() => setAvatarColor(color)}
                      className={`w-8 h-8 rounded-full transition-transform ${
                        avatarColor === color ? "ring-2 ring-white ring-offset-2 ring-offset-slate-900 scale-110" : "hover:scale-105"
                      }`}
                      style={{ backgroundColor: color }}
                    />
                  ))}
                </div>
              </div>

              <div className="pt-3">
                <button
                  type="submit"
                  disabled={profileSaving}
                  className="w-full bg-purple-600 hover:bg-purple-500 text-white font-medium py-2.5 px-4 rounded-xl transition-colors flex items-center justify-center gap-2 shadow-lg shadow-purple-600/25"
                >
                  {profileSaving ? <Loader2 size={16} className="animate-spin" /> : <Check size={16} />}
                  Salvar Personalização
                </button>
              </div>
            </form>
          ) : (
            <form onSubmit={handleChangePassword} className="space-y-4" autoComplete="off">
              {passwordMsg && (
                <div
                  className={`p-3 rounded-xl text-sm flex items-center gap-2 ${
                    passwordMsg.type === "success"
                      ? "bg-emerald-500/10 border border-emerald-500/30 text-emerald-300"
                      : "bg-rose-500/10 border border-rose-500/30 text-rose-300"
                  }`}
                >
                  <ShieldCheck size={16} />
                  {passwordMsg.text}
                </div>
              )}

              <div>
                <label className="block text-xs font-semibold uppercase tracking-wider text-slate-400 mb-1.5">
                  Senha Atual
                </label>
                <div className="relative">
                  <Lock className="absolute left-3.5 top-3 text-slate-500" size={16} />
                  <input
                    type="password"
                    value={currentPassword}
                    onChange={(e) => setCurrentPassword(e.target.value)}
                    placeholder="Digite sua senha atual"
                    required
                    autoComplete="new-password"
                    data-lpignore="true"
                    className="w-full bg-slate-800/80 border border-slate-700 rounded-xl py-2.5 pl-10 pr-4 text-sm text-white placeholder-slate-500 focus:outline-none focus:border-purple-500 transition-colors"
                  />
                </div>
              </div>

              <div>
                <label className="block text-xs font-semibold uppercase tracking-wider text-slate-400 mb-1.5">
                  Nova Senha (Mínimo 6 caracteres)
                </label>
                <div className="relative">
                  <Lock className="absolute left-3.5 top-3 text-slate-500" size={16} />
                  <input
                    type="password"
                    value={newPassword}
                    onChange={(e) => setNewPassword(e.target.value)}
                    placeholder="Digite a nova senha"
                    required
                    minLength={6}
                    autoComplete="new-password"
                    data-lpignore="true"
                    className="w-full bg-slate-800/80 border border-slate-700 rounded-xl py-2.5 pl-10 pr-4 text-sm text-white placeholder-slate-500 focus:outline-none focus:border-purple-500 transition-colors"
                  />
                </div>
              </div>

              <div>
                <label className="block text-xs font-semibold uppercase tracking-wider text-slate-400 mb-1.5">
                  Confirmar Nova Senha
                </label>
                <div className="relative">
                  <Lock className="absolute left-3.5 top-3 text-slate-500" size={16} />
                  <input
                    type="password"
                    value={confirmPassword}
                    onChange={(e) => setConfirmPassword(e.target.value)}
                    placeholder="Repita a nova senha"
                    required
                    minLength={6}
                    autoComplete="new-password"
                    data-lpignore="true"
                    className="w-full bg-slate-800/80 border border-slate-700 rounded-xl py-2.5 pl-10 pr-4 text-sm text-white placeholder-slate-500 focus:outline-none focus:border-purple-500 transition-colors"
                  />
                </div>
              </div>

              <div className="pt-3">
                <button
                  type="submit"
                  disabled={passwordSaving}
                  className="w-full bg-indigo-600 hover:bg-indigo-500 text-white font-medium py-2.5 px-4 rounded-xl transition-colors flex items-center justify-center gap-2 shadow-lg shadow-indigo-600/25"
                >
                  {passwordSaving ? <Loader2 size={16} className="animate-spin" /> : <ShieldCheck size={16} />}
                  Atualizar Senha no Banco
                </button>
              </div>
            </form>
          )}
        </div>

        {/* Footer with Logout */}
        <div className="p-4 border-t border-slate-800 bg-slate-950/60 flex items-center justify-between">
          <button
            type="button"
            onClick={handleSignOut}
            className="text-rose-400 hover:text-rose-300 text-xs font-semibold flex items-center gap-1.5 px-3 py-2 rounded-lg hover:bg-rose-500/10 transition-colors"
          >
            <LogOut size={14} />
            Sair da Conta (Logout)
          </button>
          <button
            type="button"
            onClick={onClose}
            className="px-4 py-2 bg-slate-800 hover:bg-slate-700 text-slate-200 text-xs font-semibold rounded-lg transition-colors"
          >
            Fechar
          </button>
        </div>
      </div>
    </div>
  );
}
