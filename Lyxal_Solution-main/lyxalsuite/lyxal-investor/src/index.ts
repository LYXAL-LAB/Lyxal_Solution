/**
 * LYXAL INVESTOR MODULE
 * 
 * Module principal pour l'interface INVESTOR
 * Réutilise le système de monitoring existant en mode INVESTOR_LEVEL
 */

// Export du composant principal
export { InvestorDashboard } from './pages/InvestorDashboard';

// Configuration du module
export const INVESTOR_MODULE_CONFIG = {
  name: 'lyxal-investor',
  version: '1.0.0',
  namespace: 'catalog',
  userLevel: 'INVESTOR_LEVEL',
  features: ['monitoring', 'saas-overview']
} as const;