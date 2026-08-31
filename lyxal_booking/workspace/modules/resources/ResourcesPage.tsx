/**
 * 🏛️ LYXAL WORKSPACE — Écran Complet du Module 05 : Resources
 * 
 * Cet écran consomme EXCLUSIVEMENT le SDK Client typé (resourcesClient.ts), sans aucun
 * appel fetch HTTP direct dans le composant UI.
 */

import React, { useEffect, useState } from 'react';
import { resourcesClient } from '../../sdk/resources/resources.client';
import { ResourceResponse } from '../../sdk/resources/resources.types';
import { useToast } from '../../components/Toast';
import { ApiError } from '../../sdk/client';

export const ResourcesPage: React.FC = () => {
  const { addToast } = useToast();
  const [resources, setResources] = useState<ResourceResponse[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  // Formulaire d'ajout / édition
  const [showAddModal, setShowAddModal] = useState<boolean>(false);
  const [editingResource, setEditingResource] = useState<ResourceResponse | null>(null);
  const [submitting, setSubmitting] = useState<boolean>(false);

  const [name, setName] = useState<string>('');
  const [resourceType, setResourceType] = useState<string>('ROOM');
  const [capacity, setCapacity] = useState<number | ''>('');
  const [location, setLocation] = useState<string>('');
  const [description, setDescription] = useState<string>('');

  const [deletingId, setDeletingId] = useState<string | null>(null);

  // Charge les ressources via le SDK Client
  const loadResources = async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await resourcesClient.listResources();
      setResources(data);
    } catch (err: unknown) {
      const msg = err instanceof ApiError ? err.message : 'Échec du chargement des ressources';
      setError(msg);
      addToast('error', 'Erreur Ressources', msg);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadResources();
  }, []);

  // Prépare le formulaire pour l'édition
  const openEditModal = (res: ResourceResponse) => {
    setEditingResource(res);
    setName(res.name);
    setResourceType(res.resource_type);
    setCapacity(res.capacity || '');
    setLocation(res.location || '');
    setDescription(res.description || '');
    setShowAddModal(true);
  };

  // Réinitialise le formulaire
  const resetForm = () => {
    setShowAddModal(false);
    setEditingResource(null);
    setName('');
    setResourceType('ROOM');
    setCapacity('');
    setLocation('');
    setDescription('');
  };

  // Soumission de création ou de modification via SDK Client
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitting(true);

    const payload = {
      name,
      resource_type: resourceType,
      capacity: capacity ? Number(capacity) : null,
      location: location || null,
      description: description || null,
    };

    try {
      if (editingResource) {
        const updated = await resourcesClient.updateResource(editingResource.id, payload);
        setResources((prev) => prev.map((r) => (r.id === updated.id ? updated : r)));
        addToast('success', 'Ressource mise à jour', `La ressource "${updated.name}" a été enregistrée.`);
      } else {
        const created = await resourcesClient.createResource(payload);
        setResources((prev) => [...prev, created]);
        addToast('success', 'Ressource créée', `Nouvelle ressource "${created.name}" ajoutée avec succès.`);
      }
      resetForm();
    } catch (err: unknown) {
      const msg = err instanceof ApiError ? err.message : 'Erreur lors de l\'enregistrement de la ressource';
      addToast('error', 'Erreur de sauvegarde', msg);
    } finally {
      setSubmitting(false);
    }
  };

  const [syncingId, setSyncingId] = useState<string | null>(null);

  // Synchronisation du flux d'agenda d'une ressource (ICS/CalDAV) via SDK
  const handleSync = async (id: string) => {
    setSyncingId(id);
    try {
      const res = await resourcesClient.syncResource(id);
      addToast('success', 'Synchronisation Ressource', `${res.synchronized_events} événement(s) synchronisé(s) pour la ressource.`);
    } catch (err: unknown) {
      const msg = err instanceof ApiError ? err.message : 'Échec de synchronisation de la ressource';
      addToast('error', 'Erreur de Sync', msg);
    } finally {
      setSyncingId(null);
    }
  };

  // Suppression d'une ressource via SDK Client
  const handleDelete = async (id: string) => {
    if (!confirm('Voulez-vous vraiment supprimer cette ressource ?')) return;
    setDeletingId(id);
    try {
      await resourcesClient.deleteResource(id);
      setResources((prev) => prev.filter((r) => r.id !== id));
      addToast('success', 'Ressource supprimée', 'La ressource a été retirée avec succès.');
    } catch (err: unknown) {
      const msg = err instanceof ApiError ? err.message : 'Impossible de supprimer la ressource';
      addToast('error', 'Erreur de suppression', msg);
    } finally {
      setDeletingId(null);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[300px] text-slate-400">
        <div className="flex items-center gap-3">
          <div className="w-5 h-5 border-2 border-indigo-500 border-t-transparent rounded-full animate-spin"></div>
          <span>Chargement des ressources matérielles via SDK...</span>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-8">
      {/* En-tête avec Bouton d'Action */}
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-2xl font-bold text-white tracking-tight">Ressources & Matériels</h2>
          <p className="text-sm text-slate-400 mt-1">
            Gérez vos salles de réunion, équipements, véhicules et matériels réservables.
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
          <span>Ajouter une Ressource</span>
        </button>
      </div>

      {error && (
        <div className="p-4 bg-rose-950/40 border border-rose-500/30 rounded-xl text-rose-200 text-sm">
          <p>{error}</p>
        </div>
      )}

      {/* Grille / Liste des Ressources */}
      <div className="bg-slate-900 border border-slate-800 rounded-xl overflow-hidden shadow-sm">
        <div className="p-4 border-b border-slate-800 bg-slate-950/40 flex items-center justify-between">
          <h3 className="text-sm font-semibold text-slate-300">Ressources Déclarées ({resources.length})</h3>
        </div>

        {resources.length === 0 ? (
          <div className="p-8 text-center text-slate-400">
            <p className="text-base font-medium text-slate-300">Aucune ressource disponible</p>
            <p className="text-xs text-slate-500 mt-1">Créez votre première salle de réunion ou équipement matériel.</p>
          </div>
        ) : (
          <div className="divide-y divide-slate-800">
            {resources.map((r) => (
              <div key={r.id} className="p-4 sm:p-5 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 hover:bg-slate-800/30 transition">
                <div className="flex items-center gap-4">
                  <div className="w-10 h-10 rounded-lg bg-indigo-950 border border-indigo-500/30 flex items-center justify-center text-lg">
                    {r.resource_type === 'ROOM' ? '🏢' : r.resource_type === 'VEHICLE' ? '🚗' : '💻'}
                  </div>
                  <div>
                    <div className="flex items-center gap-2">
                      <h4 className="font-bold text-slate-100 text-base">{r.name}</h4>
                      <span className="px-2 py-0.5 rounded-full text-[10px] font-semibold bg-indigo-950 text-indigo-300 border border-indigo-500/30 uppercase tracking-wider">
                        {r.resource_type}
                      </span>
                    </div>
                    <p className="text-xs text-slate-400 mt-0.5">
                      {r.location && <span>Emplacement: <strong className="text-slate-300 font-normal">{r.location}</strong></span>}
                      {r.capacity && <span className="ml-3">Capacité: <strong className="text-slate-300 font-normal">{r.capacity} pers.</strong></span>}
                    </p>
                    {r.description && <p className="text-xs text-slate-500 mt-1 line-clamp-1">{r.description}</p>}
                  </div>
                </div>

                <div className="flex items-center gap-2 w-full sm:w-auto justify-end">
                  <button
                    onClick={() => openEditModal(r)}
                    className="px-3 py-1.5 bg-slate-800 hover:bg-slate-700 text-slate-200 text-xs font-semibold rounded-md border border-slate-700 transition"
                  >
                    Modifier
                  </button>
                  <button
                    onClick={() => handleDelete(r.id)}
                    disabled={deletingId === r.id}
                    className="px-3 py-1.5 bg-rose-950/40 hover:bg-rose-900/60 text-rose-300 border border-rose-500/30 text-xs font-semibold rounded-md transition disabled:opacity-50"
                  >
                    Supprimer
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Modal Création / Modification */}
      {showAddModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/70 backdrop-blur-sm p-4">
          <form onSubmit={handleSubmit} className="bg-slate-900 border border-slate-800 rounded-xl max-w-lg w-full p-6 space-y-4 shadow-2xl">
            <div className="flex items-center justify-between border-b border-slate-800 pb-3">
              <h3 className="text-lg font-bold text-white">
                {editingResource ? 'Modifier la Ressource' : 'Ajouter une Ressource'}
              </h3>
              <button type="button" onClick={resetForm} className="text-slate-400 hover:text-white">✕</button>
            </div>

            <div className="space-y-4">
              <div>
                <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1">Nom de la ressource</label>
                <input
                  type="text"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  required
                  placeholder="Ex: Salle de Conférence Alpha"
                  className="w-full px-3.5 py-2 bg-slate-950 border border-slate-800 rounded-lg text-slate-100 text-sm focus:outline-none focus:border-indigo-500"
                />
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1">Type</label>
                  <select
                    value={resourceType}
                    onChange={(e) => setResourceType(e.target.value)}
                    className="w-full px-3.5 py-2 bg-slate-950 border border-slate-800 rounded-lg text-slate-100 text-sm"
                  >
                    <option value="ROOM">Salle de Réunion (ROOM)</option>
                    <option value="EQUIPMENT">Équipement Matériel (EQUIPMENT)</option>
                    <option value="VEHICLE">Véhicule (VEHICLE)</option>
                  </select>
                </div>

                <div>
                  <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1">Capacité (personnes)</label>
                  <input
                    type="number"
                    value={capacity}
                    onChange={(e) => setCapacity(e.target.value ? Number(e.target.value) : '')}
                    placeholder="12"
                    className="w-full px-3.5 py-2 bg-slate-950 border border-slate-800 rounded-lg text-slate-100 text-sm focus:outline-none focus:border-indigo-500"
                  />
                </div>
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1">Emplacement / Adresse</label>
                <input
                  type="text"
                  value={location}
                  onChange={(e) => setLocation(e.target.value)}
                  placeholder="Ex: Étage 2, Bâtiment B"
                  className="w-full px-3.5 py-2 bg-slate-950 border border-slate-800 rounded-lg text-slate-100 text-sm focus:outline-none focus:border-indigo-500"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1">Description (Optionnel)</label>
                <textarea
                  value={description}
                  onChange={(e) => setDescription(e.target.value)}
                  rows={3}
                  placeholder="Équipée d'un vidéo-projecteur 4K et pieuvre téléphonique."
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
                {submitting ? 'Sauvegarde...' : editingResource ? 'Enregistrer' : 'Créer la ressource'}
              </button>
            </div>
          </form>
        </div>
      )}
    </div>
  );
};
