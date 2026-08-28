"use client";

import React, { useState } from "react";
import { useCurrentUser } from "./useCurrentUser";
import { ProfileModal } from "./ProfileModal";

/** Avatar do usuário no cabeçalho — clique abre modal de personalização e configurações de conta. */
export function UserMenu() {
  const { email, displayName, initials } = useCurrentUser();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [customName, setCustomName] = useState<string | null>(null);

  const activeName = customName || displayName;
  const activeInitials = activeName ? activeName.charAt(0).toUpperCase() : initials;

  return (
    <>
      <button
        type="button"
        className="user-menu cursor-pointer hover:opacity-90 transition-opacity"
        onClick={() => setIsModalOpen(true)}
        title="Personalizar conta e alterar senha"
      >
        <span className="user-menu__text">
          <strong>{activeName}</strong>
          <small>Perfil Pessoal</small>
        </span>
        <span className="user-menu__avatar" aria-hidden="true">
          {activeInitials}
        </span>
      </button>

      <ProfileModal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        userEmail={email}
        onProfileUpdated={(newName) => setCustomName(newName)}
      />
    </>
  );
}
