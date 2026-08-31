/**
 * 🏛️ LYXAL WORKSPACE — Écran Complet du Module 08 : Teams
 * 
 * Cet écran consomme EXCLUSIVEMENT le SDK Client typé (teamsClient.ts), sans aucun
 * appel fetch HTTP direct dans le composant UI.
 */

import React, { useEffect, useState } from 'react';
import { teamsClient } from '../../sdk/teams/teams.client';
import { TeamResponse, TeamMemberResponse } from '../../sdk/teams/teams.types';
import { useToast } from '../../components/Toast';
import { ApiError } from '../../sdk/client';

export const TeamsPage: React.FC = () => {
  const { addToast } = useToast();
  const [teams, setTeams] = useState<TeamResponse[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  // Formulaire de création / modification d'équipe
  const [showModal, setShowModal] = useState<boolean>(false);
  const [editingTeam, setEditingTeam] = useState<TeamResponse | null>(null);
  const [name, setName] = useState<string>('');
  const [slug, setSlug] = useState<string>('');
  const [submitting, setSubmitting] = useState<boolean>(false);

  // Gestion des membres d'une équipe sélectionnée
  const [selectedTeamForMembers, setSelectedTeamForMembers] = useState<TeamResponse | null>(null);
  const [members, setMembers] = useState<TeamMemberResponse[]>([]);
  const [loadingMembers, setLoadingMembers] = useState<boolean>(false);
  const [newMemberUserId, setNewMemberUserId] = useState<string>('');
  const [newMemberRole, setNewMemberRole] = useState<'owner' | 'admin' | 'member'>('member');
  const [addingMember, setAddingMember] = useState<boolean>(false);

  const [deletingId, setDeletingId] = useState<string | null>(null);

  // Charge les équipes via le SDK Client
  const loadTeams = async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await teamsClient.listTeams();
      setTeams(data);
    } catch (err: unknown) {
      const msg = err instanceof ApiError ? err.message : 'Échec du chargement des équipes';
      setError(msg);
      addToast('error', 'Erreur Équipes', msg);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadTeams();
  }, []);

  const handleNameChange = (val: string) => {
    setName(val);
    if (!editingTeam) {
      const autoSlug = val
        .toLowerCase()
        .trim()
        .replace(/[^a-z0-9 -]/g, '')
        .replace(/\s+/g, '-')
        .replace(/-+/g, '-');
      setSlug(autoSlug);
    }
  };

  const resetForm = () => {
    setShowModal(false);
    setEditingTeam(null);
    setName('');
    setSlug('');
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitting(true);
    try {
      if (editingTeam) {
        const updated = await teamsClient.updateTeam(editingTeam.id, { name, slug });
        setTeams((prev) => prev.map((t) => (t.id === updated.id ? updated : t)));
        addToast('success', 'Équipe Mise à Jour', `L'équipe "${updated.name}" a été enregistrée.`);
      } else {
        const created = await teamsClient.createTeam({ name, slug });
        setTeams((prev) => [...prev, created]);
        addToast('success', 'Équipe Créée', `L'équipe "${created.name}" a été créée avec succès.`);
      }
      resetForm();
    } catch (err: unknown) {
      const msg = err instanceof ApiError ? err.message : 'Erreur lors de la sauvegarde de l\'équipe';
      addToast('error', 'Erreur de Sauvegarde', msg);
    } finally {
      setSubmitting(false);
    }
  };

  const handleDelete = async (teamId: string) => {
    if (!confirm('Voulez-vous vraiment supprimer cette équipe ?')) return;
    setDeletingId(teamId);
    try {
      await teamsClient.deleteTeam(teamId);
      setTeams((prev) => prev.filter((t) => t.id !== teamId));
      addToast('success', 'Équipe Supprimée', 'L\'équipe a été retirée.');
    } catch (err: unknown) {
      const msg = err instanceof ApiError ? err.message : 'Impossible de supprimer l\'équipe';
      addToast('error', 'Erreur de Suppression', msg);
    } finally {
      setDeletingId(null);
    }
  };

  const openMembersModal = async (team: TeamResponse) => {
    setSelectedTeamForMembers(team);
    setLoadingMembers(true);
    try {
      const data = await teamsClient.getMembers(team.id);
      setMembers(data);
    } catch (err: unknown) {
      addToast('error', 'Erreur Membres', 'Échec du chargement des membres d\'équipe');
    } finally {
      setLoadingMembers(false);
    }
  };

  const handleAddMember = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedTeamForMembers || !newMemberUserId) return;
    setAddingMember(true);
    try {
      const added = await teamsClient.addMember(selectedTeamForMembers.id, {
        user_id: newMemberUserId,
        role: newMemberRole,
      });
      setMembers((prev) => [...prev, added]);
      setNewMemberUserId('');
      addToast('success', 'Membre Ajouté', `Utilisateur rattaché à l'équipe.`);
    } catch (err: unknown) {
      const msg = err instanceof ApiError ? err.message : 'Impossible d\'ajouter ce membre';
      addToast('error', 'Erreur Membre', msg);
    } finally {
      setAddingMember(false);
    }
  };

  const handleRemoveMember = async (userId: string) => {
    if (!selectedTeamForMembers) return;
    try {
      await teamsClient.removeMember(selectedTeamForMembers.id, userId);
      setMembers((prev) => prev.filter((m) => m.user_id !== userId));
      addToast('success', 'Membre Retiré', 'Le membre a été retiré de l\'équipe.');
    } catch (err: unknown) {
      const msg = err instanceof ApiError ? err.message : 'Échec du retrait du membre';
      addToast('error', 'Erreur Membre', msg);
    }
  };

  const copyPublicTeamLink = (teamSlug: string) => {
    const link = `${window.location.origin}/team/${teamSlug}`;
    navigator.clipboard.writeText(link);
    addToast('success', 'Lien Équipe Copié', `URL publique : ${link}`);
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[300px] text-slate-400">
        <div className="flex items-center gap-3">
          <div className="w-5 h-5 border-2 border-indigo-500 border-t-transparent rounded-full animate-spin"></div>
          <span>Chargement des équipes via SDK...</span>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-8">
      {/* En-tête avec Bouton d'Action */}
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-2xl font-bold text-white tracking-tight">Équipes & Réservation Collective</h2>
          <p className="text-sm text-slate-400 mt-1">
            Gérez vos équipes, membres et pages de réservation collectives en Round-Robin.
          </p>
        </div>
        <button
          onClick={() => {
            resetForm();
            setShowModal(true);
          }}
          className="flex items-center gap-2 px-4 py-2.5 bg-indigo-600 hover:bg-indigo-500 text-white font-semibold text-sm rounded-lg shadow-sm transition"
        >
          <span>+</span>
          <span>Nouvelle Équipe</span>
        </button>
      </div>

      {error && (
        <div className="p-4 bg-rose-950/40 border border-rose-500/30 rounded-xl text-rose-200 text-sm">
          <p>{error}</p>
        </div>
      )}

      {/* Grille des Équipes */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {teams.length === 0 ? (
          <div className="col-span-full p-8 bg-slate-900 border border-slate-800 rounded-xl text-center text-slate-400">
            <p className="text-base font-medium text-slate-300">Aucune équipe configurée</p>
            <p className="text-xs text-slate-500 mt-1">Créez votre première équipe pour partager des créneaux en Round-Robin.</p>
          </div>
        ) : (
          teams.map((t) => (
            <div key={t.id} className="p-5 bg-slate-900 border border-slate-800 rounded-xl flex flex-col justify-between space-y-4 hover:border-slate-700 transition shadow-sm">
              <div>
                <div className="flex items-start justify-between gap-3">
                  <div className="flex items-center gap-2.5">
                    <span className="w-3 h-3 rounded-full bg-emerald-500"></span>
                    <h3 className="font-bold text-lg text-white">{t.name}</h3>
                  </div>
                  <span className="px-2.5 py-1 bg-slate-800 border border-slate-700 text-slate-300 font-semibold text-xs rounded-full uppercase">
                    {t.role || 'Member'}
                  </span>
                </div>

                <p className="text-xs text-slate-400 font-mono mt-1">/team/{t.slug}</p>
                <p className="text-xs text-slate-500 mt-2">Membres rattachés : <span className="text-slate-300 font-bold">{t.member_count || 1}</span></p>
              </div>

              <div className="flex items-center justify-between pt-4 border-t border-slate-800/80">
                <button
                  onClick={() => copyPublicTeamLink(t.slug)}
                  className="flex items-center gap-1.5 text-xs text-indigo-400 hover:text-indigo-300 font-semibold"
                >
                  <span>🔗</span>
                  <span>Lien Équipe</span>
                </button>

                <div className="flex items-center gap-2">
                  <button
                    onClick={() => openMembersModal(t)}
                    className="px-3 py-1.5 bg-slate-800 hover:bg-slate-700 text-slate-200 text-xs font-semibold rounded-md border border-slate-700 transition"
                  >
                    Membres
                  </button>
                  <button
                    onClick={() => handleDelete(t.id)}
                    disabled={deletingId === t.id}
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

      {/* Modal Création / Modification d'Équipe */}
      {showModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/70 backdrop-blur-sm p-4">
          <form onSubmit={handleSubmit} className="bg-slate-900 border border-slate-800 rounded-xl max-w-md w-full p-6 space-y-4 shadow-2xl">
            <div className="flex items-center justify-between border-b border-slate-800 pb-3">
              <h3 className="text-lg font-bold text-white">
                {editingTeam ? 'Modifier l\'Équipe' : 'Nouvelle Équipe'}
              </h3>
              <button type="button" onClick={resetForm} className="text-slate-400 hover:text-white">✕</button>
            </div>

            <div className="space-y-4">
              <div>
                <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1">Nom de l'équipe</label>
                <input
                  type="text"
                  value={name}
                  onChange={(e) => handleNameChange(e.target.value)}
                  required
                  placeholder="Ex: Équipe Commerciale France"
                  className="w-full px-3.5 py-2 bg-slate-950 border border-slate-800 rounded-lg text-slate-100 text-sm focus:outline-none focus:border-indigo-500"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1">Slug URL (/team/{slug})</label>
                <input
                  type="text"
                  value={slug}
                  onChange={(e) => setSlug(e.target.value)}
                  required
                  placeholder="equipe-commerciale"
                  className="w-full px-3.5 py-2 bg-slate-950 border border-slate-800 rounded-lg text-slate-100 text-sm focus:outline-none focus:border-indigo-500 font-mono"
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
                {submitting ? 'Sauvegarde...' : editingTeam ? 'Enregistrer' : 'Créer l\'équipe'}
              </button>
            </div>
          </form>
        </div>
      )}

      {/* Modal Gestion des Membres d'Équipe */}
      {selectedTeamForMembers && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/70 backdrop-blur-sm p-4">
          <div className="bg-slate-900 border border-slate-800 rounded-xl max-w-lg w-full p-6 space-y-4 shadow-2xl">
            <div className="flex items-center justify-between border-b border-slate-800 pb-3">
              <div>
                <h3 className="text-lg font-bold text-white">Membres — {selectedTeamForMembers.name}</h3>
                <p className="text-xs text-slate-400 mt-0.5">Utilisateurs affectés aux réservations d'équipe.</p>
              </div>
              <button type="button" onClick={() => setSelectedTeamForMembers(null)} className="text-slate-400 hover:text-white">✕</button>
            </div>

            {/* Formulaire Ajout Membre */}
            <form onSubmit={handleAddMember} className="flex gap-2">
              <input
                type="text"
                value={newMemberUserId}
                onChange={(e) => setNewMemberUserId(e.target.value)}
                placeholder="identity_user:user_01..."
                required
                className="flex-1 px-3 py-1.5 bg-slate-950 border border-slate-800 rounded-lg text-slate-100 text-xs font-mono"
              />
              <select
                value={newMemberRole}
                onChange={(e) => setNewMemberRole(e.target.value as 'owner' | 'admin' | 'member')}
                className="px-3 py-1.5 bg-slate-950 border border-slate-800 rounded-lg text-slate-100 text-xs"
              >
                <option value="member">Membre</option>
                <option value="admin">Admin</option>
                <option value="owner">Owner</option>
              </select>
              <button
                type="submit"
                disabled={addingMember}
                className="px-3 py-1.5 bg-indigo-600 hover:bg-indigo-500 text-white font-semibold text-xs rounded-lg shadow-sm disabled:opacity-50"
              >
                + Ajouter
              </button>
            </form>

            {/* Liste des Membres */}
            <div className="space-y-2 max-h-60 overflow-y-auto pr-1">
              {loadingMembers ? (
                <p className="text-xs text-slate-400 text-center py-4">Chargement des membres...</p>
              ) : members.length === 0 ? (
                <p className="text-xs text-slate-500 italic text-center py-4">Aucun membre rattaché.</p>
              ) : (
                members.map((m) => (
                  <div key={m.user_id} className="p-3 bg-slate-950/60 border border-slate-800 rounded-lg flex items-center justify-between">
                    <div>
                      <p className="text-xs font-mono font-bold text-slate-200">{m.user_id}</p>
                      <span className="text-[10px] text-indigo-400 uppercase font-semibold">{m.role}</span>
                    </div>
                    <button
                      onClick={() => handleRemoveMember(m.user_id)}
                      className="px-2 py-1 bg-rose-950/40 hover:bg-rose-900/60 text-rose-300 border border-rose-500/30 text-[10px] font-semibold rounded"
                    >
                      Retirer
                    </button>
                  </div>
                ))
              )}
            </div>

            <div className="flex justify-end pt-3 border-t border-slate-800">
              <button
                type="button"
                onClick={() => setSelectedTeamForMembers(null)}
                className="px-4 py-1.5 bg-slate-800 hover:bg-slate-700 text-slate-300 font-semibold text-xs rounded-lg"
              >
                Fermer
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
