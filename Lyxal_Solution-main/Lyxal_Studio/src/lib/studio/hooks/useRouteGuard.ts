import { useState, useEffect, useCallback } from 'react';
import { StudioRoute, RouteGuardContext } from '../types/route';
import { executeGuard } from '../routes/guards';

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
export const useRouteGuard = (
  route: StudioRoute | null,
  context: RouteGuardContext
): UseRouteGuardResult => {
  const [isAllowed, setIsAllowed] = useState<boolean | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [redirectTo, setRedirectTo] = useState<string | undefined>();

  // Fonction pour exécuter les guards
  const checkGuards = useCallback(async () => {
    if (!route || !route.guards || route.guards.length === 0) {
      setIsAllowed(true);
      setLoading(false);
      return;
    }

    try {
      setLoading(true);
      setError(null);
      setRedirectTo(undefined);

      console.log(`[useRouteGuard] 🔍 Checking ${route.guards.length} guards for route: ${route.identity.value}`);

      // Exécuter tous les guards
      for (const guard of route.guards) {
        console.log(`[useRouteGuard] 🛡️ Executing guard: ${guard.type}`);

        const result = await executeGuard(guard, context);

        if (!result.success) {
          console.log(`[useRouteGuard] ❌ Guard failed: ${guard.type}`);
          setIsAllowed(false);
          setError(result.error || `Guard ${guard.type} failed`);
          setRedirectTo(result.redirectTo);
          return;
        }

        console.log(`[useRouteGuard] ✅ Guard passed: ${guard.type}`);
      }

      // Tous les guards ont réussi
      console.log(`[useRouteGuard] ✅ All guards passed for route: ${route.identity.value}`);
      setIsAllowed(true);

    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Guard execution failed';
      console.error('[useRouteGuard] Error:', errorMessage);
      setError(errorMessage);
      setIsAllowed(false);
    } finally {
      setLoading(false);
    }
  }, [route, context]);

  // Ré-exécuter quand la route ou le contexte change
  useEffect(() => {
    checkGuards();
  }, [checkGuards]);

  return {
    isAllowed,
    loading,
    error,
    redirectTo
  };
};
