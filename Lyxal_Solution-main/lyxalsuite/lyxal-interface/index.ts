/**
 * 🎯 LYXAL Interface - Point d'entrée simple
 * 
 * Interface TypeScript minimaliste :
 * - Récupère les données de connexion initiales
 * - Streaming automatique pour les mises à jour
 */

// Types
export type {
  ConnectionData,
  LyxalInterface,
  SystemIdentity,
  SystemInfrastructure
} from './types/interface.js';

// Implémentation
export { LyxalInterfaceImpl } from './interface.js';

// Hook React
export { useLyxalInterface } from './useLyxalInterface.js';

// Imports pour usage interne
import type { LyxalInterface } from './types/interface.js';
import { LyxalInterfaceImpl } from './interface.js';

// Factory function pour créer une instance
export function createLyxalInterface() {
  return new LyxalInterfaceImpl();
} 