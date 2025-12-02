import { StudioRoute, RouteGuardContext } from '../types/route';
/**
 * Résultat du hook useRouteGuard
 */
export interface UseRouteGuardResult {
    isAllowed: boolean | null;
    loading: boolean;
    error: string | null;
    redirectTo?: string;
}
/**
 * Hook pour vérifier les guards d'une route
 *
 * @param route Route à vérifier
 * @param context Contexte d'exécution des guards
 * @returns État de validation des guards
 */
export declare const useRouteGuard: (route: StudioRoute | null, context: RouteGuardContext) => UseRouteGuardResult;
