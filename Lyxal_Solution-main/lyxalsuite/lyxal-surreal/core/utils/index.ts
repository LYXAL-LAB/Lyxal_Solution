/**
 * Export consolidé des utilitaires LYXAL Surreal
 */

// Cache intelligent
export { metadataCache, queryCache } from './cache';
export type { CacheMetrics } from './cache';

// Monitoring de performance
export { performanceMonitor } from './performanceMonitor';
export type { QueryMetrics, AggregatedMetrics } from './performanceMonitor';

// Logger 
export { Logger } from './logger';

// Gestion d'erreurs 
export { errorHandler } from './errorHandler';

// Middlewares
export { saasMiddleware, workspaceMiddleware, autoProvisionSaaSMiddleware } from './middlewares';

// Types d'erreurs
export type * from '../types/errors.types'; 