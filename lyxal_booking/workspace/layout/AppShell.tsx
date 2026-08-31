/**
 * 🏛️ LYXAL WORKSPACE — Layout AppShell Principal
 * Structure globale avec Sidebar, Header, Fil d'Ariane et Zone de Contenu.
 */

import React from 'react';
import { ToastProvider } from '../components/Toast';

export interface AppShellProps {
  activeModule: string;
  onNavigate: (moduleKey: string) => void;
  children: React.ReactNode;
}

export const AppShell: React.FC<AppShellProps> = ({ activeModule, onNavigate, children }) => {
  const modules = [
    { key: 'users', label: 'Profil & Paramètres', icon: '👤' },
    { key: 'calendars', label: 'Sources Calendriers', icon: '📅' },
    { key: 'resources', label: 'Ressources & Matériels', icon: '🏢' },
    { key: 'event-types', label: 'Types d\'Événements', icon: '⚡' },
    { key: 'availability', label: 'Disponibilités', icon: '🕒' },
    { key: 'teams', label: 'Équipes & Groupes', icon: '👥' },
    { key: 'bookings', label: 'Réservations', icon: '📋' },
    { key: 'public-booking', label: 'Réservation Publique', icon: '🌐' },
    { key: 'admin', label: 'Administration Système', icon: '🛡️' },
  ];

  return (
    <ToastProvider>
      <div className="flex h-screen w-full bg-slate-950 text-slate-100 font-sans overflow-hidden">
        {/* Sidebar */}
        <aside className="w-64 bg-slate-900 border-r border-slate-800 flex flex-col justify-between p-4">
          <div>
            <div className="flex items-center gap-3 px-2 py-4 border-b border-slate-800 mb-4">
              <div className="w-8 h-8 rounded-lg bg-gradient-to-tr from-violet-600 to-indigo-500 flex items-center justify-center text-white font-bold text-lg shadow-md shadow-indigo-500/20">
                L
              </div>
              <div>
                <h1 className="font-bold text-base leading-tight tracking-wide text-white">Lyxal OS</h1>
                <span className="text-[10px] text-slate-400 font-medium uppercase tracking-wider">Workspace Studio</span>
              </div>
            </div>

            <nav className="flex flex-col gap-1">
              {modules.map((m) => {
                const isActive = activeModule === m.key;
                return (
                  <button
                    key={m.key}
                    onClick={() => onNavigate(m.key)}
                    className={`flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-all ${
                      isActive
                        ? 'bg-indigo-600/20 text-indigo-400 border border-indigo-500/30 font-semibold shadow-sm'
                        : 'text-slate-400 hover:text-slate-200 hover:bg-slate-800/50'
                    }`}
                  >
                    <span>{m.icon}</span>
                    <span>{m.label}</span>
                  </button>
                );
              })}
            </nav>
          </div>

          <div className="p-3 bg-slate-950/60 border border-slate-800/80 rounded-lg flex items-center gap-3">
            <div className="w-8 h-8 rounded-full bg-indigo-900/60 border border-indigo-700/50 flex items-center justify-center text-xs font-bold text-indigo-200">
              AD
            </div>
            <div className="overflow-hidden">
              <p className="text-xs font-semibold text-slate-200 truncate">Hôte Authentifié</p>
              <p className="text-[10px] text-slate-400 truncate">user@lyxal-solution.com</p>
            </div>
          </div>
        </aside>

        {/* Main Content Area */}
        <div className="flex-1 flex flex-col min-w-0 overflow-hidden">
          {/* Header */}
          <header className="h-16 bg-slate-900/80 backdrop-blur border-b border-slate-800 px-6 flex items-center justify-between">
            <div className="flex items-center gap-2 text-sm text-slate-400">
              <span>Workspace</span>
              <span>/</span>
              <span className="font-semibold text-slate-200 capitalize">{activeModule.replace('-', ' ')}</span>
            </div>
            <div className="flex items-center gap-3">
              <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium bg-emerald-950/80 text-emerald-400 border border-emerald-500/30">
                <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse"></span>
                Backend V1 Connecté
              </span>
            </div>
          </header>

          {/* Body Content */}
          <main className="flex-1 overflow-y-auto p-6 bg-slate-950">
            <div className="max-w-6xl mx-auto">{children}</div>
          </main>
        </div>
      </div>
    </ToastProvider>
  );
};
