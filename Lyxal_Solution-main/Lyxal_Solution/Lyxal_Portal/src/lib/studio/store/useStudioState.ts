import { create } from 'zustand';

/**
 * Interface pour le state global du Studio Runtime
 */
interface StudioState {
  state: Record<string, any>;
  setValue: (key: string, value: any) => void;
  getValue: (key: string) => any;
  setState: (newState: Record<string, any>) => void;
  reset: () => void;
}

/**
 * Store global pour gérer le state des composants Studio
 * 
 * Permet aux composants générés depuis la DB de partager un state global
 * et de réagir dynamiquement aux entrées utilisateur.
 * 
 * @example
 * ```tsx
 * const { state, setValue } = useStudioState();
 * setValue('search', 'query');
 * const searchValue = state.search; // "query"
 * ```
 */
export const useStudioState = create<StudioState>((set: any, get: any) => ({
  state: {},

  /**
   * Définit une valeur dans le state
   * Supporte les chemins imbriqués via "key.subkey"
   */
  setValue: (key: string, value: any) => {
    set((current: StudioState) => {
      const keys = key.split('.');
      const newState = { ...current.state };

      // Créer l'objet imbriqué si nécessaire
      let target: any = newState;
      for (let i = 0; i < keys.length - 1; i++) {
        const k = keys[i];
        if (!target[k] || typeof target[k] !== 'object') {
          target[k] = {};
        }
        target = target[k];
      }

      // Définir la valeur finale
      target[keys[keys.length - 1]] = value;

      return { state: newState };
    });
  },

  /**
   * Récupère une valeur depuis le state
   * Supporte les chemins imbriqués via "key.subkey"
   */
  getValue: (key: string) => {
    const state = get().state;
    const keys = key.split('.');
    let value: any = state;

    for (const k of keys) {
      value = value?.[k];
      if (value === undefined || value === null) {
        break;
      }
    }

    return value;
  },

  /**
   * Remplace complètement le state
   */
  setState: (newState: Record<string, any>) => {
    set({ state: newState });
  },

  /**
   * Réinitialise le state
   */
  reset: () => {
    set({ state: {} });
  },
}));

