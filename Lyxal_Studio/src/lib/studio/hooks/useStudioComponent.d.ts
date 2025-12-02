import type { StudioComponentStructure } from '../types/component';
/**
 * Structure d'un composant complet depuis SurrealDB
 */
export interface StudioComponent {
    id: string;
    identity: {
        code: string;
        slug: string;
        value: string;
    };
    structure: StudioComponentStructure;
    config: {
        category: string;
        version: string;
        props_schema: any[];
        supports_slots: boolean;
        slots: string[];
    };
    status: {
        is_active: boolean;
        is_deprecated: boolean;
        is_system_component: boolean;
        source: string;
    };
    [key: string]: any;
}
/**
 * Résultat du hook useStudioComponent
 */
export interface UseStudioComponentResult {
    component: StudioComponent | null;
    loading: boolean;
    error: Error | null;
    refetch: () => void;
}
/**
 * Hook pour charger un composant depuis SurrealDB
 *
 * Charge le composant studio_component depuis la base de données
 * et le retourne avec son état de chargement.
 *
 * @param code - Code du composant (ex: "test_button")
 * @returns Objet contenant le composant, loading, error et refetch
 *
 * @example
 * ```tsx
 * const { component, loading, error } = useStudioComponent('test_button');
 *
 * if (loading) return <div>Loading...</div>;
 * if (error) return <div>Error: {error.message}</div>;
 * if (!component) return null;
 *
 * // Utiliser component.structure pour parser
 * ```
 */
export declare const useStudioComponent: (code: string) => UseStudioComponentResult;
