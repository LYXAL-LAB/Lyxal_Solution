/**
 * 🎯 Hook React Simple
 * 
 * Hook qui utilise l'interface pour récupérer les données + streaming
 */

import { useState, useEffect, useRef } from 'react';
import { LyxalInterfaceImpl } from './interface.js';
import type { ConnectionData } from './types/interface.js';

interface UseLyxalInterfaceOptions {
  platformId?: string;
  autoStream?: boolean;
}

interface UseLyxalInterfaceReturn {
  data: ConnectionData | null;
  loading: boolean;
  error: Error | null;
  isStreaming: boolean;
  startStreaming: () => Promise<void>;
  stopStreaming: () => Promise<void>;
  refresh: () => Promise<void>;
}

export function useLyxalInterface(
  options: UseLyxalInterfaceOptions = {}
): UseLyxalInterfaceReturn {
  
  const [data, setData] = useState<ConnectionData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);
  const [isStreaming, setIsStreaming] = useState(false);
  
  const interfaceRef = useRef<LyxalInterfaceImpl>();

  // Initialisation
  useEffect(() => {
    const lyxalInterface = new LyxalInterfaceImpl();
    interfaceRef.current = lyxalInterface;

    // Callback pour les mises à jour streaming
    lyxalInterface.onUpdate = (newData) => {
      setData(newData);
    };

    // Connexion initiale
    const connect = async () => {
      try {
        setLoading(true);
        setError(null);
        
        const connectionData = await lyxalInterface.connect(options.platformId);
        setData(connectionData);

        // Active le streaming automatiquement si demandé
        if (options.autoStream) {
          await lyxalInterface.startStreaming();
          setIsStreaming(true);
        }

      } catch (err) {
        setError(err as Error);
      } finally {
        setLoading(false);
      }
    };

    connect();

    // Nettoyage
    return () => {
      lyxalInterface.destroy();
    };
  }, [options.platformId, options.autoStream]);

  // Actions
  const startStreaming = async () => {
    if (interfaceRef.current && !isStreaming) {
      try {
        await interfaceRef.current.startStreaming();
        setIsStreaming(true);
      } catch (err) {
        setError(err as Error);
      }
    }
  };

  const stopStreaming = async () => {
    if (interfaceRef.current && isStreaming) {
      try {
        await interfaceRef.current.stopStreaming();
        setIsStreaming(false);
      } catch (err) {
        setError(err as Error);
      }
    }
  };

  const refresh = async () => {
    if (interfaceRef.current) {
      try {
        setLoading(true);
        setError(null);
        const connectionData = await interfaceRef.current.connect(options.platformId);
        setData(connectionData);
      } catch (err) {
        setError(err as Error);
      } finally {
        setLoading(false);
      }
    }
  };

  return {
    data,
    loading,
    error,
    isStreaming,
    startStreaming,
    stopStreaming,
    refresh
  };
} 