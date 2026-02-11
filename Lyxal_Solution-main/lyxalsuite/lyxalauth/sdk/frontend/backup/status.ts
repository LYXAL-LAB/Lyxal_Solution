import { apiClient } from './config';

/**
 * Vérifie l'état de santé du serveur
 */
export const checkHealth = async (): Promise<{ status: string }> => {
  return apiClient<{ status: string }>('/status/health');
}; 