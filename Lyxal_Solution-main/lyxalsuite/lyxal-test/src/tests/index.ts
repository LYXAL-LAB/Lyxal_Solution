/**
 * Index des tests regroupés - LyxalSuite
 * Point d'entrée centralisé pour tous les tests
 */

// Export des suites de tests
export * from './performance.test';
export * from './saas.test';
export * from './gdpr.test';
export * from './auth.test';
export * from './surreal-advanced.test';
export * from './ui.test';

// Configuration globale des tests
export const TEST_CONFIG = {
  timeout: 30000,
  retries: 2,
  verbose: true,
  collectCoverage: true,
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80
    }
  }
};

// Utilitaires pour les tests regroupés
export const TEST_SUITES = {
  performance: 'Tests de Performance - LyxalSuite',
  saas: 'SaaS Instance Management - Architecture Bicéphale', 
  gdpr: 'GDPR Types et Flux - LyxalSuite',
  auth: 'Tests d\'Authentification - LyxalSuite',
  surrealAdvanced: 'Tests SurrealDB Avancés - LyxalSuite',
  ui: 'Tests Interface Utilisateur - LyxalSuite'
} as const;

export type TestSuite = keyof typeof TEST_SUITES; 