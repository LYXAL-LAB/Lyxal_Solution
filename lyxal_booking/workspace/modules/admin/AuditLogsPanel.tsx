/**
 * 🏛️ LYXAL WORKSPACE — Panneau de Consultation des Journaux d'Audit
 */

import React, { useEffect, useState } from 'react';
import { tenantAdminClient } from '../../sdk/admin/tenant_admin.client';
import { platformAdminClient } from '../../sdk/admin/platform_admin.client';
import { TenantAuditLogEntry, PlatformAuditLogEntry } from '../../sdk/admin/admin.types';
import { useToast } from '../../components/Toast';

interface AuditLogsPanelProps {
  isSuperAdmin?: boolean;
}

export const AuditLogsPanel: React.FC<AuditLogsPanelProps> = ({ isSuperAdmin = false }) => {
  const { addToast } = useToast();
  const [tenantLogs, setTenantLogs] = useState<TenantAuditLogEntry[]>([]);
  const [platformLogs, setPlatformLogs] = useState<PlatformAuditLogEntry[]>([]);
  const [loading, setLoading] = useState<boolean>(true);

  const loadLogs = async () => {
    setLoading(true);
    try {
      if (isSuperAdmin) {
        const res = await platformAdminClient.getAuditLogs(50);
        setPlatformLogs(res.logs);
      } else {
        const res = await tenantAdminClient.getAuditLogs(50);
        setTenantLogs(res.logs);
      }
    } catch (err: unknown) {
      addToast('error', 'Erreur Audit Logs', 'Échec du chargement des journaux d\'audit.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadLogs();
  }, [isSuperAdmin]);

  if (loading) {
    return (
      <div className="p-8 text-center text-slate-400 text-xs">
        <div className="w-5 h-5 border-2 border-indigo-500 border-t-transparent rounded-full animate-spin mx-auto mb-2"></div>
        Chargement des journaux d'audit...
      </div>
    );
  }

  const logs = isSuperAdmin ? platformLogs : tenantLogs;

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between border-b border-slate-800 pb-4">
        <div>
          <h3 className="text-lg font-bold text-white">
            {isSuperAdmin ? 'Journaux d\'Audit Transversaux Plateforme' : 'Journaux d\'Audit du Tenant'}
          </h3>
          <p className="text-xs text-slate-400 mt-1">
            Historique d'exécution des mutations sensibles et événements système.
          </p>
        </div>
      </div>

      <div className="bg-slate-900 border border-slate-800 rounded-2xl overflow-hidden shadow-xl">
        <table className="w-full text-left text-xs">
          <thead className="bg-slate-950/80 border-b border-slate-800 text-slate-400 font-semibold uppercase tracking-wider">
            <tr>
              <th className="p-4">Horodatage</th>
              <th className="p-4">Acteur</th>
              <th className="p-4">Action</th>
              <th className="p-4 font-mono">Détails / Cible</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-800 text-slate-300 font-mono">
            {logs.length === 0 ? (
              <tr>
                <td colSpan={4} className="p-6 text-center text-slate-400 font-sans">
                  Aucun journal d'audit enregistré.
                </td>
              </tr>
            ) : (
              logs.map((log) => (
                <tr key={log.id} className="hover:bg-slate-950/40 transition">
                  <td className="p-4 text-slate-400">{new Date(log.created_at).toLocaleString()}</td>
                  <td className="p-4 font-bold text-indigo-400">{log.actor_id}</td>
                  <td className="p-4 font-bold text-emerald-400 uppercase">{log.action}</td>
                  <td className="p-4 text-slate-300">
                    {log.target_id ? `Target: ${log.target_id}` : ''} {log.new_role ? `(Role: ${log.new_role})` : ''}
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
};
