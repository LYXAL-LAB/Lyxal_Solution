/**
 * 🏛️ LYXAL WORKSPACE — Premier Écran Vertical Complet : Users & Settings
 * 
 * Cet écran consomme EXCLUSIVEMENT le SDK Client typé (usersClient.ts), sans aucun
 * appel fetch HTTP direct dans le composant UI.
 */

import React, { useEffect, useState } from 'react';
import { usersClient } from '../../sdk/users/users.client';
import { UserProfileResponse } from '../../sdk/users/users.types';
import { useToast } from '../../components/Toast';
import { ApiError } from '../../sdk/client';

export const UserSettingsPage: React.FC = () => {
  const { addToast } = useToast();
  const [profile, setProfile] = useState<UserProfileResponse | null>(null);
  const [loading, setLoading] = useState<boolean>(true);
  const [savingProfile, setSavingProfile] = useState<boolean>(false);
  const [savingTz, setSavingTz] = useState<boolean>(false);
  const [uploadingAvatar, setUploadingAvatar] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);

  // Champs de formulaire local
  const [name, setName] = useState<string>('');
  const [bookingEmail, setBookingEmail] = useState<string>('');
  const [timeZone, setTimeZone] = useState<string>('UTC');

  const timezonesList = [
    'UTC',
    'Europe/Paris',
    'Europe/London',
    'America/New_York',
    'America/Los_Angeles',
    'Asia/Tokyo',
    'Australia/Sydney',
  ];

  // Charge le profil via le SDK au montage du composant
  const loadProfile = async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await usersClient.getProfile();
      setProfile(data);
      setName(data.name || '');
      setBookingEmail(data.booking_email || '');
      setTimeZone(data.time_zone || 'UTC');
    } catch (err: unknown) {
      const msg = err instanceof ApiError ? err.message : 'Erreur de chargement du profil';
      setError(msg);
      addToast('error', 'Échec du chargement', msg);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadProfile();
  }, []);

  // Soumission de la mise à jour du profil via SDK
  const handleProfileSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSavingProfile(true);
    try {
      const updated = await usersClient.updateProfile({
        name,
        booking_email: bookingEmail || null,
      });
      setProfile(updated);
      addToast('success', 'Profil mis à jour', 'Vos informations ont été enregistrées avec succès.');
    } catch (err: unknown) {
      const msg = err instanceof ApiError ? err.message : 'Impossible de sauvegarder le profil';
      addToast('error', 'Erreur de sauvegarde', msg);
    } finally {
      setSavingProfile(false);
    }
  };

  // Soumission du changement de fuseau horaire via SDK
  const handleTimezoneSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSavingTz(true);
    try {
      await usersClient.updateTimezone(timeZone);
      if (profile) {
        setProfile({ ...profile, time_zone: timeZone });
      }
      addToast('success', 'Fuseau horaire mis à jour', `Nouveau fuseau horaire : ${timeZone}`);
    } catch (err: unknown) {
      const msg = err instanceof ApiError ? err.message : 'Échec de mise à jour du fuseau horaire';
      addToast('error', 'Erreur de fuseau horaire', msg);
    } finally {
      setSavingTz(false);
    }
  };

  // Upload d'avatar via SDK
  const handleAvatarFileChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = e.target.files;
    if (!files || files.length === 0) return;

    const file = files[0];
    setUploadingAvatar(true);
    try {
      const res = await usersClient.uploadAvatar(file);
      if (profile) {
        setProfile({ ...profile, avatar_path: res.avatar_url });
      }
      addToast('success', 'Avatar mis à jour', 'Votre nouvel avatar a été importé avec succès.');
    } catch (err: unknown) {
      const msg = err instanceof ApiError ? err.message : 'Échec de l\'upload de l\'avatar';
      addToast('error', 'Erreur Avatar', msg);
    } finally {
      setUploadingAvatar(false);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[300px] text-slate-400">
        <div className="flex items-center gap-3">
          <div className="w-5 h-5 border-2 border-indigo-500 border-t-transparent rounded-full animate-spin"></div>
          <span>Chargement du profil utilisateur via SDK...</span>
        </div>
      </div>
    );
  }

  if (error && !profile) {
    return (
      <div className="p-6 bg-rose-950/40 border border-rose-500/30 rounded-xl text-rose-200">
        <h3 className="font-bold text-lg">Erreur de Récupération</h3>
        <p className="mt-2 text-sm text-rose-300">{error}</p>
        <button
          onClick={loadProfile}
          className="mt-4 px-4 py-2 bg-rose-600 hover:bg-rose-500 text-white rounded-lg text-sm font-semibold transition"
        >
          Réessayer
        </button>
      </div>
    );
  }

  return (
    <div className="space-y-8">
      {/* En-tête du Module */}
      <div>
        <h2 className="text-2xl font-bold text-white tracking-tight">Paramètres du Compte</h2>
        <p className="text-sm text-slate-400 mt-1">
          Gérez votre profil public, vos coordonnées de réservation et votre fuseau horaire par défaut.
        </p>
      </div>

      {/* Section 1 : Upload d'Avatar */}
      <div className="bg-slate-900 border border-slate-800 rounded-xl p-6 shadow-sm">
        <h3 className="text-base font-semibold text-slate-200 mb-4">Photo de Profil (Avatar)</h3>
        <div className="flex items-center gap-6">
          <div className="relative">
            {profile?.avatar_path ? (
              <img
                src={profile.avatar_path}
                alt="Avatar"
                className="w-20 h-20 rounded-full object-cover border-2 border-indigo-500/50 shadow-md"
              />
            ) : (
              <div className="w-20 h-20 rounded-full bg-indigo-950 border-2 border-indigo-600/40 flex items-center justify-center text-indigo-300 text-2xl font-bold">
                {profile?.name ? profile.name.charAt(0).toUpperCase() : 'U'}
              </div>
            )}
          </div>

          <div>
            <label className="inline-flex items-center gap-2 px-4 py-2 bg-indigo-600 hover:bg-indigo-500 text-white text-sm font-semibold rounded-lg cursor-pointer transition shadow-sm">
              {uploadingAvatar ? 'Téléversement...' : 'Changer l\'avatar'}
              <input
                type="file"
                accept="image/*"
                onChange={handleAvatarFileChange}
                disabled={uploadingAvatar}
                className="hidden"
              />
            </label>
            <p className="text-xs text-slate-400 mt-2">Format PNG, JPG ou WebP. Taille maximale 5 Mo.</p>
          </div>
        </div>
      </div>

      {/* Section 2 : Formulaire de Profil */}
      <form onSubmit={handleProfileSubmit} className="bg-slate-900 border border-slate-800 rounded-xl p-6 shadow-sm space-y-6">
        <h3 className="text-base font-semibold text-slate-200 border-b border-slate-800 pb-3">Informations Personnelles</h3>
        
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">Nom Complet</label>
            <input
              type="text"
              value={name}
              onChange={(e) => setName(e.target.value)}
              required
              className="w-full px-3.5 py-2.5 bg-slate-950 border border-slate-800 rounded-lg text-slate-100 text-sm focus:outline-none focus:border-indigo-500 transition"
              placeholder="Ex: Jean Dupont"
            />
          </div>

          <div>
            <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">Email Principal (Connexion)</label>
            <input
              type="email"
              value={profile?.email || ''}
              disabled
              className="w-full px-3.5 py-2.5 bg-slate-950/50 border border-slate-800/80 rounded-lg text-slate-400 text-sm cursor-not-allowed opacity-75"
            />
          </div>

          <div className="md:col-span-2">
            <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">
              Email de Notification de Réservation (Optionnel)
            </label>
            <input
              type="email"
              value={bookingEmail}
              onChange={(e) => setBookingEmail(e.target.value)}
              className="w-full px-3.5 py-2.5 bg-slate-950 border border-slate-800 rounded-lg text-slate-100 text-sm focus:outline-none focus:border-indigo-500 transition"
              placeholder="Ex: rdv@monentreprise.com"
            />
            <p className="text-xs text-slate-500 mt-1.5">Si renseigné, les confirmations de rendez-vous seront transmises à cette adresse.</p>
          </div>
        </div>

        <div className="flex justify-end pt-2">
          <button
            type="submit"
            disabled={savingProfile}
            className="px-5 py-2.5 bg-indigo-600 hover:bg-indigo-500 text-white font-semibold text-sm rounded-lg shadow-sm transition disabled:opacity-50"
          >
            {savingProfile ? 'Enregistrement...' : 'Enregistrer le Profil'}
          </button>
        </div>
      </form>

      {/* Section 3 : Formulaire de Fuseau Horaire */}
      <form onSubmit={handleTimezoneSubmit} className="bg-slate-900 border border-slate-800 rounded-xl p-6 shadow-sm space-y-6">
        <h3 className="text-base font-semibold text-slate-200 border-b border-slate-800 pb-3">Fuseau Horaire IANA</h3>

        <div>
          <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">Fuseau Horaire par Défaut</label>
          <select
            value={timeZone}
            onChange={(e) => setTimeZone(e.target.value)}
            className="w-full md:w-1/2 px-3.5 py-2.5 bg-slate-950 border border-slate-800 rounded-lg text-slate-100 text-sm focus:outline-none focus:border-indigo-500 transition"
          >
            {timezonesList.map((tz) => (
              <option key={tz} value={tz}>
                {tz}
              </option>
            ))}
          </select>
          <p className="text-xs text-slate-500 mt-1.5">
            Ce fuseau horaire détermine l'affichage par défaut de vos disponibilités et l'envoi de vos rappels.
          </p>
        </div>

        <div className="flex justify-end pt-2">
          <button
            type="submit"
            disabled={savingTz}
            className="px-5 py-2.5 bg-indigo-600 hover:bg-indigo-500 text-white font-semibold text-sm rounded-lg shadow-sm transition disabled:opacity-50"
          >
            {savingTz ? 'Mise à jour...' : 'Mettre à jour le Fuseau'}
          </button>
        </div>
      </form>
    </div>
  );
};
