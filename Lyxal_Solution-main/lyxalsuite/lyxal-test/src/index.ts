/**
 * Lyxal Test - Module centralisé de tests pour LyxalSuite
 * Point d'entrée principal avec tous les utilitaires, mocks, fixtures et tests
 */

// Export des utilitaires de test
export * from './helpers';

// Export des mocks
export * from './mocks';

// Export des fixtures
export * from './fixtures';



// Export des tests regroupés
export * from './tests';

// Export des types utiles pour les tests
export type {
  SurrealConfig,
  SaaSRecord,
  WorkspaceRecord,
  WorkspaceModule,
  ModuleDefinition,
  PerformanceMetrics
} from '@lyxal-surreal/index';

// Version du module
export const VERSION = '1.0.0';

// Configuration par défaut
export const DEFAULT_TEST_CONFIG = {
  timeout: 30000,
  retries: 2,
  verbose: true,
  setupFilesAfterEnv: ['<rootDir>/src/setup/index.ts']
};

console.log(`🧪 Lyxal Test v${VERSION} - Module de tests centralisé chargé`); 