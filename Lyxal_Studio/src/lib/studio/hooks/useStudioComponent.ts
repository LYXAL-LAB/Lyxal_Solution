import { useState, useEffect } from 'react';
import { SystemConfigService } from '@/services/SystemConfigService';
import { SurrealClient } from '@/services/SurrealClient';
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
export const useStudioComponent = (code: string): UseStudioComponentResult => {
  const [config, setConfig] = useState<any>(null);
  const [configLoading, setConfigLoading] = useState(true);
  const [component, setComponent] = useState<StudioComponent | null>(null);
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

  const loadComponent = async () => {
    if (!code || configLoading || !config) {
      return;
    }

    try {
      setLoading(true);
      setError(null);

      // Requête SurrealDB pour charger le composant
      const query = `
        SELECT * FROM studio_component 
        WHERE identity.code = '${code}' 
        AND status.is_active = true
        LIMIT 1
      `;

      const result = await SurrealClient.query<StudioComponent[]>(config, query);

      if (result && Array.isArray(result) && result.length > 0) {
        setComponent(result[0]);
      } else {
        setComponent(null);
        setError(new Error(`Component '${code}' not found or inactive`));
      }
    } catch (err) {
      const error = err instanceof Error 
        ? err 
        : new Error(`Failed to load component '${code}'`);
      setError(error);
      console.error(`[useStudioComponent] Failed to load component '${code}':`, err);
      setComponent(null);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadComponent();
  }, [code, configLoading]);

  return {
    component,
    loading: loading || configLoading,
    error,
    refetch: loadComponent,
  };
};

