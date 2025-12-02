import { useState, useEffect, useCallback } from 'react';
import { PermissionChecker } from '../routes/utils/permissionChecker';
/**
 * Hook pour vérifier les permissions d'accès à une route
 *
 * @param route Route à vérifier
 * @param user Profil utilisateur (optionnel)
 * @param requireAll Si true, nécessite toutes les permissions (AND), sinon au moins une (OR)
 * @returns État des permissions
 */
export const useRoutePermissions = (route, user, requireAll = false) => {
    const [hasPermission, setHasPermission] = useState(false);
    const [loading, setLoading] = useState(true);
    const [missingPermissions, setMissingPermissions] = useState([]);
    const [userPermissions, setUserPermissions] = useState([]);
    const [error, setError] = useState();
    // Fonction pour vérifier les permissions
    const checkPermissions = useCallback(async () => {
        try {
            setLoading(true);
            setError(undefined);
            if (!route) {
                setHasPermission(false);
                setMissingPermissions([]);
                setUserPermissions([]);
                return;
            }
            console.log(`[useRoutePermissions] 🔍 Checking permissions for route: ${route.identity.value}`);
            console.log(`[useRoutePermissions] 📋 Required permissions:`, route.permissions);
            // Utiliser PermissionChecker pour valider
            const result = PermissionChecker.checkRoutePermissions({
                user,
                routePermissions: route.permissions,
                requireAll
            });
            console.log(`[useRoutePermissions] ✅ Permission check result:`, {
                granted: result.granted,
                userPermissions: result.userPermissions,
                missingPermissions: result.missingPermissions
            });
            setHasPermission(result.granted);
            setMissingPermissions(result.missingPermissions);
            setUserPermissions(result.userPermissions);
        }
        catch (err) {
            const errorMessage = err instanceof Error ? err.message : 'Permission check failed';
            console.error('[useRoutePermissions] Error:', errorMessage);
            setError(errorMessage);
            setHasPermission(false);
            setMissingPermissions(route?.permissions || []);
            setUserPermissions([]);
        }
        finally {
            setLoading(false);
        }
    }, [route, user, requireAll]);
    // Ré-exécuter quand les dépendances changent
    useEffect(() => {
        checkPermissions();
    }, [checkPermissions]);
    return {
        hasPermission,
        loading,
        missingPermissions,
        userPermissions,
        error
    };
};
