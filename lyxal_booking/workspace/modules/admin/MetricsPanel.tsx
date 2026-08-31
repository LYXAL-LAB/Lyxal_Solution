/**
 * 🏛️ LYXAL WORKSPACE — Panneau de Métriques Supervision Admin
 */

import React, { useEffect, useState } from 'react';
import { tenantAdminClient } from '../../sdk/admin/tenant_admin.client';
import { platformAdminClient } from '../../sdk/admin/platform_admin.client';
import { TenantMetricsResponse, PlatformMetricsResponse } from '../../sdk/admin/admin.types';
import { useToast } from '../../components/Toast';

interface MetricsPanelProps {
  isSuperAdmin?: boolean;
}

export const MetricsPanel: React.FC<MetricsPanelProps> = ({ isSuperAdmin = false }) => {
  const { addToast } = useToast();
  const [tenantMetrics, setTenantMetrics] = useState<TenantMetricsResponse | null>(null);
  const [platformMetrics, setPlatformMetrics] = useState<PlatformMetricsResponse | null>(null);
  const [loading, setLoading] = useState<boolean>(true);

  const loadMetrics = async () => {
    setLoading(true);
    try {
      if (isSuperAdmin) {
        const res = await platformAdminClient.getMetrics();
        setPlatformMetrics(res);
      } else {
        const res = await tenantAdminClient.getMetrics();
        setTenantMetrics(res);
      }
    } catch (err: unknown) {
      addToast('error', 'Erreur Métriques', 'Échec du chargement des indicateurs de supervision.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadMetrics();
  }, [isSuperAdmin]);

  if (loading) {
    return (
      <div className="p-8 text-center text-slate-400 text-xs">
        <div className="w-5 h-5 border-2 border-indigo-500 border-t-transparent rounded-full animate-spin mx-auto mb-2"></div>
        Chargement des métriques de supervision...
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between border-b border-slate-800 pb-4">
        <div>
          <h3 className="text-lg font-bold text-white">
            {isSuperAdmin ? 'Supervision Globale Plateforme' : 'Métriques de Supervision Tenant'}
          </h3>
          <p className="text-xs text-slate-400 mt-1">
            Indicateurs d'activité et état de santé du système.
          </p>
        </div>
        <button
          onClick={loadMetrics}
          className="px-3 py-1.5 bg-slate-800 hover:bg-slate-700 text-slate-200 font-semibold text-xs rounded-lg transition"
        >
          Rafraîchir
        </button>
      </div>

      {isSuperAdmin && platformMetrics ? (
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <div className="p-4 bg-slate-900 border border-slate-800 rounded-xl space-y-1">
            <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Tenants Actifs</span>
            <p className="text-2xl font-extrabold text-indigo-400 font-mono">{platformMetrics.total_tenants}</p>
          </div>
          <div className="p-4 bg-slate-900 border border-slate-800 rounded-xl space-y-1">
            <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Total Utilisateurs</span>
            <p className="text-2xl font-extrabold text-slate-100 font-mono">{platformMetrics.total_users}</p>
          </div>
          <div className="p-4 bg-slate-900 border border-slate-800 rounded-xl space-y-1">
            <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Réservations Cumulées</span>
            <p className="text-2xl font-extrabold text-emerald-400 font-mono">{platformMetrics.total_bookings}</p>
          </div>
          <div className="p-4 bg-slate-900 border border-slate-800 rounded-xl space-y-1">
            <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">État Système</span>
            <p className="text-2xl font-extrabold text-emerald-400 font-mono">{platformMetrics.system_status}</p>
          </div>
        </div>
      ) : tenantMetrics ? (
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <div className="p-4 bg-slate-900 border border-slate-800 rounded-xl space-y-1">
            <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Membres Tenant</span>
            <p className="text-2xl font-extrabold text-slate-100 font-mono">{tenantMetrics.total_users}</p>
          </div>
          <div className="p-4 bg-slate-900 border border-slate-800 rounded-xl space-y-1">
            <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">En Attente</span>
            <p className="text-2xl font-extrabold text-amber-400 font-mono">{tenantMetrics.pending_bookings}</p>
          </div>
          <div className="p-4 bg-slate-900 border border-slate-800 rounded-xl space-y-1">
            <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Confirmées</span>
            <p className="text-2xl font-extrabold text-emerald-400 font-mono">{tenantMetrics.confirmed_bookings}</p>
          </div>
          <div className="p-4 bg-slate-900 border border-slate-800 rounded-xl space-y-1">
            <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Annulées</span>
            <p className="text-2xl font-extrabold text-rose-400 font-mono">{tenantMetrics.cancelled_bookings}</p>
          </div>
        </div>
      ) : null}
    </div>
  );
};
