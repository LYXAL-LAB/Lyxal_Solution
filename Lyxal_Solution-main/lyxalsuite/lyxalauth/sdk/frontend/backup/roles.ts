import { apiClient } from './config';
import { Role, PaginationOptions, PaginatedResponse } from './types';

/**
 * Récupère la liste des rôles
 */
export const getRoles = async (
  options?: PaginationOptions & { search?: string }
): Promise<PaginatedResponse<Role>> => {
  const queryParams = new URLSearchParams();
  
  if (options) {
    if (options.page) queryParams.append('page', options.page.toString());
    if (options.pageSize) queryParams.append('page_size', options.pageSize.toString());
    if (options.search) queryParams.append('search', options.search);
  }
  
  const query = queryParams.toString() ? `?${queryParams.toString()}` : '';
  return apiClient<PaginatedResponse<Role>>(`/roles${query}`);
};

/**
 * Récupère un rôle par son ID
 */
export const getRole = async (roleId: string): Promise<Role> => {
  return apiClient<Role>(`/roles/${roleId}`);
};

/**
 * Crée un nouveau rôle
 */
export const createRole = async (roleData: {
  name: string;
  description?: string;
}): Promise<Role> => {
  return apiClient<Role>('/roles', {
    method: 'POST',
    body: JSON.stringify(roleData),
  });
};

/**
 * Met à jour un rôle
 */
export const updateRole = async (
  roleId: string,
  roleData: {
    name?: string;
    description?: string;
  }
): Promise<Role> => {
  return apiClient<Role>(`/roles/${roleId}`, {
    method: 'PATCH',
    body: JSON.stringify(roleData),
  });
};

/**
 * Supprime un rôle
 */
export const deleteRole = async (roleId: string): Promise<void> => {
  return apiClient<void>(`/roles/${roleId}`, {
    method: 'DELETE',
  });
};

/**
 * Récupère les utilisateurs assignés à un rôle
 */
export const getRoleUsers = async (
  roleId: string,
  options?: PaginationOptions
): Promise<PaginatedResponse<{ userId: string }>> => {
  const queryParams = new URLSearchParams();
  
  if (options) {
    if (options.page) queryParams.append('page', options.page.toString());
    if (options.pageSize) queryParams.append('page_size', options.pageSize.toString());
  }
  
  const query = queryParams.toString() ? `?${queryParams.toString()}` : '';
  return apiClient<PaginatedResponse<{ userId: string }>>(`/roles/${roleId}/users${query}`);
};

/**
 * Assigne un rôle à des utilisateurs
 */
export const assignRoleToUsers = async (
  roleId: string,
  userIds: string[]
): Promise<{ userIds: string[] }> => {
  return apiClient<{ userIds: string[] }>(`/roles/${roleId}/users`, {
    method: 'POST',
    body: JSON.stringify({ userIds }),
  });
};

/**
 * Retire un rôle d'un utilisateur
 */
export const removeRoleFromUser = async (
  roleId: string,
  userId: string
): Promise<void> => {
  return apiClient<void>(`/roles/${roleId}/users/${userId}`, {
    method: 'DELETE',
  });
};

/**
 * Récupère les applications assignées à un rôle
 */
export const getRoleApplications = async (
  roleId: string,
  options?: PaginationOptions
): Promise<PaginatedResponse<{ applicationId: string }>> => {
  const queryParams = new URLSearchParams();
  
  if (options) {
    if (options.page) queryParams.append('page', options.page.toString());
    if (options.pageSize) queryParams.append('page_size', options.pageSize.toString());
  }
  
  const query = queryParams.toString() ? `?${queryParams.toString()}` : '';
  return apiClient<PaginatedResponse<{ applicationId: string }>>(`/roles/${roleId}/applications${query}`);
};

/**
 * Récupère les scopes d'un rôle
 */
export const getRoleScopes = async (
  roleId: string
): Promise<{ scopes: string[] }> => {
  return apiClient<{ scopes: string[] }>(`/roles/${roleId}/scopes`);
};

/**
 * Assigne des scopes à un rôle
 */
export const assignScopesToRole = async (
  roleId: string,
  scopes: string[]
): Promise<{ scopes: string[] }> => {
  return apiClient<{ scopes: string[] }>(`/roles/${roleId}/scopes`, {
    method: 'POST',
    body: JSON.stringify({ scopes }),
  });
};

/**
 * Retire un scope d'un rôle
 */
export const removeScopeFromRole = async (
  roleId: string,
  scope: string
): Promise<void> => {
  return apiClient<void>(`/roles/${roleId}/scopes/${scope}`, {
    method: 'DELETE',
  });
};