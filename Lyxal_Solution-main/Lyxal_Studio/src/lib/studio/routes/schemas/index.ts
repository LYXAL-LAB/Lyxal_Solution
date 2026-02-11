/**
 * Export centralisé de tous les schémas de validation
 * pour le système de routes dynamiques
 */

// Schémas principaux
export * from './routeSchema';
export * from './permissionSchema';
export * from './guardSchema';

// Types utilitaires partagés
export type { RouteValidationResult } from '../../types/route';
