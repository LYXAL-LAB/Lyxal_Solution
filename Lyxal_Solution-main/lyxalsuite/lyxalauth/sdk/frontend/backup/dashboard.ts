import { apiClient } from './config';

/**
 * Récupère le nombre total d'utilisateurs
 */
export const getTotalUserCount = async (): Promise<{ count: number }> => {
  return apiClient<{ count: number }>('/dashboard/users/total');
};

/**
 * Récupère le nombre de nouveaux utilisateurs
 */
export const getNewUserCount = async (options?: {
  days?: number;
}): Promise<{ count: number }> => {
  const queryParams = new URLSearchParams();
  
  if (options?.days) {
    queryParams.append('days', options.days.toString());
  }
  
  const query = queryParams.toString() ? `?${queryParams.toString()}` : '';
  return apiClient<{ count: number }>(`/dashboard/users/new${query}`);
};

/**
 * Récupère les données des utilisateurs actifs
 */
export const getActiveUserData = async (options?: {
  days?: number;
}): Promise<{
  dailyActive: Array<{ date: string; count: number }>;
  monthlyActive: Array<{ date: string; count: number }>;
}> => {
  const queryParams = new URLSearchParams();
  
  if (options?.days) {
    queryParams.append('days', options.days.toString());
  }
  
  const query = queryParams.toString() ? `?${queryParams.toString()}` : '';
  return apiClient<{
    dailyActive: Array<{ date: string; count: number }>;
    monthlyActive: Array<{ date: string; count: number }>;
  }>(`/dashboard/users/active${query}`);
}; 