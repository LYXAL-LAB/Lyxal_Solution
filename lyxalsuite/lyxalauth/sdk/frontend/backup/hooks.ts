import { apiClient } from './config';
import { PaginationOptions, PaginatedResponse } from './types';

interface Hook {
  id: string;
  name: string;
  triggerType: string;
  events: string[];
  config: {
    endpoint: string;
    httpMethod?: string;
    headers?: Record<string, string>;
    timeout?: number;
  };
  signingKey?: string;
  enabled: boolean;
  createdAt: string;
}

/**
 * Récupère la liste des hooks
 */
export const getHooks = async (
  options?: PaginationOptions
): Promise<PaginatedResponse<Hook>> => {
  const queryParams = new URLSearchParams();
  
  if (options) {
    if (options.page) queryParams.append('page', options.page.toString());
    if (options.pageSize) queryParams.append('page_size', options.pageSize.toString());
  }
  
  const query = queryParams.toString() ? `?${queryParams.toString()}` : '';
  return apiClient<PaginatedResponse<Hook>>(`/hooks${query}`);
};

/**
 * Récupère un hook par son ID
 */
export const getHook = async (hookId: string): Promise<Hook> => {
  return apiClient<Hook>(`/hooks/${hookId}`);
};

/**
 * Crée un nouveau hook
 */
export const createHook = async (hookData: {
  name: string;
  triggerType: string;
  events: string[];
  config: {
    endpoint: string;
    httpMethod?: string;
    headers?: Record<string, string>;
    timeout?: number;
  };
  enabled?: boolean;
}): Promise<Hook> => {
  return apiClient<Hook>('/hooks', {
    method: 'POST',
    body: JSON.stringify(hookData),
  });
};

/**
 * Met à jour un hook
 */
export const updateHook = async (
  hookId: string,
  hookData: {
    name?: string;
    events?: string[];
    config?: {
      endpoint?: string;
      httpMethod?: string;
      headers?: Record<string, string>;
      timeout?: number;
    };
    enabled?: boolean;
  }
): Promise<Hook> => {
  return apiClient<Hook>(`/hooks/${hookId}`, {
    method: 'PATCH',
    body: JSON.stringify(hookData),
  });
};

/**
 * Supprime un hook
 */
export const deleteHook = async (hookId: string): Promise<void> => {
  return apiClient<void>(`/hooks/${hookId}`, {
    method: 'DELETE',
  });
};

/**
 * Récupère les logs récents d'un hook
 */
export const getHookLogs = async (
  hookId: string,
  options?: PaginationOptions
): Promise<PaginatedResponse<{
  id: string;
  hookId: string;
  event: string;
  requestBody: Record<string, any>;
  responseBody?: Record<string, any>;
  statusCode?: number;
  executionTime?: number;
  success: boolean;
  errorMessage?: string;
  createdAt: string;
}>> => {
  const queryParams = new URLSearchParams();
  
  if (options) {
    if (options.page) queryParams.append('page', options.page.toString());
    if (options.pageSize) queryParams.append('page_size', options.pageSize.toString());
  }
  
  const query = queryParams.toString() ? `?${queryParams.toString()}` : '';
  return apiClient<
    PaginatedResponse<{
      id: string;
      hookId: string;
      event: string;
      requestBody: Record<string, any>;
      responseBody?: Record<string, any>;
      statusCode?: number;
      executionTime?: number;
      success: boolean;
      errorMessage?: string;
      createdAt: string;
    }>
  >(`/hooks/${hookId}/logs${query}`);
};

/**
 * Teste un hook
 */
export const testHook = async (
  hookId: string,
  testData?: Record<string, any>
): Promise<{
  success: boolean;
  statusCode?: number;
  responseBody?: Record<string, any>;
  errorMessage?: string;
  executionTime?: number;
}> => {
  return apiClient<{
    success: boolean;
    statusCode?: number;
    responseBody?: Record<string, any>;
    errorMessage?: string;
    executionTime?: number;
  }>(`/hooks/${hookId}/test`, {
    method: 'POST',
    body: JSON.stringify(testData || {}),
  });
};

/**
 * Met à jour la clé de signature pour un hook
 */
export const updateHookSigningKey = async (
  hookId: string
): Promise<{ signingKey: string }> => {
  return apiClient<{ signingKey: string }>(`/hooks/${hookId}/signing-key`, {
    method: 'PATCH',
  });
}; 