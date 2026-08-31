/**
 * 🏛️ LYXAL WORKSPACE — Écran Complet du Module 09 : Bookings
 * 
 * Cet écran consomme EXCLUSIVEMENT le SDK Client typé (bookingsClient.ts), sans aucun
 * appel fetch HTTP direct dans le composant UI.
 */

import React, { useEffect, useState } from 'react';
import { bookingsClient } from '../../sdk/bookings/bookings.client';
import { BookingResponse } from '../../sdk/bookings/bookings.types';
import { useToast } from '../../components/Toast';
import { ApiError } from '../../sdk/client';

export const BookingsPage: React.FC = () => {
  const { addToast } = useToast();
  const [bookings, setBookings] = useState<BookingResponse[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  // Modal d'annulation
  const [selectedBookingForCancel, setSelectedBookingForCancel] = useState<BookingResponse | null>(null);
  const [cancelReason, setCancelReason] = useState<string>('');
  const [cancelling, setCancelling] = useState<boolean>(false);

  // Modal de réservation rapide
  const [showCreateModal, setShowCreateModal] = useState<boolean>(false);
  const [eventTypeSlug, setEventTypeSlug] = useState<string>('30min');
  const [startTime, setStartTime] = useState<string>('2026-08-04T10:00:00Z');
  const [guestName, setGuestName] = useState<string>('');
  const [guestEmail, setGuestEmail] = useState<string>('');
  const [notes, setNotes] = useState<string>('');
  const [creating, setCreating] = useState<boolean>(false);

  // Charge les réservations via SDK
  const loadBookings = async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await bookingsClient.listBookings();
      setBookings(data);
    } catch (err: unknown) {
      const msg = err instanceof ApiError ? err.message : 'Échec du chargement des réservations';
      setError(msg);
      addToast('error', 'Erreur Réservations', msg);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadBookings();
  }, []);

  const handleCreateBooking = async (e: React.FormEvent) => {
    e.preventDefault();
    setCreating(true);
    try {
      const created = await bookingsClient.createBooking({
        event_type_slug: eventTypeSlug,
        start_time: startTime,
        guest_name: guestName,
        guest_email: guestEmail,
        notes: notes || undefined,
      });
      setBookings((prev) => [created, ...prev]);
      addToast('success', 'Réservation Créée', `Rendez-vous réservé avec succès pour ${created.guest_name}.`);
      setShowCreateModal(false);
      setGuestName('');
      setGuestEmail('');
      setNotes('');
    } catch (err: unknown) {
      const msg = err instanceof ApiError ? err.message : 'Échec de création de la réservation';
      addToast('error', 'Erreur de Création', msg);
    } finally {
      setCreating(false);
    }
  };

  const handleConfirm = async (bookingId: string) => {
    try {
      const updated = await bookingsClient.confirmBooking(bookingId);
      setBookings((prev) => prev.map((b) => (b.id === updated.id ? updated : b)));
      addToast('success', 'Réservation Confirmée', 'Le statut a été mis à jour.');
    } catch (err: unknown) {
      const msg = err instanceof ApiError ? err.message : 'Échec de confirmation';
      addToast('error', 'Erreur Confirmation', msg);
    }
  };

  const handleCancel = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedBookingForCancel) return;
    setCancelling(true);
    try {
      await bookingsClient.cancelBooking(selectedBookingForCancel.id, { reason: cancelReason });
      setBookings((prev) =>
        prev.map((b) =>
          b.id === selectedBookingForCancel.id ? { ...b, status: 'cancelled' } : b
        )
      );
      addToast('success', 'Réservation Annulée', 'La réservation a été annulée.');
      setSelectedBookingForCancel(null);
      setCancelReason('');
    } catch (err: unknown) {
      const msg = err instanceof ApiError ? err.message : 'Échec de l\'annulation';
      addToast('error', 'Erreur d\'Annulation', msg);
    } finally {
      setCancelling(false);
    }
  };

  const getStatusBadge = (status: string) => {
    switch (status) {
      case 'confirmed':
        return <span className="px-2.5 py-1 bg-emerald-950/60 border border-emerald-500/30 text-emerald-300 font-semibold text-xs rounded-full">Confirmé</span>;
      case 'pending':
        return <span className="px-2.5 py-1 bg-amber-950/60 border border-amber-500/30 text-amber-300 font-semibold text-xs rounded-full">En attente</span>;
      case 'cancelled':
        return <span className="px-2.5 py-1 bg-rose-950/60 border border-rose-500/30 text-rose-300 font-semibold text-xs rounded-full">Annulé</span>;
      default:
        return <span className="px-2.5 py-1 bg-slate-800 border border-slate-700 text-slate-300 font-semibold text-xs rounded-full">{status}</span>;
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[300px] text-slate-400">
        <div className="flex items-center gap-3">
          <div className="w-5 h-5 border-2 border-indigo-500 border-t-transparent rounded-full animate-spin"></div>
          <span>Chargement des réservations via SDK...</span>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-8">
      {/* En-tête */}
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-2xl font-bold text-white tracking-tight">Gestion des Réservations</h2>
          <p className="text-sm text-slate-400 mt-1">
            Consultez, confirmez ou annulez vos rendez-vous clients en temps réel.
          </p>
        </div>
        <button
          onClick={() => setShowCreateModal(true)}
          className="flex items-center gap-2 px-4 py-2.5 bg-indigo-600 hover:bg-indigo-500 text-white font-semibold text-sm rounded-lg shadow-sm transition"
        >
          <span>+</span>
          <span>Nouvelle Réservation</span>
        </button>
      </div>

      {error && (
        <div className="p-4 bg-rose-950/40 border border-rose-500/30 rounded-xl text-rose-200 text-sm">
          <p>{error}</p>
        </div>
      )}

      {/* Tableau des Réservations */}
      <div className="bg-slate-900 border border-slate-800 rounded-xl overflow-hidden shadow-sm">
        {bookings.length === 0 ? (
          <div className="p-8 text-center text-slate-400">
            <p className="text-base font-medium text-slate-300">Aucune réservation pour le moment</p>
            <p className="text-xs text-slate-500 mt-1">Les rendez-vous pris sur vos pages de réservation apparaîtront ici.</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-sm text-slate-300">
              <thead className="bg-slate-950/60 text-xs font-semibold text-slate-400 uppercase tracking-wider border-b border-slate-800">
                <tr>
                  <th className="px-5 py-3.5">Invité</th>
                  <th className="px-5 py-3.5">Date & Heure</th>
                  <th className="px-5 py-3.5">Statut</th>
                  <th className="px-5 py-3.5 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-800/80">
                {bookings.map((b) => (
                  <tr key={b.id} className="hover:bg-slate-800/40 transition">
                    <td className="px-5 py-4">
                      <div>
                        <p className="font-bold text-white text-sm">{b.guest_name}</p>
                        <p className="text-xs text-slate-400 font-mono mt-0.5">{b.guest_email}</p>
                      </div>
                    </td>
                    <td className="px-5 py-4 font-mono text-xs">
                      <p className="text-slate-200 font-semibold">{new Date(b.start_at).toLocaleDateString()}</p>
                      <p className="text-slate-400 mt-0.5">{new Date(b.start_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })} - {new Date(b.end_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}</p>
                    </td>
                    <td className="px-5 py-4">{getStatusBadge(b.status)}</td>
                    <td className="px-5 py-4 text-right space-x-2">
                      {b.status === 'pending' && (
                        <button
                          onClick={() => handleConfirm(b.id)}
                          className="px-3 py-1.5 bg-emerald-950/60 hover:bg-emerald-900/60 text-emerald-300 border border-emerald-500/30 text-xs font-semibold rounded-md transition"
                        >
                          Confirmer
                        </button>
                      )}
                      {b.status !== 'cancelled' && (
                        <button
                          onClick={() => setSelectedBookingForCancel(b)}
                          className="px-3 py-1.5 bg-rose-950/40 hover:bg-rose-900/60 text-rose-300 border border-rose-500/30 text-xs font-semibold rounded-md transition"
                        >
                          Annuler
                        </button>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Modal Création Réservation */}
      {showCreateModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/70 backdrop-blur-sm p-4">
          <form onSubmit={handleCreateBooking} className="bg-slate-900 border border-slate-800 rounded-xl max-w-md w-full p-6 space-y-4 shadow-2xl">
            <div className="flex items-center justify-between border-b border-slate-800 pb-3">
              <h3 className="text-lg font-bold text-white">Nouvelle Réservation</h3>
              <button type="button" onClick={() => setShowCreateModal(false)} className="text-slate-400 hover:text-white">✕</button>
            </div>

            <div className="space-y-4">
              <div>
                <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1">Slug du Type d'Événement</label>
                <input
                  type="text"
                  value={eventTypeSlug}
                  onChange={(e) => setEventTypeSlug(e.target.value)}
                  required
                  className="w-full px-3.5 py-2 bg-slate-950 border border-slate-800 rounded-lg text-slate-100 text-sm font-mono"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1">Nom de l'Invité</label>
                <input
                  type="text"
                  value={guestName}
                  onChange={(e) => setGuestName(e.target.value)}
                  required
                  placeholder="Jean Dupont"
                  className="w-full px-3.5 py-2 bg-slate-950 border border-slate-800 rounded-lg text-slate-100 text-sm"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1">Email de l'Invité</label>
                <input
                  type="email"
                  value={guestEmail}
                  onChange={(e) => setGuestEmail(e.target.value)}
                  required
                  placeholder="jean.dupont@example.com"
                  className="w-full px-3.5 py-2 bg-slate-950 border border-slate-800 rounded-lg text-slate-100 text-sm"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1">Date & Heure ISO (UTC)</label>
                <input
                  type="text"
                  value={startTime}
                  onChange={(e) => setStartTime(e.target.value)}
                  required
                  className="w-full px-3.5 py-2 bg-slate-950 border border-slate-800 rounded-lg text-slate-100 text-sm font-mono"
                />
              </div>
            </div>

            <div className="flex justify-end gap-3 pt-3 border-t border-slate-800">
              <button
                type="button"
                onClick={() => setShowCreateModal(false)}
                className="px-4 py-2 bg-slate-800 hover:bg-slate-700 text-slate-300 font-semibold text-sm rounded-lg"
              >
                Annuler
              </button>
              <button
                type="submit"
                disabled={creating}
                className="px-5 py-2 bg-indigo-600 hover:bg-indigo-500 text-white font-semibold text-sm rounded-lg shadow-sm disabled:opacity-50"
              >
                {creating ? 'Création...' : 'Réserver'}
              </button>
            </div>
          </form>
        </div>
      )}

      {/* Modal Annulation */}
      {selectedBookingForCancel && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/70 backdrop-blur-sm p-4">
          <form onSubmit={handleCancel} className="bg-slate-900 border border-slate-800 rounded-xl max-w-md w-full p-6 space-y-4 shadow-2xl">
            <div className="flex items-center justify-between border-b border-slate-800 pb-3">
              <h3 className="text-lg font-bold text-white">Annuler le Rendez-vous</h3>
              <button type="button" onClick={() => setSelectedBookingForCancel(null)} className="text-slate-400 hover:text-white">✕</button>
            </div>

            <p className="text-xs text-slate-300">
              Annulation du rendez-vous avec <span className="font-bold text-white">{selectedBookingForCancel.guest_name}</span>.
            </p>

            <div>
              <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1">Raison de l'annulation (optionnel)</label>
              <textarea
                value={cancelReason}
                onChange={(e) => setCancelReason(e.target.value)}
                rows={3}
                placeholder="Ex: Empêchement de dernière minute..."
                className="w-full px-3.5 py-2 bg-slate-950 border border-slate-800 rounded-lg text-slate-100 text-sm"
              />
            </div>

            <div className="flex justify-end gap-3 pt-3 border-t border-slate-800">
              <button
                type="button"
                onClick={() => setSelectedBookingForCancel(null)}
                className="px-4 py-2 bg-slate-800 hover:bg-slate-700 text-slate-300 font-semibold text-sm rounded-lg"
              >
                Retour
              </button>
              <button
                type="submit"
                disabled={cancelling}
                className="px-5 py-2 bg-rose-600 hover:bg-rose-500 text-white font-semibold text-sm rounded-lg shadow-sm disabled:opacity-50"
              >
                {cancelling ? 'Annulation...' : 'Confirmer l\'annulation'}
              </button>
            </div>
          </form>
        </div>
      )}
    </div>
  );
};
