import { useState, useEffect } from 'react';
import { useSystemConfig } from '@/hooks/useSystemConfig';
import { SurrealClient } from '@/services/SurrealClient';
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
export const useStudioPage = (code: string): UseStudioPageResult => {
  const { config, loading: configLoading } = useSystemConfig();
  const [page, setPage] = useState<StudioPage | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  const loadPage = async () => {
    if (!code || configLoading) {
      return;
    }

    try {
      setLoading(true);
      setError(null);

      // Requête SurrealDB pour charger la page
      const query = `
        SELECT * FROM studio_page 
        WHERE identity.code = '${code}' 
        AND status.is_active = true
        LIMIT 1
      `;

      const result = await SurrealClient.query<StudioPage[]>(config, query);

      if (result && Array.isArray(result) && result.length > 0) {
        setPage(result[0]);
      } else {
        setPage(null);
        setError(new Error(`Page '${code}' not found or inactive`));
      }
    } catch (err) {
      const error = err instanceof Error 
        ? err 
        : new Error(`Failed to load page '${code}'`);
      setError(error);
      console.error(`[useStudioPage] Failed to load page '${code}':`, err);
      setPage(null);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadPage();
  }, [code, configLoading]);

  return {
    page,
    loading: loading || configLoading,
    error,
    refetch: loadPage,
  };
};

