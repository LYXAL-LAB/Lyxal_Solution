/**
 * SDK GDPR pour Lyxal Gateway
 * Exposer les différentes interfaces et types pour faciliter l'importation
 */

// Exporter les types communs
export * from './types/types';
export * from './types/monitoring';

// Exporter le client backend
export { GdprClient } from './backend/gdprClient';
export { createGdprHooks } from './backend/hooks';

// Exporter les hooks frontend
export {
  useCreateRequest,
  useCreateAccessRequest,
  useCreateErasureRequest,
  useGetRequest,
  useListRequests,
  useUpdateRequest,
  useCreateResponse,
  useListLogs,
  useDeleteRequest
} from './frontend/hooks';

// Exporter les composants frontend
export { GdprRequestForm } from './frontend/components/GdprRequestForm';
export { GdprRequestList } from './frontend/components/GdprRequestList';

// Exporter l'agent IA
export { GdprAgent, createGdprAgent } from './agent/gdprAgent';

// Exporter le système de monitoring
export { GdprMonitor, createGdprMonitor } from './monitoring/gdprMonitor';
export { GdprDashboard, createGdprDashboard } from './monitoring/dashboard';

// Version et informations
export const VERSION = '0.1.0';
export const PACKAGE_NAME = 'lyxalgdpr';
export const DESCRIPTION = 'Module GDPR pour Lyxal Gateway'; 