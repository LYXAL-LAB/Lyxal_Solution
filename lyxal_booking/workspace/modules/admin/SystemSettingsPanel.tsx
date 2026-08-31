/**
 * 🏛️ LYXAL WORKSPACE — Panneau de Configuration Système / Tenant
 */

import React, { useEffect, useState } from 'react';
import { tenantAdminClient } from '../../sdk/admin/tenant_admin.client';
import { platformAdminClient } from '../../sdk/admin/platform_admin.client';
import { useToast } from '../../components/Toast';

interface SystemSettingsPanelProps {
  isSuperAdmin?: boolean;
}

export const SystemSettingsPanel: React.FC<SystemSettingsPanelProps> = ({ isSuperAdmin = false }) => {
  const { addToast } = useToast();
  const [brandingName, setBrandingName] = useState<string>('Lyxal OS');
  const [defaultTz, setDefaultTz] = useState<string>('UTC');
  const [allowPublic, setAllowPublic] = useState<boolean>(true);

  const [maintenanceMode, setMaintenanceMode] = useState<boolean>(false);
  const [maxUsers, setMaxUsers] = useState<number>(100);
  const [saving, setSaving] = useState<boolean>(false);
  const [loading, setLoading] = useState<boolean>(true);

  const loadSettings = async () => {
    setLoading(true);
    try {
      if (isSuperAdmin) {
        const res = await platformAdminClient.getSettings();
        setMaintenanceMode(res.maintenance_mode);
        setMaxUsers(res.max_users_per_tenant);
      } else {
        const res = await tenantAdminClient.getSettings();
        setBrandingName(res.branding_name);
        setDefaultTz(res.default_timezone);
        setAllowPublic(res.allow_public_bookings);
      }
    } catch (err: unknown) {
      addToast('error', 'Erreur Configuration', 'Échec du chargement des paramètres système.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadSettings();
  }, [isSuperAdmin]);

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);
    try {
      if (isSuperAdmin) {
        await platformAdminClient.updateSettings({
          maintenance_mode: maintenanceMode,
          max_users_per_tenant: maxUsers,
        });
        addToast('success', 'Paramètres Globaux Mis à Jour', 'La configuration de la plateforme a été enregistrée.');
      } else {
        await tenantAdminClient.updateSettings({
          branding_name: brandingName,
          default_timezone: defaultTz,
          allow_public_bookings: allowPublic,
        });
        addToast('success', 'Paramètres Tenant Mis à Jour', 'La configuration de l\'organisation a été enregistrée.');
      }
    } catch (err: unknown) {
      addToast('error', 'Échec Sauvegarde', 'Impossible d\'enregistrer les modifications.');
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <div className="p-8 text-center text-slate-400 text-xs">
        <div className="w-5 h-5 border-2 border-indigo-500 border-t-transparent rounded-full animate-spin mx-auto mb-2"></div>
        Chargement des configurations...
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="border-b border-slate-800 pb-4">
        <h3 className="text-lg font-bold text-white">
          {isSuperAdmin ? 'Paramètres Globaux Plateforme (SuperAdmin)' : 'Configuration de l\'Organisation (Tenant)'}
        </h3>
        <p className="text-xs text-slate-400 mt-1">
          Personnalisez les politiques et réglages système.
        </p>
      </div>

      <form onSubmit={handleSave} className="max-w-xl bg-slate-900 border border-slate-800 rounded-2xl p-6 space-y-4 shadow-xl">
        {!isSuperAdmin ? (
          <>
            <div>
              <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1">Nom de Marque / Organisation</label>
              <input
                type="text"
                value={brandingName}
                onChange={(e) => setBrandingName(e.target.value)}
                required
                className="w-full px-3.5 py-2 bg-slate-950 border border-slate-800 rounded-lg text-slate-100 text-sm focus:outline-none focus:border-indigo-500"
              />
            </div>

            <div>
              <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1">Fuseau Horaire par Défaut</label>
              <input
                type="text"
                value={defaultTz}
                onChange={(e) => setDefaultTz(e.target.value)}
                required
                className="w-full px-3.5 py-2 bg-slate-950 border border-slate-800 rounded-lg text-slate-100 text-sm font-mono focus:outline-none focus:border-indigo-500"
              />
            </div>

            <div className="flex items-center gap-3 pt-2">
              <input
                type="checkbox"
                id="allowPublic"
                checked={allowPublic}
                onChange={(e) => setAllowPublic(e.target.checked)}
                className="w-4 h-4 rounded border-slate-800 bg-slate-950 text-indigo-600 focus:ring-0"
              />
              <label htmlFor="allowPublic" className="text-xs font-semibold text-slate-300 cursor-pointer">
                Autoriser les réservations publiques invités
              </label>
            </div>
          </>
        ) : (
          <>
            <div className="flex items-center gap-3">
              <input
                type="checkbox"
                id="maintMode"
                checked={maintenanceMode}
                onChange={(e) => setMaintenanceMode(e.target.checked)}
                className="w-4 h-4 rounded border-slate-800 bg-slate-950 text-indigo-600 focus:ring-0"
              />
              <label htmlFor="maintMode" className="text-xs font-bold text-amber-400 cursor-pointer uppercase">
                Activer le mode Maintenance Globale
              </label>
            </div>

            <div>
              <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1">Nombre Max Utilisateurs par Tenant</label>
              <input
                type="number"
                value={maxUsers}
                onChange={(e) => setMaxUsers(Number(e.target.value))}
                required
                className="w-full px-3.5 py-2 bg-slate-950 border border-slate-800 rounded-lg text-slate-100 text-sm font-mono focus:outline-none focus:border-indigo-500"
              />
            </div>
          </>
        )}

        <button
          type="submit"
          disabled={saving}
          className="w-full py-2.5 bg-indigo-600 hover:bg-indigo-500 text-white font-bold text-sm rounded-lg shadow-sm transition disabled:opacity-50 mt-4"
        >
          {saving ? 'Enregistrement en cours...' : 'Sauvegarder les Modifications (PATCH)'}
        </button>
      </form>
    </div>
  );
};
