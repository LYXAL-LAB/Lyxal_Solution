/**
 * 🏛️ LYXAL WORKSPACE — Écran Complet du Module 07 : Availability
 * 
 * Cet écran consomme EXCLUSIVEMENT le SDK Client typé (availabilityClient.ts), sans aucun
 * appel fetch HTTP direct dans le composant UI.
 */

import React, { useEffect, useState } from 'react';
import { availabilityClient } from '../../sdk/availability/availability.client';
import {
  AvailabilityScheduleRule,
  AvailabilitySlotResponse,
  AvailabilityOverrideResponse,
} from '../../sdk/availability/availability.types';
import { useToast } from '../../components/Toast';
import { ApiError } from '../../sdk/client';

const DAYS_NAMES = ['Dimanche', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'];

export const AvailabilityPage: React.FC = () => {
  const { addToast } = useToast();
  const [loading, setLoading] = useState<boolean>(true);
  const [saving, setSaving] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);

  // Planning hebdomadaire
  const [scheduleName, setScheduleName] = useState<string>('Horaires de Travail Standard');
  const [timeZone, setTimeZone] = useState<string>('Europe/Paris');
  const [isDefault, setIsDefault] = useState<boolean>(true);
  const [rules, setRules] = useState<AvailabilityScheduleRule[]>([
    { day_of_week: 1, start_time: '09:00', end_time: '17:00' },
    { day_of_week: 2, start_time: '09:00', end_time: '17:00' },
    { day_of_week: 3, start_time: '09:00', end_time: '17:00' },
    { day_of_week: 4, start_time: '09:00', end_time: '17:00' },
    { day_of_week: 5, start_time: '09:00', end_time: '17:00' },
  ]);

  // Test du calculateur de créneaux libres
  const [testSlug, setTestSlug] = useState<string>('consultation-30min');
  const [testDateFrom, setTestDateFrom] = useState<string>(new Date().toISOString().split('T')[0]);
  const [testDateTo, setTestDateTo] = useState<string>(
    new Date(Date.now() + 7 * 86400000).toISOString().split('T')[0]
  );
  const [computedSlots, setComputedSlots] = useState<AvailabilitySlotResponse[]>([]);
  const [calculatingSlots, setCalculatingSlots] = useState<boolean>(false);

  // Exceptions ponctuelles (Overrides)
  const [overrides, setOverrides] = useState<AvailabilityOverrideResponse[]>([]);
  const [overrideDate, setOverrideDate] = useState<string>('');
  const [overrideUnavailable, setOverrideUnavailable] = useState<boolean>(true);
  const [addingOverride, setAddingOverride] = useState<boolean>(false);

  // Charge les plannings et les overrides enregistrés via le SDK Client
  const loadSchedules = async () => {
    setLoading(true);
    setError(null);
    try {
      const [schedules, ovs] = await Promise.all([
        availabilityClient.getSchedules(),
        availabilityClient.getOverrides(),
      ]);
      setOverrides(ovs);
      if (schedules.length > 0) {
        const defaultSched = schedules[0];
        setScheduleName(defaultSched.name);
        setTimeZone(defaultSched.time_zone);
        setIsDefault(defaultSched.is_default);
        if (defaultSched.rules && defaultSched.rules.length > 0) {
          setRules(defaultSched.rules);
        }
      }
    } catch (err: unknown) {
      const msg = err instanceof ApiError ? err.message : 'Échec du chargement des plannings d\'ouverture';
      setError(msg);
    } finally {
      setLoading(false);
    }
  };

  const handleSaveOverride = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!overrideDate) return;
    setAddingOverride(true);
    try {
      const created = await availabilityClient.saveOverride({
        date: overrideDate,
        unavailable: overrideUnavailable,
      });
      setOverrides((prev) => [...prev.filter((o) => o.date !== created.date), created]);
      setOverrideDate('');
      addToast('success', 'Exception Ajoutée', `Exception enregistrée pour le ${created.date}.`);
    } catch (err: unknown) {
      const msg = err instanceof ApiError ? err.message : 'Erreur lors de l\'ajout de l\'exception';
      addToast('error', 'Erreur Exception', msg);
    } finally {
      setAddingOverride(false);
    }
  };

  const handleDeleteOverride = async (id: string) => {
    try {
      await availabilityClient.deleteOverride(id);
      setOverrides((prev) => prev.filter((o) => o.id !== id));
      addToast('success', 'Exception Retirée', 'L\'exception ponctuelle a été supprimée.');
    } catch (err: unknown) {
      const msg = err instanceof ApiError ? err.message : 'Erreur de suppression de l\'exception';
      addToast('error', 'Erreur Exception', msg);
    }
  };

  useEffect(() => {
    loadSchedules();
  }, []);

  // Modification d'une règle hebdomadaire
  const handleRuleChange = (dayIndex: number, field: 'enabled' | 'start' | 'end', val?: string) => {
    setRules((prev) => {
      const existing = prev.find((r) => r.day_of_week === dayIndex);
      if (field === 'enabled') {
        if (existing) {
          return prev.filter((r) => r.day_of_week !== dayIndex);
        } else {
          return [...prev, { day_of_week: dayIndex, start_time: '09:00', end_time: '17:00' }];
        }
      } else if (existing) {
        return prev.map((r) =>
          r.day_of_week === dayIndex
            ? {
                ...r,
                start_time: field === 'start' ? val || r.start_time : r.start_time,
                end_time: field === 'end' ? val || r.end_time : r.end_time,
              }
            : r
        );
      }
      return prev;
    });
  };

  // Enregistrement du planning via SDK Client
  const handleSaveSchedule = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);
    try {
      await availabilityClient.saveSchedule({
        name: scheduleName,
        time_zone: timeZone,
        is_default: isDefault,
        rules,
      });
      addToast('success', 'Planning Enregistré', 'Vos heures d\'ouverture ont été mises à jour avec succès.');
    } catch (err: unknown) {
      const msg = err instanceof ApiError ? err.message : 'Erreur lors de l\'enregistrement du planning';
      addToast('error', 'Erreur de Sauvegarde', msg);
    } finally {
      setSaving(false);
    }
  };

  // Calcul des créneaux libres via SDK Client
  const handleCalculateSlots = async () => {
    setCalculatingSlots(true);
    try {
      const res = await availabilityClient.getAvailableSlots({
        event_type_slug: testSlug,
        date_from: testDateFrom,
        date_to: testDateTo,
        time_zone: timeZone,
      });
      setComputedSlots(res.slots);
      addToast('success', 'Calcul Terminé', `${res.slots.length} créneau(x) libre(s) généré(s).`);
    } catch (err: unknown) {
      const msg = err instanceof ApiError ? err.message : 'Échec du calcul des créneaux libres';
      addToast('error', 'Erreur Calcul Slots', msg);
    } finally {
      setCalculatingSlots(false);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[300px] text-slate-400">
        <div className="flex items-center gap-3">
          <div className="w-5 h-5 border-2 border-indigo-500 border-t-transparent rounded-full animate-spin"></div>
          <span>Chargement du moteur de disponibilité via SDK...</span>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-8">
      {/* En-tête avec Actions */}
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-2xl font-bold text-white tracking-tight">Disponibilités & Heures d'Ouverture</h2>
          <p className="text-sm text-slate-400 mt-1">
            Définissez vos créneaux de travail récurrents et simulez les fenêtres de réservation libres.
          </p>
        </div>
      </div>

      {error && (
        <div className="p-4 bg-rose-950/40 border border-rose-500/30 rounded-xl text-rose-200 text-sm">
          <p>{error}</p>
        </div>
      )}

      {/* Grille Principale : Planning + Simulateur */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Colonne 1 & 2 : Configuration du Planning */}
        <form onSubmit={handleSaveSchedule} className="lg:col-span-2 space-y-6 bg-slate-900 border border-slate-800 rounded-xl p-6 shadow-sm">
          <div className="flex items-center justify-between border-b border-slate-800 pb-4">
            <div>
              <h3 className="text-lg font-bold text-white">Planning d'Ouverture Récurrent</h3>
              <p className="text-xs text-slate-400 mt-0.5">Plages horaires durant lesquelles vous acceptez des rendez-vous.</p>
            </div>
            <button
              type="submit"
              disabled={saving}
              className="px-4 py-2 bg-indigo-600 hover:bg-indigo-500 text-white font-semibold text-xs rounded-lg shadow-sm disabled:opacity-50 transition"
            >
              {saving ? 'Sauvegarde...' : 'Enregistrer le Planning'}
            </button>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1">Nom du planning</label>
              <input
                type="text"
                value={scheduleName}
                onChange={(e) => setScheduleName(e.target.value)}
                required
                className="w-full px-3.5 py-2 bg-slate-950 border border-slate-800 rounded-lg text-slate-100 text-sm focus:outline-none focus:border-indigo-500"
              />
            </div>

            <div>
              <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1">Fuseau horaire (Timezone IANA)</label>
              <select
                value={timeZone}
                onChange={(e) => setTimeZone(e.target.value)}
                className="w-full px-3.5 py-2 bg-slate-950 border border-slate-800 rounded-lg text-slate-100 text-sm"
              >
                <option value="Europe/Paris">Europe/Paris (UTC+1/+2)</option>
                <option value="Europe/London">Europe/London (UTC+0/+1)</option>
                <option value="America/New_York">America/New_York (EST)</option>
                <option value="UTC">UTC (Temps Universel)</option>
              </select>
            </div>
          </div>

          {/* Grille Hebdomadaire Jour par Jour */}
          <div className="space-y-3 pt-2">
            <h4 className="text-xs font-bold text-slate-300 uppercase tracking-wider">Jours de la semaine</h4>
            {DAYS_NAMES.map((dayName, index) => {
              const rule = rules.find((r) => r.day_of_week === index);
              const enabled = !!rule;

              return (
                <div key={index} className="flex items-center justify-between p-3 bg-slate-950/60 border border-slate-800 rounded-lg">
                  <div className="flex items-center gap-3 w-36">
                    <input
                      type="checkbox"
                      checked={enabled}
                      onChange={() => handleRuleChange(index, 'enabled')}
                      className="w-4 h-4 rounded border-slate-700 bg-slate-900 text-indigo-600 focus:ring-0 cursor-pointer"
                    />
                    <span className={`text-sm font-semibold ${enabled ? 'text-white' : 'text-slate-500'}`}>{dayName}</span>
                  </div>

                  {enabled ? (
                    <div className="flex items-center gap-2">
                      <input
                        type="time"
                        value={rule.start_time}
                        onChange={(e) => handleRuleChange(index, 'start', e.target.value)}
                        className="px-2.5 py-1 bg-slate-900 border border-slate-800 rounded text-slate-100 text-xs font-mono"
                      />
                      <span className="text-slate-500 text-xs">à</span>
                      <input
                        type="time"
                        value={rule.end_time}
                        onChange={(e) => handleRuleChange(index, 'end', e.target.value)}
                        className="px-2.5 py-1 bg-slate-900 border border-slate-800 rounded text-slate-100 text-xs font-mono"
                      />
                    </div>
                  ) : (
                    <span className="text-xs text-slate-600 font-medium">Non disponible</span>
                  )}
                </div>
              );
            })}
          </div>
        </form>

        {/* Colonne 3 : Simulateur de Créneaux Libres */}
        <div className="space-y-6 bg-slate-900 border border-slate-800 rounded-xl p-6 shadow-sm">
          <div className="border-b border-slate-800 pb-3">
            <h3 className="text-lg font-bold text-white">Calculateur de Créneaux</h3>
            <p className="text-xs text-slate-400 mt-0.5">Testez la génération des fenêtres disponibles en direct.</p>
          </div>

          <div className="space-y-4">
            <div>
              <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1">Slug Type d'Événement</label>
              <input
                type="text"
                value={testSlug}
                onChange={(e) => setTestSlug(e.target.value)}
                placeholder="consultation-30min"
                className="w-full px-3.5 py-2 bg-slate-950 border border-slate-800 rounded-lg text-slate-100 text-sm font-mono"
              />
            </div>

            <div className="grid grid-cols-2 gap-3">
              <div>
                <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1">Du</label>
                <input
                  type="date"
                  value={testDateFrom}
                  onChange={(e) => setTestDateFrom(e.target.value)}
                  className="w-full px-3 py-1.5 bg-slate-950 border border-slate-800 rounded-lg text-slate-100 text-xs"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1">Au</label>
                <input
                  type="date"
                  value={testDateTo}
                  onChange={(e) => setTestDateTo(e.target.value)}
                  className="w-full px-3 py-1.5 bg-slate-950 border border-slate-800 rounded-lg text-slate-100 text-xs"
                />
              </div>
            </div>

            <button
              onClick={handleCalculateSlots}
              disabled={calculatingSlots}
              className="w-full py-2.5 bg-indigo-600 hover:bg-indigo-500 text-white font-semibold text-xs rounded-lg shadow-sm disabled:opacity-50 transition"
            >
              {calculatingSlots ? 'Calcul en cours...' : '⚡ Calculer les Créneaux Libres'}
            </button>
          </div>

          {/* Résultat du Calcul */}
          <div className="space-y-2 pt-2 border-t border-slate-800">
            <h4 className="text-xs font-semibold text-slate-300">
              Créneaux Libres Déduits ({computedSlots.length})
            </h4>

            {computedSlots.length === 0 ? (
              <p className="text-xs text-slate-500 italic p-3 bg-slate-950/40 rounded-lg border border-slate-800 text-center">
                Cliquez sur calculer pour simuler les créneaux disponibles.
              </p>
            ) : (
              <div className="max-h-60 overflow-y-auto space-y-1.5 pr-1">
                {computedSlots.map((slot, i) => (
                  <div key={i} className="p-2 bg-slate-950 border border-slate-800 rounded flex items-center justify-between text-xs">
                    <span className="font-mono text-slate-200">
                      {new Date(slot.start_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })} -{' '}
                      {new Date(slot.end_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                    </span>
                    <span className="text-[10px] text-emerald-400 font-semibold bg-emerald-950/50 px-2 py-0.5 rounded border border-emerald-500/30">
                      Libre
                    </span>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};
