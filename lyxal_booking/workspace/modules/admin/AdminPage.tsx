/**
 * 🏛️ LYXAL WORKSPACE — Page Principale Administration (Module 11 : Admin System)
 */

import React, { useState } from 'react';
import { MetricsPanel } from './MetricsPanel';
import { UsersAdminPanel } from './UsersAdminPanel';
import { AuditLogsPanel } from './AuditLogsPanel';
import { SystemSettingsPanel } from './SystemSettingsPanel';

export const AdminPage: React.FC = () => {
  const [activeTab, setActiveTab] = useState<'metrics' | 'users' | 'audit' | 'settings'>('metrics');
  const [isSuperAdminView, setIsSuperAdminView] = useState<boolean>(false);

  return (
    <div className="space-y-6">
      {/* Header Admin */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 border-b border-slate-800 pb-4">
        <div>
          <div className="flex items-center gap-3">
            <span className="px-2.5 py-0.5 bg-indigo-950 border border-indigo-500/30 text-indigo-400 font-mono font-bold text-[10px] rounded-full uppercase">
              Module 11 — Admin System
            </span>
            {isSuperAdminView && (
              <span className="px-2.5 py-0.5 bg-rose-950 border border-rose-500/30 text-rose-400 font-mono font-bold text-[10px] rounded-full uppercase">
                SuperAdmin Mode
              </span>
            )}
          </div>
          <h2 className="text-2xl font-extrabold text-white tracking-tight mt-1">
            {isSuperAdminView ? 'Supervision globale Plateforme' : 'Administration de l\'Organisation'}
          </h2>
        </div>

        <div className="flex items-center gap-2">
          <button
            onClick={() => setIsSuperAdminView(!isSuperAdminView)}
            className={`px-3.5 py-1.5 font-bold text-xs rounded-lg transition border ${
              isSuperAdminView
                ? 'bg-rose-600 hover:bg-rose-500 text-white border-rose-500 shadow-sm'
                : 'bg-slate-800 hover:bg-slate-700 text-slate-300 border-slate-700'
            }`}
          >
            {isSuperAdminView ? 'Basculer en Vue Tenant' : 'Basculer en Vue SuperAdmin'}
          </button>
        </div>
      </div>

      {/* Barre d'Onglets Modulaire */}
      <div className="flex items-center gap-2 border-b border-slate-800 pb-2">
        <button
          onClick={() => setActiveTab('metrics')}
          className={`px-4 py-2 font-bold text-xs rounded-lg transition ${
            activeTab === 'metrics'
              ? 'bg-indigo-600 text-white shadow-sm'
              : 'bg-slate-900 text-slate-400 hover:text-white hover:bg-slate-800'
          }`}
        >
          Supervision & Métriques
        </button>
        <button
          onClick={() => setActiveTab('users')}
          className={`px-4 py-2 font-bold text-xs rounded-lg transition ${
            activeTab === 'users'
              ? 'bg-indigo-600 text-white shadow-sm'
              : 'bg-slate-900 text-slate-400 hover:text-white hover:bg-slate-800'
          }`}
        >
          Gestion Utilisateurs
        </button>
        <button
          onClick={() => setActiveTab('audit')}
          className={`px-4 py-2 font-bold text-xs rounded-lg transition ${
            activeTab === 'audit'
              ? 'bg-indigo-600 text-white shadow-sm'
              : 'bg-slate-900 text-slate-400 hover:text-white hover:bg-slate-800'
          }`}
        >
          Journaux d'Audit
        </button>
        <button
          onClick={() => setActiveTab('settings')}
          className={`px-4 py-2 font-bold text-xs rounded-lg transition ${
            activeTab === 'settings'
              ? 'bg-indigo-600 text-white shadow-sm'
              : 'bg-slate-900 text-slate-400 hover:text-white hover:bg-slate-800'
          }`}
        >
          Configuration
        </button>
      </div>

      {/* Contenu Panneau Actif */}
      <div className="pt-2">
        {activeTab === 'metrics' && <MetricsPanel isSuperAdmin={isSuperAdminView} />}
        {activeTab === 'users' && <UsersAdminPanel />}
        {activeTab === 'audit' && <AuditLogsPanel isSuperAdmin={isSuperAdminView} />}
        {activeTab === 'settings' && <SystemSettingsPanel isSuperAdmin={isSuperAdminView} />}
      </div>
    </div>
  );
};
