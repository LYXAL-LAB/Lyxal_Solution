import type { StudioComponentStructure } from '../types/component';
/**
 * Structure d'une page complète depuis SurrealDB
 */
export interface StudioPage {
    id: string;
    identity: {
        code: string;
        slug: string;
        value: string;
    };
    presentation: {
        title_i18n?: string;
        description_i18n?: string;
        url: string;
        layout: string;
        breadcrumb?: any[];
    };
    content_structure?: StudioComponentStructure;
    context: {
        permissions?: string[];
        modules?: string[];
    };
    status: {
        is_active: boolean;
        is_system_page: boolean;
    };
    [key: string]: any;
}
/**
 * Résultat du hook useStudioPage
 */
export interface UseStudioPageResult {
    page: StudioPage | null;
    loading: boolean;
    error: Error | null;
    refetch: () => void;
}
/**
 * Hook pour charger une page depuis SurrealDB
 *
 * Charge la page studio_page depuis la base de données
 * avec sa structure complète content_structure.
 *
 * @param code - Code de la page (ex: "test_page")
 * @returns Objet contenant la page, loading, error et refetch
 *
 * @example
 * ```tsx
 * const { page, loading, error } = useStudioPage('test_page');
 *
 * if (loading) return <div>Loading...</div>;
 * if (error) return <div>Error: {error.message}</div>;
 * if (!page) return null;
 *
 * // Utiliser page.content_structure pour rendre
 * ```
 */
export declare const useStudioPage: (code: string) => UseStudioPageResult;
