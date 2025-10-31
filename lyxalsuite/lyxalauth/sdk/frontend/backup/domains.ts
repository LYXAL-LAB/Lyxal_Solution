import { apiClient } from './config';
import { PaginationOptions, PaginatedResponse } from './types';

interface Domain {
  id: string;
  domain: string;
  status: 'PendingVerification' | 'Active' | 'Error';
  dnsRecords: Array<{
    type: string;
    name: string;
    value: string;
  }>;
  errorMessage?: string;
  createdAt: string;
}

/**
 * Récupère la liste des domaines
 */
export const getDomains = async (
  options?: PaginationOptions
): Promise<PaginatedResponse<Domain>> => {
  const queryParams = new URLSearchParams();
  
  if (options) {
    if (options.page) queryParams.append('page', options.page.toString());
    if (options.pageSize) queryParams.append('page_size', options.pageSize.toString());
  }
  
  const query = queryParams.toString() ? `?${queryParams.toString()}` : '';
  return apiClient<PaginatedResponse<Domain>>(`/domains${query}`);
};

/**
 * Crée un nouveau domaine
 */
export const createDomain = async (
  domainData: {
    domain: string;
  }
): Promise<Domain> => {
  return apiClient<Domain>('/domains', {
    method: 'POST',
    body: JSON.stringify(domainData),
  });
};

/**
 * Récupère un domaine par son ID
 */
export const getDomain = async (domainId: string): Promise<Domain> => {
  return apiClient<Domain>(`/domains/${domainId}`);
};

/**
 * Supprime un domaine
 */
export const deleteDomain = async (domainId: string): Promise<void> => {
  return apiClient<void>(`/domains/${domainId}`, {
    method: 'DELETE',
  });
};

/**
 * Vérifie un domaine
 */
export const verifyDomain = async (domainId: string): Promise<Domain> => {
  return apiClient<Domain>(`/domains/${domainId}/verify`, {
    method: 'POST',
  });
}; 