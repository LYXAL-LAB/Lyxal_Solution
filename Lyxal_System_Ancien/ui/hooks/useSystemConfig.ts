import { useState, useEffect } from 'react';
import { SystemConfigService } from '../services/SystemConfigService';

/**
 * Interface pour la configuration système
 */
interface SystemConfig {
  identity: {
    platformName: {
      value: string;
    };
    themeParDefaut: {
      value: string;
    };
    niveauArchitectural: {
      value: string;
    };
    anneeConstruction: {
      value: string;
    };
    nomApplication?: string;
    version?: string;
  };
  infrastructure: {
    surrealDbUrl: {
      value: string;
    };
    surrealNamespace: {
      value: string;
    };
    surrealDatabase: {
      value: string;
    };
    surrealUsername: {
      value: string;
    };
    surrealPassword: {
      value: string;
    };
  };
  ui?: {
    sidebar?: {
      defaultOpen: boolean;
    };
    modules?: Record<string, boolean>;
  };
}

/**
 * Interface pour le retour du hook
 */
interface UseSystemConfigReturn {
  config: SystemConfig;
  loading: boolean;
  error: Error | null;
  refetch: () => void;
}

function buildDefaultConfig(): SystemConfig {
  return {
        identity: {
      platformName: {
        value: 'LYXAL'
      },
          themeParDefaut: {
            value: localStorage.getItem('lyxal-default-theme') || 'corporate'
          },
          niveauArchitectural: {
            value: '5' // Niveau propriétaire par défaut
          },
          anneeConstruction: {
            value: '2025'
          },
          nomApplication: 'LYXAL Master Console',
          version: '1.0.0'
        },
        infrastructure: {
          surrealDbUrl: {
        value: 'wss://lyxal-06bsd9k399ou7e5fa4tblm6b3g.aws-euw1.surreal.cloud/rpc'
          },
          surrealNamespace: {
        value: 'Lyxal_Solution'
          },
          surrealDatabase: {
        value: 'Labs'
          },
          surrealUsername: {
        value: 'admin'
          },
          surrealPassword: {
        value: 'admin'
          }
        },
        ui: {
          sidebar: {
        defaultOpen: typeof window !== 'undefined' ? window.innerWidth >= 1024 : true
      },
      modules: {}
    }
  };
}

function deepMergeDefaults(defaults: SystemConfig, remote?: Partial<{
  identity: Partial<Record<string, { value: string }>>;
  infrastructure: Partial<Record<string, { value: string }>>;
  ui: { sidebar?: { defaultOpen: boolean }, modules?: Record<string, boolean> };
}>): SystemConfig {
  if (!remote) return defaults;
  return {
    identity: {
      ...defaults.identity,
      ...(remote.identity || {}),
    } as SystemConfig['identity'],
    infrastructure: {
      ...defaults.infrastructure,
      ...(remote.infrastructure || {}),
    } as SystemConfig['infrastructure'],
    ui: {
      ...defaults.ui,
      ...(remote.ui || {}),
      modules: { ...(defaults.ui?.modules || {}), ...(remote.ui?.modules || {}) }
    },
  };
}

/**
 * Hook personnalisé pour la gestion de la configuration système
 * Charge et gère la configuration globale de l'application
 */
export const useSystemConfig = (): UseSystemConfigReturn => {
  const [config, setConfig] = useState<SystemConfig>(() => buildDefaultConfig());
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  const loadConfig = async () => {
    try {
      setLoading(true);
      setError(null);
      const defaults = buildDefaultConfig();
      // Charger depuis le service (Surreal/HTTP plus tard)
      const remote = await SystemConfigService.loadAll();
      const merged = deepMergeDefaults(defaults, remote);
      setConfig(merged);
    } catch (err) {
      // En cas d'erreur, rester sur les defaults
      setError(err instanceof Error ? err : new Error('Erreur de chargement de la configuration'));
      setConfig((prev) => prev || buildDefaultConfig());
    } finally {
      setLoading(false);
    }
  };

  const refetch = () => { loadConfig(); };

  useEffect(() => { loadConfig(); }, []);

  return { config, loading, error, refetch };
}; 