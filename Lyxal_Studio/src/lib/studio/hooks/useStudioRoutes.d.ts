import { StudioRoute } from '../types/route';
/**
 * Résultat du hook useStudioRoutes
 */
export interface UseStudioRoutesResult {
    routes: StudioRoute[];
    loading: boolean;
    error: string | null;
    refetch: () => Promise<void>;
}
/**
 * Hook pour charger et gérer les routes dynamiques
 *
 * @param options Options de chargement
 * @returns État des routes et fonctions de contrôle
 */
export declare const useStudioRoutes: (options?: {
    forceRefresh?: boolean;
    backgroundLoad?: boolean;
}) => UseStudioRoutesResult;
