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
export declare const useStudioState: import("zustand").UseBoundStore<import("zustand").StoreApi<StudioState>>;
export {};
