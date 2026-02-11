import { useState, useEffect, useCallback } from 'react';
import { StudioRoute } from '../types/route';
import { routeLoader } from '../routes/registry/RouteLoader';

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
export const useStudioRoutes = (
  options: {
    forceRefresh?: boolean;
    backgroundLoad?: boolean;
  } = {}
): UseStudioRoutesResult => {
  const { forceRefresh = false, backgroundLoad = false } = options;

  const [routes, setRoutes] = useState<StudioRoute[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Fonction pour charger les routes
  const loadRoutes = useCallback(async (force = false) => {
    try {
      setLoading(true);
      setError(null);

      const result = await routeLoader.loadActiveRoutes({
        forceRefresh: force,
        backgroundLoad
      });

      if (result.error) {
        setError(result.error.message);
        setRoutes([]);
      } else {
        setRoutes(result.routes);
      }
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Failed to load routes';
      setError(errorMessage);
      setRoutes([]);
    } finally {
      setLoading(false);
    }
  }, [backgroundLoad]);

  // Fonction de rechargement manuel
  const refetch = useCallback(async () => {
    await loadRoutes(true);
  }, [loadRoutes]);

  // Chargement initial
  useEffect(() => {
    loadRoutes(forceRefresh);
  }, [loadRoutes, forceRefresh]);

  return {
    routes,
    loading,
    error,
    refetch
  };
};
