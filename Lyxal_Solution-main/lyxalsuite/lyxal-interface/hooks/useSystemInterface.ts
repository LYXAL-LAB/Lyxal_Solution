/**
 * 🎯 Hook React Simple - Connexion + Streaming automatique
 * 
 * Hook minimaliste qui :
 * 1. Récupère les données de connexion initiales
 * 2. Active le streaming pour les mises à jour automatiques
 */

import { useState, useEffect, useCallback } from 'react';
import { LyxalSurrealClient, defaultConfig } from '@lyxalsuite/lyxal-surreal';
import type { ConnectionData } from '../types/interface.js';

interface UseLyxalInterfaceOptions {
  platformId?: string;
  autoStream?: boolean;
}

interface UseLyxalInterfaceReturn {
  data: ConnectionData | null;
  loading: boolean;
  error: Error | null;
  refresh: () => Promise<void>;
  enableStreaming: () => Promise<void>;
  disableStreaming: () => Promise<void>;
}

export function useLyxalInterface(
  options: UseLyxalInterfaceOptions = {}
): UseLyxalInterfaceReturn {
  
  const [data, setData] = useState<ConnectionData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);
  const [liveQueries, setLiveQueries] = useState<any[]>([]);

  const client = new LyxalSurrealClient(defaultConfig);

  /**
   * Charge les données de connexion initiales
   */
  const loadConnectionData = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);

      // ✅ Vérifie si MASTER est configuré
      const isConfigured = await client.master.isMasterLevelConfigured();
      if (!isConfigured) {
        throw new Error('Niveau MASTER non configuré');
      }

      let identity, infrastructure;

      if (options.platformId) {
        // Charge une plateforme spécifique
        const platform = await client.master.getMasterPlatform(options.platformId);
        identity = platform.identity;
        infrastructure = platform.infrastructure;
      } else {
        // Charge la première plateforme disponible
        const platforms = await client.master.listMasterPlatforms();
        if (platforms.identities.length === 0) {
          throw new Error('Aucune plateforme MASTER trouvée');
        }
        identity = platforms.identities[0]!;
        infrastructure = platforms.infrastructures[0]!;
      }

      const connectionData: ConnectionData = {
        identity,
        infrastructure,
        lastUpdate: new Date()
      };

      setData(connectionData);

      // ✅ Active le streaming automatiquement si demandé
      if (options.autoStream) {
        await enableStreamingInternal(connectionData);
      }

    } catch (err) {
      setError(err as Error);
    } finally {
      setLoading(false);
    }
  }, [options.platformId, options.autoStream]);

  /**
   * Active le streaming pour les mises à jour automatiques
   */
  const enableStreamingInternal = useCallback(async (connectionData: ConnectionData) => {
    try {
      const baseClient = client.getBaseClient();
      const db = baseClient.getDB();
      const queries: any[] = [];

      // ✅ Streaming sur system_identity
      const identityQuery = await db.live(
        `LIVE SELECT * FROM system_identity WHERE platform_id = '${connectionData.identity.platform_id}'`,
        (action: string, result: any) => {
          if (action === 'UPDATE' && result) {
            setData(prev => prev ? {
              ...prev,
              identity: result,
              lastUpdate: new Date()
            } : null);
          }
        }
      );
      queries.push(identityQuery);

      // ✅ Streaming sur system_infrastructure
      const infraQuery = await db.live(
        `LIVE SELECT * FROM system_infrastructure WHERE platform_id = '${connectionData.identity.platform_id}'`,
        (action: string, result: any) => {
          if (action === 'UPDATE' && result) {
            setData(prev => prev ? {
              ...prev,
              infrastructure: result,
              lastUpdate: new Date()
            } : null);
          }
        }
      );
      queries.push(infraQuery);

      setLiveQueries(queries);

    } catch (err) {
      console.error('Erreur activation streaming:', err);
    }
  }, [client]);

  /**
   * Active le streaming manuellement
   */
  const enableStreaming = useCallback(async () => {
    if (data) {
      await enableStreamingInternal(data);
    }
  }, [data, enableStreamingInternal]);

  /**
   * Désactive le streaming
   */
  const disableStreaming = useCallback(async () => {
    try {
      const baseClient = client.getBaseClient();
      const db = baseClient.getDB();
      await Promise.all(liveQueries.map(queryId => db.kill(queryId)));
      setLiveQueries([]);
    } catch (err) {
      console.error('Erreur désactivation streaming:', err);
    }
  }, [liveQueries, client]);

  /**
   * Actualise les données manuellement
   */
  const refresh = useCallback(async () => {
    await loadConnectionData();
  }, [loadConnectionData]);

  // ✅ Chargement initial
  useEffect(() => {
    loadConnectionData();
  }, [loadConnectionData]);

  // ✅ Nettoyage au démontage
  useEffect(() => {
    return () => {
      if (liveQueries.length > 0) {
        disableStreaming();
      }
    };
  }, [liveQueries, disableStreaming]);

  return {
    data,
    loading,
    error,
    refresh,
    enableStreaming,
    disableStreaming
  };
} 