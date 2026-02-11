/**
 * 🎯 Interface TypeScript Simple
 * 
 * Récupère les données de connexion initiales + streaming automatique
 */

import type {
  SystemIdentity,
  SystemInfrastructure
} from '@lyxalsuite/lyxal-surreal';

/**
 * Données de connexion système
 */
export interface ConnectionData {
  identity: SystemIdentity;
  infrastructure: SystemInfrastructure;
  lastUpdate: Date;
}

/**
 * Interface principale
 */
export interface LyxalInterface {
  // Données actuelles
  data: ConnectionData | null;
  isConnected: boolean;
  isStreaming: boolean;
  
  // Actions
  connect(platformId?: string): Promise<ConnectionData>;
  startStreaming(): Promise<void>;
  stopStreaming(): Promise<void>;
  
  // Callback pour les mises à jour
  onUpdate?: (data: ConnectionData) => void;
}

// Re-exports
export type { SystemIdentity, SystemInfrastructure };