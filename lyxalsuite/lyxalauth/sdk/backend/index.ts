/**
 * @file index.ts
 * @description Point d'entrée du SDK backend lyxalauth
 */

// Exporter le client d'authentification
export * from './client';

// Exporter les middlewares
export * from './middleware';

// Définir la version du SDK
export const BACKEND_SDK_VERSION = '1.0.0'; 