import { apiClient } from './config';
import { Resource, Scope, PaginationOptions, PaginatedResponse } from './types';

/**
 * Récupère la liste des ressources API
 */
export const getResources = async (
  options?: PaginationOptions & { search?: string }
): Promise<PaginatedResponse<Resource>> => {
  const queryParams = new URLSearchParams();
  
  if (options) {
    if (options.page) queryParams.append('page', options.page.toString());
    if (options.pageSize) queryParams.append('page_size', options.pageSize.toString());
    if (options.search) queryParams.append('search', options.search);
  }
  
  const query = queryParams.toString() ? `?${queryParams.toString()}` : '';
  return apiClient<PaginatedResponse<Resource>>(`/resources${query}`);
};

/**
 * Récupère une ressource API par son ID
 */
export const getResource = async (resourceId: string): Promise<Resource> => {
  return apiClient<Resource>(`/resources/${resourceId}`);
};

/**
 * Crée une nouvelle ressource API
 */
export const createResource = async (resourceData: {
  name: string;
  indicator: string;
  accessTokenTtl?: number;
}): Promise<Resource> => {
  return apiClient<Resource>('/resources', {
    method: 'POST',
    body: JSON.stringify(resourceData),
  });
};

/**
 * Met à jour une ressource API
 */
export const updateResource = async (
  resourceId: string,
  resourceData: {
    name?: string;
    accessTokenTtl?: number;
  }
): Promise<Resource> => {
  return apiClient<Resource>(`/resources/${resourceId}`, {
    method: 'PATCH',
    body: JSON.stringify(resourceData),
  });
};

/**
 * Supprime une ressource API
 */
export const deleteResource = async (resourceId: string): Promise<void> => {
  return apiClient<void>(`/resources/${resourceId}`, {
    method: 'DELETE',
  });
};

/**
 * Définit une ressource API comme ressource par défaut
 */
export const setResourceAsDefault = async (resourceId: string): Promise<Resource> => {
  return apiClient<Resource>(`/resources/${resourceId}/default`, {
    method: 'PATCH',
  });
};

/**
 * Récupère les scopes d'une ressource API
 */
export const getResourceScopes = async (
  resourceId: string,
  options?: PaginationOptions
): Promise<PaginatedResponse<Scope>> => {
  const queryParams = new URLSearchParams();
  
  if (options) {
    if (options.page) queryParams.append('page', options.page.toString());
    if (options.pageSize) queryParams.append('page_size', options.pageSize.toString());
  }
  
  const query = queryParams.toString() ? `?${queryParams.toString()}` : '';
  return apiClient<PaginatedResponse<Scope>>(`/resources/${resourceId}/scopes${query}`);
};

/**
 * Crée un nouveau scope pour une ressource API
 */
export const createResourceScope = async (
  resourceId: string,
  scopeData: {
    name: string;
    description?: string;
  }
): Promise<Scope> => {
  return apiClient<Scope>(`/resources/${resourceId}/scopes`, {
    method: 'POST',
    body: JSON.stringify(scopeData),
  });
};

/**
 * Met à jour un scope de ressource API
 */
export const updateResourceScope = async (
  resourceId: string,
  scopeId: string,
  scopeData: {
    description?: string;
  }
): Promise<Scope> => {
  return apiClient<Scope>(`/resources/${resourceId}/scopes/${scopeId}`, {
    method: 'PATCH',
    body: JSON.stringify(scopeData),
  });
};

/**
 * Supprime un scope de ressource API
 */
export const deleteResourceScope = async (
  resourceId: string,
  scopeId: string
): Promise<void> => {
  return apiClient<void>(`/resources/${resourceId}/scopes/${scopeId}`, {
    method: 'DELETE',
  });
}; 