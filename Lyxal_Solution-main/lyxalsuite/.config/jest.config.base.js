/** @type {import('jest').Config} */
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'jsdom',
  
  // Chemins de base
  roots: ['<rootDir>/src'],
  testMatch: [
    '**/__tests__/**/*.(ts|tsx|js)',
    '**/*.(test|spec).(ts|tsx|js)'
  ],
  
  // Transformation des fichiers
  transform: {
    '^.+\\.(ts|tsx)$': 'ts-jest',
    '^.+\\.(js|jsx)$': 'babel-jest'
  },
  
  // Extensions de fichiers
  moduleFileExtensions: ['ts', 'tsx', 'js', 'jsx', 'json', 'node'],
  
  // Alias de modules (coherent avec tsconfig)
  moduleNameMapping: {
    '^@/(.*)$': '<rootDir>/src/$1',
    '^@lyxal-surreal/(.*)$': '<rootDir>/../lyxal-surreal/$1',
    '^@lyxal-surreal$': '<rootDir>/../lyxal-surreal'
  },
  
  // Configuration des tests
  setupFilesAfterEnv: ['<rootDir>/src/setupTests.ts'],
  testTimeout: 10000,
  
  // Couverture de code
  collectCoverageFrom: [
    'src/**/*.{ts,tsx}',
    '!src/**/*.d.ts',
    '!src/**/*.test.{ts,tsx}',
    '!src/**/*.spec.{ts,tsx}',
    '!src/**/index.ts',
    '!src/setupTests.ts'
  ],
  coverageDirectory: 'coverage',
  coverageReporters: ['text', 'lcov', 'html'],
  
  // Seuils de couverture
  coverageThreshold: {
    global: {
      branches: 70,
      functions: 70,
      lines: 70,
      statements: 70
    }
  },
  
  // Fichiers à ignorer
  testPathIgnorePatterns: [
    '/node_modules/',
    '/dist/',
    '/build/',
    '/coverage/'
  ],
  
  // Variables d'environnement pour les tests
  testEnvironmentOptions: {
    url: 'http://localhost'
  },
  
  // Configuration spécifique pour TypeScript
  globals: {
    'ts-jest': {
      tsconfig: {
        jsx: 'react-jsx'
      }
    }
  }
}; 