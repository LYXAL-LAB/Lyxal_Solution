import { apiClient } from './config';
import { PaginationOptions, PaginatedResponse } from './types';

interface OneTimeToken {
  id: string;
  purpose: string;
  userId?: string;
  createdAt: string;
  expiresAt: string;
  status: 'Active' | 'Used' | 'Expired';
}

/**
 * Récupère la liste des tokens à usage unique
 */
export const getOneTimeTokens = async (
  options?: PaginationOptions & {
    userId?: string;
    purpose?: string;
    status?: 'Active' | 'Used' | 'Expired';
  }
): Promise<PaginatedResponse<OneTimeToken>> => {
  const queryParams = new URLSearchParams();
  
  if (options) {
    if (options.page) queryParams.append('page', options.page.toString());
    if (options.pageSize) queryParams.append('page_size', options.pageSize.toString());
    if (options.userId) queryParams.append('userId', options.userId);
    if (options.purpose) queryParams.append('purpose', options.purpose);
    if (options.status) queryParams.append('status', options.status);
  }
  
  const query = queryParams.toString() ? `?${queryParams.toString()}` : '';
  return apiClient<PaginatedResponse<OneTimeToken>>(`/one-time-tokens${query}`);
};

/**
 * Crée un token à usage unique
 */
export const createOneTimeToken = async (
  tokenData: {
    purpose: string;
    userId?: string;
    expiresIn?: number; // En secondes
  }
): Promise<OneTimeToken & { token: string }> => {
  return apiClient<OneTimeToken & { token: string }>('/one-time-tokens', {
    method: 'POST',
    body: JSON.stringify(tokenData),
  });
};

/**
 * Récupère un token à usage unique par son ID
 */
export const getOneTimeToken = async (tokenId: string): Promise<OneTimeToken> => {
  return apiClient<OneTimeToken>(`/one-time-tokens/${tokenId}`);
};

/**
 * Supprime un token à usage unique
 */
export const deleteOneTimeToken = async (tokenId: string): Promise<void> => {
  return apiClient<void>(`/one-time-tokens/${tokenId}`, {
    method: 'DELETE',
  });
};

/**
 * Vérifie un token à usage unique
 */
export const verifyOneTimeToken = async (
  token: string
): Promise<{
  success: boolean;
  purpose?: string;
  userId?: string;
}> => {
  return apiClient<{
    success: boolean;
    purpose?: string;
    userId?: string;
  }>('/one-time-tokens/verify', {
    method: 'POST',
    body: JSON.stringify({ token }),
  });
};

/**
 * Met à jour le statut d'un token à usage unique
 */
export const updateOneTimeTokenStatus = async (
  tokenId: string,
  status: 'Used' | 'Expired'
): Promise<OneTimeToken> => {
  return apiClient<OneTimeToken>(`/one-time-tokens/${tokenId}/status`, {
    method: 'PUT',
    body: JSON.stringify({ status }),
  });
}; 