import { create } from 'zustand';
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
export const useStudioState = create((set, get) => ({
    state: {},
    /**
     * Définit une valeur dans le state
     * Supporte les chemins imbriqués via "key.subkey"
     */
    setValue: (key, value) => {
        set((current) => {
            const keys = key.split('.');
            const newState = { ...current.state };
            // Créer l'objet imbriqué si nécessaire
            let target = newState;
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
    getValue: (key) => {
        const state = get().state;
        const keys = key.split('.');
        let value = state;
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
    setState: (newState) => {
        set({ state: newState });
    },
    /**
     * Réinitialise le state
     */
    reset: () => {
        set({ state: {} });
    },
}));
