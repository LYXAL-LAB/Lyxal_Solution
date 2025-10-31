// Configuration Jest pour les tests React
import '@testing-library/jest-dom';

// Mock pour matchMedia (nécessaire pour les tests avec responsive design)
Object.defineProperty(window, 'matchMedia', {
  writable: true,
  value: jest.fn().mockImplementation(query => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: jest.fn(), // deprecated
    removeListener: jest.fn(), // deprecated
    addEventListener: jest.fn(),
    removeEventListener: jest.fn(),
    dispatchEvent: jest.fn(),
  })),
});

// Mock pour ResizeObserver
global.ResizeObserver = jest.fn().mockImplementation(() => ({
  observe: jest.fn(),
  unobserve: jest.fn(),
  disconnect: jest.fn(),
}));

// Mock pour IntersectionObserver
global.IntersectionObserver = jest.fn().mockImplementation(() => ({
  observe: jest.fn(),
  unobserve: jest.fn(),
  disconnect: jest.fn(),
}));

// Configuration pour les tests d'accessibilité
import { configure } from '@testing-library/react';

configure({
  testIdAttribute: 'data-testid',
});

// Extend expect avec des matchers personnalisés pour l'accessibilité
expect.extend({
  toHaveAccessibleName(received, expected) {
    const pass = received.getAttribute('aria-label') === expected ||
                 received.getAttribute('aria-labelledby') ||
                 received.textContent === expected;
    
    return {
      message: () => `expected element to have accessible name "${expected}"`,
      pass,
    };
  },
});

// Configuration globale pour les tests
beforeEach(() => {
  // Reset des mocks avant chaque test
  jest.clearAllMocks();
});

afterEach(() => {
  // Nettoyage après chaque test
  jest.restoreAllMocks();
}); 