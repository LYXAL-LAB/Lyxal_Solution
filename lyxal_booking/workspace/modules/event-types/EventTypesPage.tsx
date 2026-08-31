/**
 * 🏛️ LYXAL WORKSPACE — Écran Complet du Module 06 : EventTypes
 * 
 * Cet écran consomme EXCLUSIVEMENT le SDK Client typé (eventTypesClient.ts), sans aucun
 * appel fetch HTTP direct dans le composant UI.
 */

import React, { useEffect, useState } from 'react';
import { eventTypesClient } from '../../sdk/event-types/event_types.client';
import { EventTypeResponse } from '../../sdk/event-types/event_types.types';
import { useToast } from '../../components/Toast';
import { ApiError } from '../../sdk/client';

export const EventTypesPage: React.FC = () => {
  const { addToast } = useToast();
  const [eventTypes, setEventTypes] = useState<EventTypeResponse[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  // Formulaire d'ajout / édition
  const [showAddModal, setShowAddModal] = useState<boolean>(false);
  const [editingType, setEditingType] = useState<EventTypeResponse | null>(null);
  const [submitting, setSubmitting] = useState<boolean>(false);

  const [title, setTitle] = useState<string>('');
  const [slug, setSlug] = useState<string>('');
  const [durationMinutes, setDurationMinutes] = useState<number>(30);
  const [description, setDescription] = useState<string>('');

  const [deletingSlug, setDeletingSlug] = useState<string | null>(null);

  // Charge les types d'événements via le SDK Client
  const loadEventTypes = async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await eventTypesClient.listEventTypes();
      setEventTypes(data);
    } catch (err: unknown) {
      const msg = err instanceof ApiError ? err.message : 'Échec du chargement des créneaux de réservation';
      setError(msg);
      addToast('error', 'Erreur Créneaux', msg);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadEventTypes();
  }, []);

  // Génère automatiquement un slug à partir du titre
  const handleTitleChange = (val: string) => {
    setTitle(val);
    if (!editingType) {
      const autoSlug = val
        .toLowerCase()
        .trim()
        .replace(/[^a-z0-9 -]/g, '')
        .replace(/\s+/g, '-')
        .replace(/-+/g, '-');
      setSlug(autoSlug);
    }
  };

  // Prépare le formulaire pour l'édition
  const openEditModal = (et: EventTypeResponse) => {
    setEditingType(et);
    setTitle(et.title);
    setSlug(et.slug);
    setDurationMinutes(et.duration_minutes);
    setDescription(et.description || '');
    setShowAddModal(true);
  };

  // Réinitialise le formulaire
  const resetForm = () => {
    setShowAddModal(false);
    setEditingType(null);
    setTitle('');
    setSlug('');
    setDurationMinutes(30);
    setDescription('');
  };

  // Soumission de création ou de modification via SDK Client
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitting(true);

    try {
      if (editingType) {
        const updated = await eventTypesClient.updateEventType(editingType.slug, {
          title,
          slug,
          duration_minutes: durationMinutes,
          description: description || null,
        });
        setEventTypes((prev) => prev.map((t) => (t.id === updated.id ? updated : t)));
        addToast('success', 'Créneau mis à jour', `Le créneau "${updated.title}" a été enregistré.`);
      } else {
        const created = await eventTypesClient.createEventType({
          title,
          slug,
          duration_minutes: durationMinutes,
          description: description || null,
        });
        setEventTypes((prev) => [...prev, created]);
        addToast('success', 'Créneau créé', `Nouveau type d'événement "${created.title}" ajouté.`);
      }
      resetForm();
    } catch (err: unknown) {
      const msg = err instanceof ApiError ? err.message : 'Erreur lors de la sauvegarde du créneau';
      addToast('error', 'Erreur de sauvegarde', msg);
    } finally {
      setSubmitting(false);
    }
  };

  // Suppression d'un créneau via SDK Client
  const handleDelete = async (targetSlug: string) => {
    if (!confirm('Voulez-vous vraiment supprimer ce type d\'événement ?')) return;
    setDeletingSlug(targetSlug);
    try {
      await eventTypesClient.deleteEventType(targetSlug);
      setEventTypes((prev) => prev.filter((t) => t.slug !== targetSlug));
      addToast('success', 'Créneau supprimé', 'Le type d\'événement a été retiré.');
    } catch (err: unknown) {
      const msg = err instanceof ApiError ? err.message : 'Impossible de supprimer le créneau';
      addToast('error', 'Erreur de suppression', msg);
    } finally {
      setDeletingSlug(null);
    }
  };

  const [beforeBufferMinutes, setBeforeBufferMinutes] = useState<number>(0);
  const [afterBufferMinutes, setAfterBufferMinutes] = useState<number>(0);
  const [locationType, setLocationType] = useState<string>('GOOGLE_MEET');

  const [togglingSlug, setTogglingSlug] = useState<string | null>(null);

  // Bascule le statut actif / masque d'un type d'evenement via le SDK Client
  const handleToggleActive = async (targetSlug: string) => {
    setTogglingSlug(targetSlug);
    try {
      const res = await eventTypesClient.toggleEventType(targetSlug);
      setEventTypes((prev) =>
        prev.map((t) => (t.slug === targetSlug ? { ...t, active: res.active } : t))
      );
      addToast('success', 'Statut mis a jour', `Le créneau est désormais ${res.active ? 'actif' : 'masqué'}.`);
    } catch (err: unknown) {
      const msg = err instanceof ApiError ? err.message : 'Échec du changement de statut';
      addToast('error', 'Erreur de Statut', msg);
    } finally {
      setTogglingSlug(null);
    }
  };

  // Copie du lien public de réservation canonique (/u/me/{slug}) dans le presse-papier
  const copyPublicLink = (targetSlug: string) => {
    const link = `${window.location.origin}/u/me/${targetSlug}`;
    navigator.clipboard.writeText(link);
    addToast('success', 'Lien copié', `Lien public de réservation : ${link}`);
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[300px] text-slate-400">
        <div className="flex items-center gap-3">
          <div className="w-5 h-5 border-2 border-indigo-500 border-t-transparent rounded-full animate-spin"></div>
          <span>Chargement des types d'événements via SDK...</span>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-8">
      {/* En-tête avec Bouton d'Action */}
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-2xl font-bold text-white tracking-tight">Types d'Événements & Créneaux</h2>
          <p className="text-sm text-slate-400 mt-1">
            Configurez vos créneaux de rendez-vous réutilisables (durées, tarifs, descriptions).
          </p>
        </div>
        <button
          onClick={() => {
            resetForm();
            setShowAddModal(true);
          }}
          className="flex items-center gap-2 px-4 py-2.5 bg-indigo-600 hover:bg-indigo-500 text-white font-semibold text-sm rounded-lg shadow-sm transition"
        >
          <span>+</span>
          <span>Nouveau Créneau</span>
        </button>
      </div>

      {error && (
        <div className="p-4 bg-rose-950/40 border border-rose-500/30 rounded-xl text-rose-200 text-sm">
          <p>{error}</p>
        </div>
      )}

      {/* Grille des Types d'Événements */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {eventTypes.length === 0 ? (
          <div className="col-span-full p-8 bg-slate-900 border border-slate-800 rounded-xl text-center text-slate-400">
            <p className="text-base font-medium text-slate-300">Aucun type d'événement configuré</p>
            <p className="text-xs text-slate-500 mt-1">Créez votre premier créneau de réservation (ex: "Consultation 30 min").</p>
          </div>
        ) : (
          eventTypes.map((et) => (
            <div key={et.id} className="p-5 bg-slate-900 border border-slate-800 rounded-xl flex flex-col justify-between space-y-4 hover:border-slate-700 transition shadow-sm">
              <div>
                <div className="flex items-start justify-between gap-3">
                  <div className="flex items-center gap-2.5">
                    <span className="w-3 h-3 rounded-full bg-indigo-500"></span>
                    <h3 className="font-bold text-lg text-white">{et.title}</h3>
                  </div>
                  <span className="px-2.5 py-1 bg-indigo-950 border border-indigo-500/30 text-indigo-300 font-bold text-xs rounded-full">
                    {et.duration_minutes} min
                  </span>
                </div>

                <p className="text-xs text-slate-400 font-mono mt-1">/{et.slug}</p>

                {et.description && (
                  <p className="text-xs text-slate-400 mt-3 line-clamp-2 leading-relaxed">
                    {et.description}
                  </p>
                )}
              </div>

              <div className="flex items-center justify-between pt-4 border-t border-slate-800/80">
                <button
                  onClick={() => copyPublicLink(et.slug)}
                  className="flex items-center gap-1.5 text-xs text-indigo-400 hover:text-indigo-300 font-semibold"
                >
                  <span>🔗</span>
                  <span>Copier le lien</span>
                </button>

                <div className="flex items-center gap-2">
                  <button
                    onClick={() => openEditModal(et)}
                    className="px-3 py-1.5 bg-slate-800 hover:bg-slate-700 text-slate-200 text-xs font-semibold rounded-md border border-slate-700 transition"
                  >
                    Modifier
                  </button>
                  <button
                    onClick={() => handleDelete(et.slug)}
                    disabled={deletingSlug === et.slug}
                    className="px-3 py-1.5 bg-rose-950/40 hover:bg-rose-900/60 text-rose-300 border border-rose-500/30 text-xs font-semibold rounded-md transition disabled:opacity-50"
                  >
                    Supprimer
                  </button>
                </div>
              </div>
            </div>
          ))
        )}
      </div>

      {/* Modal Création / Modification */}
      {showAddModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/70 backdrop-blur-sm p-4">
          <form onSubmit={handleSubmit} className="bg-slate-900 border border-slate-800 rounded-xl max-w-lg w-full p-6 space-y-4 shadow-2xl">
            <div className="flex items-center justify-between border-b border-slate-800 pb-3">
              <h3 className="text-lg font-bold text-white">
                {editingType ? 'Modifier le Créneau' : 'Nouveau Type d\'Événement'}
              </h3>
              <button type="button" onClick={resetForm} className="text-slate-400 hover:text-white">✕</button>
            </div>

            <div className="space-y-4">
              <div>
                <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1">Titre de la prestation</label>
                <input
                  type="text"
                  value={title}
                  onChange={(e) => handleTitleChange(e.target.value)}
                  required
                  placeholder="Ex: Consultation Stratégique"
                  className="w-full px-3.5 py-2 bg-slate-950 border border-slate-800 rounded-lg text-slate-100 text-sm focus:outline-none focus:border-indigo-500"
                />
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1">Slug URL</label>
                  <input
                    type="text"
                    value={slug}
                    onChange={(e) => setSlug(e.target.value)}
                    required
                    placeholder="consultation-strategique"
                    className="w-full px-3.5 py-2 bg-slate-950 border border-slate-800 rounded-lg text-slate-100 text-sm focus:outline-none focus:border-indigo-500 font-mono"
                  />
                </div>

                <div>
                  <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1">Durée (minutes)</label>
                  <select
                    value={durationMinutes}
                    onChange={(e) => setDurationMinutes(Number(e.target.value))}
                    className="w-full px-3.5 py-2 bg-slate-950 border border-slate-800 rounded-lg text-slate-100 text-sm"
                  >
                    <option value={15}>15 minutes</option>
                    <option value={30}>30 minutes</option>
                    <option value={45}>45 minutes</option>
                    <option value={60}>60 minutes (1h)</option>
                    <option value={90}>90 minutes (1h30)</option>
                    <option value={120}>120 minutes (2h)</option>
                  </select>
                </div>
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1">Description (Optionnel)</label>
                <textarea
                  value={description}
                  onChange={(e) => setDescription(e.target.value)}
                  rows={3}
                  placeholder="Session d'analyse approfondie de votre projet."
                  className="w-full px-3.5 py-2 bg-slate-950 border border-slate-800 rounded-lg text-slate-100 text-sm focus:outline-none focus:border-indigo-500 resize-none"
                />
              </div>
            </div>

            <div className="flex justify-end gap-3 pt-3 border-t border-slate-800">
              <button
                type="button"
                onClick={resetForm}
                className="px-4 py-2 bg-slate-800 hover:bg-slate-700 text-slate-300 font-semibold text-sm rounded-lg"
              >
                Annuler
              </button>
              <button
                type="submit"
                disabled={submitting}
                className="px-5 py-2 bg-indigo-600 hover:bg-indigo-500 text-white font-semibold text-sm rounded-lg shadow-sm disabled:opacity-50"
              >
                {submitting ? 'Sauvegarde...' : editingType ? 'Enregistrer' : 'Créer le créneau'}
              </button>
            </div>
          </form>
        </div>
      )}
    </div>
  );
};
