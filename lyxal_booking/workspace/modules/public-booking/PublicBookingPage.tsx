/**
 * 🏛️ LYXAL WORKSPACE — Écran Invité de Réservation Publique (Module 10 : Public Booking)
 * 
 * Permet aux visiteurs et clients de réserver un créneau sur la page publique d'un hôte ou d'une équipe.
 * Consomme 100% le SDK Client (bookingsClient.ts et availabilityClient.ts).
 */

import React, { useEffect, useState } from 'react';
import { bookingsClient } from '../../sdk/bookings/bookings.client';
import { availabilityClient } from '../../sdk/availability/availability.client';
import { AvailabilitySlotResponse } from '../../sdk/availability/availability.types';
import { BookingResponse } from '../../sdk/bookings/bookings.types';
import { useToast } from '../../components/Toast';
import { ApiError } from '../../sdk/client';

interface PublicBookingPageProps {
  eventSlug?: string;
  onBookingSuccess?: (booking: BookingResponse) => void;
}

export const PublicBookingPage: React.FC<PublicBookingPageProps> = ({
  eventSlug = '30min',
  onBookingSuccess,
}) => {
  const { addToast } = useToast();
  const [slots, setSlots] = useState<AvailabilitySlotResponse[]>([]);
  const [loadingSlots, setLoadingSlots] = useState<boolean>(true);
  const [selectedSlot, setSelectedSlot] = useState<AvailabilitySlotResponse | null>(null);

  // Formulaire invité
  const [guestName, setGuestName] = useState<string>('');
  const [guestEmail, setGuestEmail] = useState<string>('');
  const [notes, setNotes] = useState<string>('');
  const [submitting, setSubmitting] = useState<boolean>(false);
  const [completedBooking, setCompletedBooking] = useState<BookingResponse | null>(null);

  // Charge les créneaux disponibles via SDK Availability
  const loadAvailableSlots = async () => {
    setLoadingSlots(true);
    try {
      const today = new Date().toISOString();
      const nextWeek = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString();
      const response = await availabilityClient.getAvailableSlots({
        event_type_slug: eventSlug,
        date_from: today,
        date_to: nextWeek,
        time_zone: Intl.DateTimeFormat().resolvedOptions().timeZone || 'UTC',
      });
      setSlots(response.slots);
      if (response.slots.length > 0) {
        setSelectedSlot(response.slots[0]);
      }
    } catch (err: unknown) {
      addToast('error', 'Erreur Créneaux', 'Échec du chargement des créneaux de disponibilité.');
    } finally {
      setLoadingSlots(false);
    }
  };

  useEffect(() => {
    loadAvailableSlots();
  }, [eventSlug]);

  const handleSubmitBooking = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedSlot) return;
    setSubmitting(true);
    try {
      const booking = await bookingsClient.createUserBooking('current_user', eventSlug, {
        event_type_slug: eventSlug,
        start_time: selectedSlot.start_at,
        guest_name: guestName,
        guest_email: guestEmail,
        notes: notes || undefined,
      });

      setCompletedBooking(booking);
      addToast('success', 'Réservation Confirmée !', `Rendez-vous réservé pour le ${new Date(booking.start_at).toLocaleString()}`);
      if (onBookingSuccess) {
        onBookingSuccess(booking);
      }
    } catch (err: unknown) {
      const msg = err instanceof ApiError ? err.message : 'Erreur lors de la réservation publique';
      addToast('error', 'Échec Réservation', msg);
    } finally {
      setSubmitting(false);
    }
  };

  if (completedBooking) {
    return (
      <div className="max-w-xl mx-auto p-8 bg-slate-900 border border-slate-800 rounded-2xl text-center space-y-6 shadow-2xl">
        <div className="w-16 h-16 bg-emerald-950 border border-emerald-500/30 text-emerald-400 rounded-full flex items-center justify-center mx-auto text-2xl font-bold">
          ✓
        </div>
        <div>
          <h2 className="text-2xl font-bold text-white tracking-tight">Rendez-vous Confirmé !</h2>
          <p className="text-sm text-slate-400 mt-2">
            Un e-mail d'invitation avec les détails du rendez-vous et le lien visio a été envoyé à <span className="font-semibold text-slate-200">{completedBooking.guest_email}</span>.
          </p>
        </div>
        <div className="p-4 bg-slate-950/80 border border-slate-800 rounded-xl text-left text-xs space-y-2 font-mono">
          <p><span className="text-slate-500">ID Réservation :</span> <span className="text-indigo-400 font-bold">{completedBooking.id}</span></p>
          <p><span className="text-slate-500">Date & Heure :</span> <span className="text-slate-200">{new Date(completedBooking.start_at).toLocaleString()}</span></p>
          <p><span className="text-slate-500">Invité :</span> <span className="text-slate-200">{completedBooking.guest_name} ({completedBooking.guest_email})</span></p>
          <p><span className="text-slate-500">Statut :</span> <span className="text-emerald-400 uppercase font-bold">{completedBooking.status}</span></p>
        </div>
        <button
          onClick={() => {
            setCompletedBooking(null);
            setGuestName('');
            setGuestEmail('');
            setNotes('');
          }}
          className="px-6 py-2.5 bg-indigo-600 hover:bg-indigo-500 text-white font-semibold text-sm rounded-lg shadow-sm transition"
        >
          Réserver un autre créneau
        </button>
      </div>
    );
  }

  return (
    <div className="max-w-4xl mx-auto space-y-8">
      <div className="text-center space-y-2">
        <span className="px-3 py-1 bg-indigo-950/60 border border-indigo-500/30 text-indigo-300 font-semibold text-xs rounded-full uppercase tracking-wider">
          Page de Réservation Publique
        </span>
        <h2 className="text-3xl font-extrabold text-white tracking-tight">Réservez un Rendez-vous</h2>
        <p className="text-sm text-slate-400 max-w-md mx-auto">
          Sélectionnez un créneau horaire disponible et renseignez vos coordonnées.
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-8 bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-xl">
        {/* Colonne 1 : Choix du Créneau Libre */}
        <div className="space-y-4">
          <h3 className="text-sm font-bold text-slate-200 uppercase tracking-wider border-b border-slate-800 pb-2">
            1. Choisissez un Créneau
          </h3>

          {loadingSlots ? (
            <div className="p-8 text-center text-slate-400 text-xs">
              <div className="w-5 h-5 border-2 border-indigo-500 border-t-transparent rounded-full animate-spin mx-auto mb-2"></div>
              Recherche des disponibilités...
            </div>
          ) : slots.length === 0 ? (
            <div className="p-6 bg-slate-950/60 border border-slate-800 rounded-xl text-center text-xs text-slate-400">
              Aucun créneau libre trouvé pour cette période.
            </div>
          ) : (
            <div className="space-y-2 max-h-80 overflow-y-auto pr-1">
              {slots.map((slot, idx) => (
                <button
                  key={idx}
                  type="button"
                  onClick={() => setSelectedSlot(slot)}
                  className={`w-full p-3.5 rounded-xl border text-left flex items-center justify-between transition ${
                    selectedSlot === slot
                      ? 'bg-indigo-950/60 border-indigo-500 text-white shadow-sm'
                      : 'bg-slate-950/40 border-slate-800 text-slate-300 hover:border-slate-700'
                  }`}
                >
                  <div>
                    <p className="font-bold text-xs font-mono">
                      {new Date(slot.start_at).toLocaleDateString([], { weekday: 'short', month: 'short', day: 'numeric' })}
                    </p>
                    <p className="text-xs text-slate-400 font-mono mt-0.5">
                      {new Date(slot.start_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })} - {new Date(slot.end_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                    </p>
                  </div>
                  {selectedSlot === slot && <span className="text-indigo-400 font-bold text-sm">✓</span>}
                </button>
              ))}
            </div>
          )}
        </div>

        {/* Colonne 2 : Formulaire Invité */}
        <form onSubmit={handleSubmitBooking} className="space-y-4">
          <h3 className="text-sm font-bold text-slate-200 uppercase tracking-wider border-b border-slate-800 pb-2">
            2. Vos Coordonnées
          </h3>

          <div>
            <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1">Nom complet</label>
            <input
              type="text"
              value={guestName}
              onChange={(e) => setGuestName(e.target.value)}
              required
              placeholder="Ex: Marie Curie"
              className="w-full px-3.5 py-2 bg-slate-950 border border-slate-800 rounded-lg text-slate-100 text-sm focus:outline-none focus:border-indigo-500"
            />
          </div>

          <div>
            <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1">Adresse e-mail</label>
            <input
              type="email"
              value={guestEmail}
              onChange={(e) => setGuestEmail(e.target.value)}
              required
              placeholder="marie.curie@example.com"
              className="w-full px-3.5 py-2 bg-slate-950 border border-slate-800 rounded-lg text-slate-100 text-sm focus:outline-none focus:border-indigo-500"
            />
          </div>

          <div>
            <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1">Notes / Remarques (optionnel)</label>
            <textarea
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
              rows={3}
              placeholder="Précisez le sujet de votre entretien..."
              className="w-full px-3.5 py-2 bg-slate-950 border border-slate-800 rounded-lg text-slate-100 text-sm focus:outline-none focus:border-indigo-500"
            />
          </div>

          <button
            type="submit"
            disabled={submitting || !selectedSlot}
            className="w-full py-3 bg-indigo-600 hover:bg-indigo-500 text-white font-bold text-sm rounded-lg shadow-sm transition disabled:opacity-50 mt-4"
          >
            {submitting ? 'Confirmation de la réservation...' : 'Confirmer le Rendez-vous'}
          </button>
        </form>
      </div>
    </div>
  );
};
