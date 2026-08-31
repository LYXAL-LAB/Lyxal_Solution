/**
 * 🏛️ LYXAL WORKSPACE — Écran Complet du Module 04 : Calendars
 * 
 * Cet écran consomme EXCLUSIVEMENT le SDK Client typé (calendarsClient.ts), sans aucun
 * appel fetch HTTP direct dans le composant UI.
 */

import React, { useEffect, useState } from 'react';
import { calendarsClient } from '../../sdk/calendars/calendars.client';
import { CalendarSourceResponse } from '../../sdk/calendars/calendars.types';
import { useToast } from '../../components/Toast';
import { ApiError } from '../../sdk/client';

export const CalendarsPage: React.FC = () => {
  const { addToast } = useToast();
  const [sources, setSources] = useState<CalendarSourceResponse[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  // Formulaire d'ajout CalDAV / EWS / ICS
  const [showAddModal, setShowAddModal] = useState<boolean>(false);
  const [creating, setCreating] = useState<boolean>(false);
  const [name, setName] = useState<string>('');
  const [providerType, setProviderType] = useState<string>('caldav');
  const [authType, setAuthType] = useState<string>('basic');
  const [serverUrl, setServerUrl] = useState<string>('');
  const [username, setUsername] = useState<string>('');
  const [secret, setSecret] = useState<string>('');

  // États d'action sur une source
  const [syncingId, setSyncingId] = useState<string | null>(null);
  const [deletingId, setDeletingId] = useState<string | null>(null);

  // Sélection du calendrier d'écriture
  const [writeCalendarModalSource, setWriteCalendarModalSource] = useState<CalendarSourceResponse | null>(null);
  const [calendarHref, setCalendarHref] = useState<string>('');
  const [savingWriteCalendar, setSavingWriteCalendar] = useState<boolean>(false);

  // Charge la liste des sources distantes via le SDK
  const loadSources = async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await calendarsClient.listSources();
      setSources(data);
    } catch (err: unknown) {
      const msg = err instanceof ApiError ? err.message : 'Échec du chargement des sources de calendriers';
      setError(msg);
      addToast('error', 'Erreur Calendriers', msg);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    const urlParams = new URLSearchParams(window.location.search);
    const oauthStatus = urlParams.get('oauth');

    if (oauthStatus === 'success') {
      addToast('success', 'Google Calendar Connecté', 'Votre compte Google Calendar a été lié avec succès !');
      window.history.replaceState({}, document.title, window.location.pathname);
    } else if (oauthStatus === 'error') {
      addToast('error', 'Échec OAuth Google', 'L\'autorisation OAuth2 Google a été annulée ou a échoué.');
      window.history.replaceState({}, document.title, window.location.pathname);
    }

    loadSources();
  }, []);

  // Création d'une nouvelle source CalDAV/EWS/ICS via SDK
  const handleCreateSourceSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setCreating(true);
    try {
      const newSource = await calendarsClient.createSource({
        name,
        provider_type: providerType,
        auth_type: authType,
        server_url: serverUrl || null,
        username: username || null,
        secret: secret || null,
      });
      setSources((prev) => [...prev, newSource]);
      setShowAddModal(false);
      setName('');
      setServerUrl('');
      setUsername('');
      setSecret('');
      addToast('success', 'Source ajoutée', `Source "${newSource.name}" configurée avec succès.`);
    } catch (err: unknown) {
      const msg = err instanceof ApiError ? err.message : 'Impossible de créer la source';
      addToast('error', 'Erreur de création', msg);
    } finally {
      setCreating(false);
    }
  };

  // Connexion Google OAuth2 via SDK
  const handleConnectGoogle = async () => {
    try {
      const res = await calendarsClient.getGoogleOAuthUrl();
      addToast('info', 'Redirection Google OAuth2', 'Redirection vers la page de consentement Google...');
      window.location.href = res.auth_url;
    } catch (err: unknown) {
      const msg = err instanceof ApiError ? err.message : 'Échec de connexion OAuth Google';
      addToast('error', 'OAuth Google', msg);
    }
  };

  // Synchronisation manuelle via SDK
  const handleSyncSource = async (id: string) => {
    setSyncingId(id);
    try {
      const res = await calendarsClient.syncSource(id);
      addToast(
        res.success ? 'success' : 'warning',
        'Synchronisation Terminée',
        `${res.synced_events_count} événement(s) synchronisé(s).`
      );
      loadSources();
    } catch (err: unknown) {
      const msg = err instanceof ApiError ? err.message : 'Échec de la synchronisation';
      addToast('error', 'Erreur Sync', msg);
    } finally {
      setSyncingId(null);
    }
  };

  // Suppression d'une source via SDK
  const handleDeleteSource = async (id: string) => {
    if (!confirm('Voulez-vous vraiment supprimer cette source de calendrier ?')) return;
    setDeletingId(id);
    try {
      await calendarsClient.deleteSource(id);
      setSources((prev) => prev.filter((s) => s.id !== id));
      addToast('success', 'Source supprimée', 'La source de calendrier a été retirée.');
    } catch (err: unknown) {
      const msg = err instanceof ApiError ? err.message : 'Échec de la suppression';
      addToast('error', 'Erreur Suppression', msg);
    } finally {
      setDeletingId(null);
    }
  };

  // Enregistrement du calendrier d'écriture via SDK
  const handleSaveWriteCalendar = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!writeCalendarModalSource) return;
    setSavingWriteCalendar(true);
    try {
      await calendarsClient.setWriteCalendar(writeCalendarModalSource.id, calendarHref);
      addToast('success', 'Calendrier d\'écriture défini', `Calendrier d'écriture mis à jour pour ${writeCalendarModalSource.name}`);
      setWriteCalendarModalSource(null);
      setCalendarHref('');
    } catch (err: unknown) {
      const msg = err instanceof ApiError ? err.message : 'Échec de configuration du calendrier d\'écriture';
      addToast('error', 'Erreur Calendrier Écriture', msg);
    } finally {
      setSavingWriteCalendar(false);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[300px] text-slate-400">
        <div className="flex items-center gap-3">
          <div className="w-5 h-5 border-2 border-indigo-500 border-t-transparent rounded-full animate-spin"></div>
          <span>Chargement des sources de calendrier via SDK...</span>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-8">
      {/* En-tête avec Actions */}
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-2xl font-bold text-white tracking-tight">Sources de Calendrier</h2>
          <p className="text-sm text-slate-400 mt-1">
            Connectez vos agendas distants (CalDAV, EWS, Google Calendar) pour la détection automatique de conflits.
          </p>
        </div>
        <div className="flex items-center gap-3">
          <button
            onClick={handleConnectGoogle}
            className="flex items-center gap-2 px-4 py-2.5 bg-slate-900 hover:bg-slate-800 border border-slate-700 text-white font-semibold text-sm rounded-lg shadow-sm transition"
          >
            <span>🌐</span>
            <span>Connecter Google</span>
          </button>
          <button
            onClick={() => setShowAddModal(true)}
            className="flex items-center gap-2 px-4 py-2.5 bg-indigo-600 hover:bg-indigo-500 text-white font-semibold text-sm rounded-lg shadow-sm transition"
          >
            <span>+</span>
            <span>Ajouter CalDAV / EWS</span>
          </button>
        </div>
      </div>

      {/* Message d'Erreur si besoin */}
      {error && (
        <div className="p-4 bg-rose-950/40 border border-rose-500/30 rounded-xl text-rose-200 text-sm">
          <p>{error}</p>
        </div>
      )}

      {/* Liste des Sources Connected */}
      <div className="bg-slate-900 border border-slate-800 rounded-xl overflow-hidden shadow-sm">
        <div className="p-4 border-b border-slate-800 bg-slate-950/40 flex items-center justify-between">
          <h3 className="text-sm font-semibold text-slate-300">Sources Connectées ({sources.length})</h3>
        </div>

        {sources.length === 0 ? (
          <div className="p-8 text-center text-slate-400">
            <p className="text-base font-medium text-slate-300">Aucune source de calendrier configurée</p>
            <p className="text-xs text-slate-500 mt-1">Ajoutez un serveur CalDAV, EWS ou connectez votre compte Google.</p>
          </div>
        ) : (
          <div className="divide-y divide-slate-800">
            {sources.map((s) => (
              <div key={s.id} className="p-4 sm:p-5 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 hover:bg-slate-800/30 transition">
                <div className="flex items-center gap-4">
                  <div className="w-10 h-10 rounded-lg bg-indigo-950 border border-indigo-500/30 flex items-center justify-center text-lg">
                    {s.provider_type === 'google' ? '🌐' : s.provider_type === 'ews' ? '📧' : '📅'}
                  </div>
                  <div>
                    <div className="flex items-center gap-2">
                      <h4 className="font-bold text-slate-100 text-base">{s.name}</h4>
                      <span
                        className={`px-2 py-0.5 rounded-full text-[10px] font-semibold uppercase tracking-wider ${
                          s.status === 'active'
                            ? 'bg-emerald-950 text-emerald-400 border border-emerald-500/30'
                            : 'bg-amber-950 text-amber-400 border border-amber-500/30'
                        }`}
                      >
                        {s.status}
                      </span>
                    </div>
                    <p className="text-xs text-slate-400 mt-0.5">
                      Type: <span className="uppercase text-slate-300">{s.provider_type}</span> ({s.auth_type})
                      {s.server_url && ` — ${s.server_url}`}
                    </p>
                  </div>
                </div>

                <div className="flex items-center gap-2 w-full sm:w-auto justify-end">
                  <button
                    onClick={() => {
                      setWriteCalendarModalSource(s);
                      setCalendarHref(s.server_url || '');
                    }}
                    className="px-3 py-1.5 bg-slate-800 hover:bg-slate-700 text-slate-200 text-xs font-semibold rounded-md border border-slate-700 transition"
                  >
                    Sélectionner Écriture
                  </button>

                  <button
                    onClick={() => handleSyncSource(s.id)}
                    disabled={syncingId === s.id}
                    className="px-3 py-1.5 bg-indigo-600/20 hover:bg-indigo-600/30 text-indigo-300 border border-indigo-500/30 text-xs font-semibold rounded-md transition disabled:opacity-50"
                  >
                    {syncingId === s.id ? 'Sync...' : 'Synchroniser'}
                  </button>

                  <button
                    onClick={() => handleDeleteSource(s.id)}
                    disabled={deletingId === s.id}
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

      {/* Modal d'ajout de source CalDAV / EWS */}
      {showAddModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/70 backdrop-blur-sm p-4">
          <form onSubmit={handleCreateSourceSubmit} className="bg-slate-900 border border-slate-800 rounded-xl max-w-lg w-full p-6 space-y-5 shadow-2xl">
            <div className="flex items-center justify-between border-b border-slate-800 pb-3">
              <h3 className="text-lg font-bold text-white">Ajouter une Source de Calendrier</h3>
              <button type="button" onClick={() => setShowAddModal(false)} className="text-slate-400 hover:text-white">✕</button>
            </div>

            <div className="space-y-4">
              <div>
                <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1">Nom de la source</label>
                <input
                  type="text"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  required
                  placeholder="Ex: Mon Agenda Pro Nextcloud"
                  className="w-full px-3.5 py-2 bg-slate-950 border border-slate-800 rounded-lg text-slate-100 text-sm focus:outline-none focus:border-indigo-500"
                />
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1">Provider</label>
                  <select
                    value={providerType}
                    onChange={(e) => setProviderType(e.target.value)}
                    className="w-full px-3.5 py-2 bg-slate-950 border border-slate-800 rounded-lg text-slate-100 text-sm"
                  >
                    <option value="caldav">CalDAV</option>
                    <option value="ews">Exchange EWS</option>
                    <option value="ics">ICS Webcal</option>
                  </select>
                </div>

                <div>
                  <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1">Authentification</label>
                  <select
                    value={authType}
                    onChange={(e) => setAuthType(e.target.value)}
                    className="w-full px-3.5 py-2 bg-slate-950 border border-slate-800 rounded-lg text-slate-100 text-sm"
                  >
                    <option value="basic">Basic (User/Pass)</option>
                    <option value="oauth2">OAuth2</option>
                    <option value="none">Aucune (Lecture seule)</option>
                  </select>
                </div>
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1">URL du Serveur / Agenda</label>
                <input
                  type="url"
                  value={serverUrl}
                  onChange={(e) => setServerUrl(e.target.value)}
                  required
                  placeholder="https://caldav.exemple.com/remote.php/dav/"
                  className="w-full px-3.5 py-2 bg-slate-950 border border-slate-800 rounded-lg text-slate-100 text-sm focus:outline-none focus:border-indigo-500"
                />
              </div>

              {authType === 'basic' && (
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1">Identifiant / User</label>
                    <input
                      type="text"
                      value={username}
                      onChange={(e) => setUsername(e.target.value)}
                      required
                      placeholder="utilisateur"
                      className="w-full px-3.5 py-2 bg-slate-950 border border-slate-800 rounded-lg text-slate-100 text-sm focus:outline-none focus:border-indigo-500"
                    />
                  </div>

                  <div>
                    <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1">Mot de passe / Secret</label>
                    <input
                      type="password"
                      value={secret}
                      onChange={(e) => setSecret(e.target.value)}
                      required
                      placeholder="••••••••"
                      className="w-full px-3.5 py-2 bg-slate-950 border border-slate-800 rounded-lg text-slate-100 text-sm focus:outline-none focus:border-indigo-500"
                    />
                  </div>
                </div>
              )}
            </div>

            <div className="flex justify-end gap-3 pt-3 border-t border-slate-800">
              <button
                type="button"
                onClick={() => setShowAddModal(false)}
                className="px-4 py-2 bg-slate-800 hover:bg-slate-700 text-slate-300 font-semibold text-sm rounded-lg"
              >
                Annuler
              </button>
              <button
                type="submit"
                disabled={creating}
                className="px-5 py-2 bg-indigo-600 hover:bg-indigo-500 text-white font-semibold text-sm rounded-lg shadow-sm disabled:opacity-50"
              >
                {creating ? 'Création...' : 'Ajouter la source'}
              </button>
            </div>
          </form>
        </div>
      )}

      {/* Modal d'écriture du calendrier */}
      {writeCalendarModalSource && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/70 backdrop-blur-sm p-4">
          <form onSubmit={handleSaveWriteCalendar} className="bg-slate-900 border border-slate-800 rounded-xl max-w-md w-full p-6 space-y-4 shadow-2xl">
            <h3 className="text-lg font-bold text-white">Sélectionner le Calendrier d'Écriture</h3>
            <p className="text-xs text-slate-400">
              Les nouveaux rendez-vous acceptés seront automatiquement insérés dans cet agenda distant.
            </p>
            <div>
              <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1">HREF / URL du Calendrier</label>
              <input
                type="text"
                value={calendarHref}
                onChange={(e) => setCalendarHref(e.target.value)}
                required
                className="w-full px-3.5 py-2 bg-slate-950 border border-slate-800 rounded-lg text-slate-100 text-sm focus:outline-none focus:border-indigo-500"
              />
            </div>
            <div className="flex justify-end gap-3 pt-2">
              <button
                type="button"
                onClick={() => setWriteCalendarModalSource(null)}
                className="px-4 py-2 bg-slate-800 hover:bg-slate-700 text-slate-300 font-semibold text-sm rounded-lg"
              >
                Annuler
              </button>
              <button
                type="submit"
                disabled={savingWriteCalendar}
                className="px-5 py-2 bg-indigo-600 hover:bg-indigo-500 text-white font-semibold text-sm rounded-lg shadow-sm disabled:opacity-50"
              >
                {savingWriteCalendar ? 'Sauvegarde...' : 'Définir comme Cible'}
              </button>
            </div>
          </form>
        </div>
      )}
    </div>
  );
};
