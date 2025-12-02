import { useState, useEffect } from 'react';
import { SystemConfigService } from '@/services/SystemConfigService';
import { SurrealClient } from '@/services/SurrealClient';
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
export const useStudioComponent = (code) => {
    const [config, setConfig] = useState(null);
    const [configLoading, setConfigLoading] = useState(true);
    const [component, setComponent] = useState(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    // Charger la configuration au montage
    useEffect(() => {
        const loadConfig = async () => {
            try {
                const systemConfig = await SystemConfigService.loadAll();
                setConfig(systemConfig);
            }
            catch (err) {
                setError(err instanceof Error ? err : new Error('Failed to load config'));
            }
            finally {
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
            const result = await SurrealClient.query(config, query);
            if (result && Array.isArray(result) && result.length > 0) {
                setComponent(result[0]);
            }
            else {
                setComponent(null);
                setError(new Error(`Component '${code}' not found or inactive`));
            }
        }
        catch (err) {
            const error = err instanceof Error
                ? err
                : new Error(`Failed to load component '${code}'`);
            setError(error);
            console.error(`[useStudioComponent] Failed to load component '${code}':`, err);
            setComponent(null);
        }
        finally {
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
