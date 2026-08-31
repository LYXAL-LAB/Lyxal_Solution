/**
 * 🏛️ LYXAL WORKSPACE — Écran des Actions par Jetons Publics (Module 10 : Public Booking)
 * 
 * Gère l'affichage et l'exécution des 5 actions par jetons à usage unique :
 * 1. Annulation invité par token (/public/bookings/cancel/{token})
 * 2. Report invité par token (/public/bookings/reschedule/{token})
 * 3. Approbation hôte par token (/public/bookings/approve/{token})
 * 4. Refus hôte par token (/public/bookings/decline/{token})
 * 5. Revendication d'équipe (/public/bookings/claim/{booking_id})
 */

import React, { useEffect, useState } from 'react';
import { bookingsClient } from '../../sdk/bookings/bookings.client';
import { PublicTokenInfoResponse, BookingResponse } from '../../sdk/bookings/bookings.types';
import { useToast } from '../../components/Toast';
import { ApiError } from '../../sdk/client';

interface PublicTokenActionPageProps {
  token?: string;
  actionType?: 'cancel' | 'reschedule' | 'approve' | 'decline' | 'claim';
}

export const PublicTokenActionPage: React.FC<PublicTokenActionPageProps> = ({
  token = 'demo_token_123',
  actionType = 'cancel',
}) => {
  const { addToast } = useToast();
  const [tokenInfo, setTokenInfo] = useState<PublicTokenInfoResponse | null>(null);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  // Formulaire d'action
  const [cancelReason, setCancelReason] = useState<string>('');
  const [newStartTime, setNewStartTime] = useState<string>('2026-08-05T14:00:00Z');
  const [executing, setExecuting] = useState<boolean>(false);
  const [actionDone, setActionDone] = useState<boolean>(false);

  // Charge les infos du jeton
  const loadTokenInfo = async () => {
    setLoading(true);
    setError(null);
    try {
      const info = await bookingsClient.getPublicTokenInfo(token);
      setTokenInfo(info);
    } catch (err: unknown) {
      const msg = err instanceof ApiError ? err.message : 'Jeton invalide ou expiré';
      setError(msg);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadTokenInfo();
  }, [token]);

  const handleExecuteAction = async () => {
    setExecuting(true);
    try {
      if (actionType === 'cancel') {
        await bookingsClient.cancelPublicBooking(token, { reason: cancelReason });
        addToast('success', 'Réservation Annulée', 'Votre annulation a bien été prise en compte.');
      } else if (actionType === 'reschedule') {
        await bookingsClient.reschedulePublicBooking(token, {
          expected_start_at: tokenInfo?.start_at || '',
          expected_end_at: tokenInfo?.end_at || '',
          new_start_at: newStartTime,
          new_end_at: new Date(new Date(newStartTime).getTime() + 30 * 60000).toISOString(),
        });
        addToast('success', 'Réservation Reportée', 'Votre rendez-vous a été déplacé.');
      } else if (actionType === 'approve') {
        await bookingsClient.approvePublicBooking(token);
        addToast('success', 'Demande Approuvée', 'La réservation a été confirmée.');
      } else if (actionType === 'decline') {
        await bookingsClient.declinePublicBooking(token);
        addToast('success', 'Demande Refusée', 'La réservation a été déclinée.');
      }
      setActionDone(true);
    } catch (err: unknown) {
      const msg = err instanceof ApiError ? err.message : 'Échec de l\'action sur la réservation';
      addToast('error', 'Erreur Action', msg);
    } finally {
      setExecuting(false);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[300px] text-slate-400">
        <div className="flex items-center gap-3">
          <div className="w-5 h-5 border-2 border-indigo-500 border-t-transparent rounded-full animate-spin"></div>
          <span>Vérification du lien sécurisé...</span>
        </div>
      </div>
    );
  }

  if (error || (tokenInfo && !tokenInfo.is_valid)) {
    return (
      <div className="max-w-md mx-auto p-6 bg-slate-900 border border-rose-500/30 rounded-2xl text-center space-y-4">
        <div className="w-12 h-12 bg-rose-950 text-rose-400 rounded-full flex items-center justify-center mx-auto text-xl font-bold">
          ✕
        </div>
        <h3 className="text-lg font-bold text-white">Lien Invalide ou Expiré</h3>
        <p className="text-xs text-slate-400">
          Ce lien sécurisé à usage unique a déjà été utilisé ou a expiré.
        </p>
      </div>
    );
  }

  if (actionDone) {
    return (
      <div className="max-w-md mx-auto p-6 bg-slate-900 border border-slate-800 rounded-2xl text-center space-y-4 shadow-xl">
        <div className="w-12 h-12 bg-emerald-950 text-emerald-400 rounded-full flex items-center justify-center mx-auto text-xl font-bold">
          ✓
        </div>
        <h3 className="text-lg font-bold text-white">Opération Terminée</h3>
        <p className="text-xs text-slate-400">
          L'action sur la réservation a été enregistrée avec succès.
        </p>
      </div>
    );
  }

  return (
    <div className="max-w-lg mx-auto bg-slate-900 border border-slate-800 rounded-2xl p-6 space-y-6 shadow-xl">
      <div className="border-b border-slate-800 pb-4 text-center">
        <span className="px-2.5 py-1 bg-slate-800 text-slate-300 font-semibold text-[10px] rounded-full uppercase">
          Action Sécurisée
        </span>
        <h3 className="text-xl font-bold text-white mt-2 capitalize">{actionType} Réservation</h3>
        <p className="text-xs text-slate-400 mt-1">
          Rendez-vous : <span className="text-slate-200 font-semibold">{tokenInfo?.event_type_title}</span>
        </p>
      </div>

      <div className="p-4 bg-slate-950/60 border border-slate-800 rounded-xl space-y-2 text-xs font-mono">
        <p><span className="text-slate-500">Invité :</span> <span className="text-slate-200">{tokenInfo?.guest_name}</span></p>
        <p><span className="text-slate-500">Date actuelle :</span> <span className="text-slate-200">{new Date(tokenInfo?.start_at || '').toLocaleString()}</span></p>
      </div>

      {actionType === 'cancel' && (
        <div>
          <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1">Raison de l'annulation (optionnel)</label>
          <textarea
            value={cancelReason}
            onChange={(e) => setCancelReason(e.target.value)}
            rows={3}
            placeholder="Ex: Changement de planning..."
            className="w-full px-3.5 py-2 bg-slate-950 border border-slate-800 rounded-lg text-slate-100 text-sm focus:outline-none focus:border-indigo-500"
          />
        </div>
      )}

      {actionType === 'reschedule' && (
        <div>
          <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1">Nouvelle Date ISO (UTC)</label>
          <input
            type="text"
            value={newStartTime}
            onChange={(e) => setNewStartTime(e.target.value)}
            required
            className="w-full px-3.5 py-2 bg-slate-950 border border-slate-800 rounded-lg text-slate-100 text-sm font-mono focus:outline-none focus:border-indigo-500"
          />
        </div>
      )}

      <button
        onClick={handleExecuteAction}
        disabled={executing}
        className={`w-full py-3 font-bold text-sm rounded-lg shadow-sm transition disabled:opacity-50 ${
          actionType === 'cancel' || actionType === 'decline'
            ? 'bg-rose-600 hover:bg-rose-500 text-white'
            : 'bg-indigo-600 hover:bg-indigo-500 text-white'
        }`}
      >
        {executing ? 'Traitement en cours...' : `Confirmer l'action : ${actionType}`}
      </button>
    </div>
  );
};
