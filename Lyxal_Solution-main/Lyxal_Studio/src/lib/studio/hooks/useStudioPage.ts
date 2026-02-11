import { useState, useEffect } from 'react';
import { SystemConfigService } from '@/services/SystemConfigService';
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
  const [config, setConfig] = useState<any>(null);
  const [configLoading, setConfigLoading] = useState(true);
  const [page, setPage] = useState<StudioPage | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  // Charger la configuration au montage
  useEffect(() => {
    const loadConfig = async () => {
      try {
        const systemConfig = await SystemConfigService.loadAll();
        setConfig(systemConfig);
      } catch (err) {
        setError(err instanceof Error ? err : new Error('Failed to load config'));
      } finally {
        setConfigLoading(false);
      }
    };
    loadConfig();
  }, []);

  const loadPage = async () => {
    if (!code || configLoading || !config) {
      console.log(`[useStudioPage] Skipping load - code: ${code}, configLoading: ${configLoading}, hasConfig: ${!!config}`);
      return;
    }

    console.log(`[useStudioPage] 🔍 Loading page '${code}'...`);

    try {
      setLoading(true);
      setError(null);

      // Requête SurrealDB pour charger la page
      const query = `
        SELECT * FROM studio_page
        WHERE identity.code = $code
        AND status.is_active = true
        LIMIT 1
      `;

      console.log(`[useStudioPage] 📡 Executing query with params:`, { code });
      console.log(`[useStudioPage] 🔗 Config used:`, {
        url: config.infrastructure?.surrealDbUrl?.value,
        ns: config.infrastructure?.surrealNamespace?.value,
        db: config.infrastructure?.surrealDatabase?.value
      });

      const result = await SurrealClient.queryWithParams<StudioPage[]>(config, query, { code });

      console.log(`[useStudioPage] 📦 Raw result:`, result);
      console.log(`[useStudioPage] 📊 Result type:`, typeof result, Array.isArray(result) ? `length: ${result.length}` : 'not array');

      if (result && Array.isArray(result) && result.length > 0) {
        console.log(`[useStudioPage] ✅ Page found:`, result[0].identity);
        setPage(result[0]);
      } else {
        console.log(`[useStudioPage] ❌ Page not found. Checking if exists inactive...`);

        // Requête sans le filtre is_active pour déboguer
        const debugQuery = `SELECT identity.code, status.is_active FROM studio_page WHERE identity.code = '${code}'`;
        const debugResult = await SurrealClient.query<any[]>(config, debugQuery);
        console.log(`[useStudioPage] 🔍 Debug result:`, debugResult);

        setPage(null);
        setError(new Error(`Page '${code}' not found or inactive`));
      }
    } catch (err) {
      const error = err instanceof Error
        ? err
        : new Error(`Failed to load page '${code}'`);
      console.error(`[useStudioPage] 💥 Failed to load page '${code}':`, err);
      setError(error);
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

