/**
 * Configuration globale Jest pour LyxalSuite
 */

declare global {
  var testConfig: {
    timeout: number;
    retries: number;
    verbose: boolean;
  };
}

// Configuration des timeouts
jest.setTimeout(30000);

// Configuration globale pour les tests
global.testConfig = {
  timeout: 10000,
  retries: 3,
  verbose: process.env.NODE_ENV === 'test'
};

beforeEach(() => {
  // Réinitialiser les mocks avant chaque test
  jest.clearAllMocks();
});

afterEach(() => {
  // Nettoyer après chaque test
  jest.restoreAllMocks();
});

// Mock des modules externes si nécessaire
jest.mock('surrealdb.js', () => ({
  Surreal: jest.fn().mockImplementation(() => ({
    connect: jest.fn(),
    signin: jest.fn(),
    use: jest.fn(),
    query: jest.fn(),
    close: jest.fn()
  }))
}));

export {}; 