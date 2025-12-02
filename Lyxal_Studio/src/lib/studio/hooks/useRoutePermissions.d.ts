import { StudioRoute, Permission } from '../types/route';
/**
 * Résultat du hook useRoutePermissions
 */
export interface UseRoutePermissionsResult {
    hasPermission: boolean;
    loading: boolean;
    missingPermissions: Permission[];
    userPermissions: Permission[];
    error?: string;
}
/**
 * Hook pour vérifier les permissions d'accès à une route
 *
 * @param route Route à vérifier
 * @param user Profil utilisateur (optionnel)
 * @param requireAll Si true, nécessite toutes les permissions (AND), sinon au moins une (OR)
 * @returns État des permissions
 */
export declare const useRoutePermissions: (route: StudioRoute | null, user?: any, requireAll?: boolean) => UseRoutePermissionsResult;
