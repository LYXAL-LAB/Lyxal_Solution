import { apiClient } from './config';
import { Application, PaginationOptions, PaginatedResponse } from './types';

/**
 * Récupère la liste des applications
 */
export const getApplications = async (
  options?: PaginationOptions & { search?: string }
): Promise<PaginatedResponse<Application>> => {
  const queryParams = new URLSearchParams();
  
  if (options) {
    if (options.page) queryParams.append('page', options.page.toString());
    if (options.pageSize) queryParams.append('page_size', options.pageSize.toString());
    if (options.search) queryParams.append('search', options.search);
  }
  
  const query = queryParams.toString() ? `?${queryParams.toString()}` : '';
  return apiClient<PaginatedResponse<Application>>(`/applications${query}`);
};

/**
 * Récupère une application par son ID
 */
export const getApplication = async (applicationId: string): Promise<Application> => {
  return apiClient<Application>(`/applications/${applicationId}`);
};

/**
 * Crée une nouvelle application
 */
export const createApplication = async (applicationData: {
  name: string;
  description?: string;
  type: 'spa' | 'traditional' | 'native' | 'machine_to_machine';
  oidcClientMetadata?: {
    redirectUris?: string[];
    postLogoutRedirectUris?: string[];
    clientUri?: string;
    logoUri?: string;
  };
  customClientMetadata?: Record<string, any>;
}): Promise<Application> => {
  return apiClient<Application>('/applications', {
    method: 'POST',
    body: JSON.stringify(applicationData),
  });
};

/**
 * Met à jour une application
 */
export const updateApplication = async (
  applicationId: string,
  applicationData: {
    name?: string;
    description?: string;
    oidcClientMetadata?: {
      redirectUris?: string[];
      postLogoutRedirectUris?: string[];
      clientUri?: string;
      logoUri?: string;
    };
  }
): Promise<Application> => {
  return apiClient<Application>(`/applications/${applicationId}`, {
    method: 'PATCH',
    body: JSON.stringify(applicationData),
  });
};

/**
 * Supprime une application
 */
export const deleteApplication = async (applicationId: string): Promise<void> => {
  return apiClient<void>(`/applications/${applicationId}`, {
    method: 'DELETE',
  });
};

/**
 * Met à jour les données personnalisées d'une application
 */
export const updateApplicationCustomData = async (
  applicationId: string,
  customData: Record<string, any>
): Promise<Application> => {
  return apiClient<Application>(`/applications/${applicationId}/custom-data`, {
    method: 'PATCH',
    body: JSON.stringify(customData),
  });
};

/**
 * Récupère les rôles d'API d'une application
 */
export const getApplicationApiResourceRoles = async (
  applicationId: string
): Promise<{ roleIds: string[] }> => {
  return apiClient<{ roleIds: string[] }>(`/applications/${applicationId}/roles`);
};

/**
 * Met à jour les rôles d'API d'une application
 */
export const updateApplicationApiResourceRoles = async (
  applicationId: string,
  roleIds: string[]
): Promise<{ roleIds: string[] }> => {
  return apiClient<{ roleIds: string[] }>(`/applications/${applicationId}/roles`, {
    method: 'PUT',
    body: JSON.stringify({ roleIds }),
  });
};

/**
 * Assigne des rôles d'API à une application
 */
export const assignApiResourceRolesToApplication = async (
  applicationId: string,
  roleIds: string[]
): Promise<{ roleIds: string[] }> => {
  return apiClient<{ roleIds: string[] }>(`/applications/${applicationId}/roles`, {
    method: 'POST',
    body: JSON.stringify({ roleIds }),
  });
};

/**
 * Supprime un rôle d'API d'une application
 */
export const removeApiResourceRoleFromApplication = async (
  applicationId: string,
  roleId: string
): Promise<void> => {
  return apiClient<void>(`/applications/${applicationId}/roles/${roleId}`, {
    method: 'DELETE',
  });
};

/**
 * Récupère les domaines personnalisés d'une application
 */
export const getApplicationCustomDomains = async (
  applicationId: string
): Promise<{ domains: string[] }> => {
  return apiClient<{ domains: string[] }>(`/applications/${applicationId}/custom-domains`);
};

/**
 * Ajoute un domaine personnalisé à une application
 */
export const addCustomDomainToApplication = async (
  applicationId: string,
  domain: string
): Promise<{ domains: string[] }> => {
  return apiClient<{ domains: string[] }>(`/applications/${applicationId}/custom-domains`, {
    method: 'POST',
    body: JSON.stringify({ domain }),
  });
};

/**
 * Supprime un domaine personnalisé d'une application
 */
export const removeCustomDomainFromApplication = async (
  applicationId: string,
  domain: string
): Promise<void> => {
  return apiClient<void>(`/applications/${applicationId}/custom-domains/${domain}`, {
    method: 'DELETE',
  });
};

/**
 * Récupère les secrets d'une application
 */
export const getApplicationSecrets = async (
  applicationId: string
): Promise<{ secrets: Array<{ id: string; createdAt: string }> }> => {
  return apiClient<{ secrets: Array<{ id: string; createdAt: string }> }>(
    `/applications/${applicationId}/secrets`
  );
};

/**
 * Ajoute un secret à une application
 */
export const addApplicationSecret = async (
  applicationId: string
): Promise<{ id: string; secret: string; createdAt: string }> => {
  return apiClient<{ id: string; secret: string; createdAt: string }>(
    `/applications/${applicationId}/secrets`,
    {
      method: 'POST',
    }
  );
};

/**
 * Supprime un secret d'une application
 */
export const deleteApplicationSecret = async (
  applicationId: string,
  secretId: string
): Promise<void> => {
  return apiClient<void>(`/applications/${applicationId}/secrets/${secretId}`, {
    method: 'DELETE',
  });
}; 