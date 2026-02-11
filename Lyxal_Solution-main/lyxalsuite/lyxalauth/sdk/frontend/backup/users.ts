import { apiClient } from './config';
import { User, PaginationOptions, PaginatedResponse } from './types';

/**
 * Récupère la liste des utilisateurs
 */
export const getUsers = async (
  options?: PaginationOptions & { 
    search?: string;
    sort?: string;
    filter?: string;
  }
): Promise<PaginatedResponse<User>> => {
  const queryParams = new URLSearchParams();
  
  if (options) {
    if (options.page) queryParams.append('page', options.page.toString());
    if (options.pageSize) queryParams.append('page_size', options.pageSize.toString());
    if (options.search) queryParams.append('search', options.search);
    if (options.sort) queryParams.append('sort', options.sort);
    if (options.filter) queryParams.append('filter', options.filter);
  }
  
  const query = queryParams.toString() ? `?${queryParams.toString()}` : '';
  return apiClient<PaginatedResponse<User>>(`/users${query}`);
};

/**
 * Récupère un utilisateur par son ID
 */
export const getUser = async (userId: string): Promise<User> => {
  return apiClient<User>(`/users/${userId}`);
};

/**
 * Crée un nouvel utilisateur
 */
export const createUser = async (userData: {
  username?: string;
  primaryEmail?: string;
  primaryPhone?: string;
  name?: string;
  password?: string;
  customData?: Record<string, any>;
}): Promise<User> => {
  return apiClient<User>('/users', {
    method: 'POST',
    body: JSON.stringify(userData),
  });
};

/**
 * Met à jour un utilisateur
 */
export const updateUser = async (
  userId: string,
  userData: {
    username?: string;
    primaryEmail?: string;
    primaryPhone?: string;
    name?: string;
    customData?: Record<string, any>;
  }
): Promise<User> => {
  return apiClient<User>(`/users/${userId}`, {
    method: 'PATCH',
    body: JSON.stringify(userData),
  });
};

/**
 * Supprime un utilisateur
 */
export const deleteUser = async (userId: string): Promise<void> => {
  return apiClient<void>(`/users/${userId}`, {
    method: 'DELETE',
  });
};

/**
 * Récupère les rôles d'un utilisateur
 */
export const getUserRoles = async (userId: string): Promise<{ roleIds: string[] }> => {
  return apiClient<{ roleIds: string[] }>(`/users/${userId}/roles`);
};

/**
 * Met à jour les rôles d'un utilisateur
 */
export const updateUserRoles = async (
  userId: string,
  roleIds: string[]
): Promise<{ roleIds: string[] }> => {
  return apiClient<{ roleIds: string[] }>(`/users/${userId}/roles`, {
    method: 'PUT',
    body: JSON.stringify({ roleIds }),
  });
};

/**
 * Ajoute des rôles à un utilisateur
 */
export const assignRolesToUser = async (
  userId: string,
  roleIds: string[]
): Promise<{ roleIds: string[] }> => {
  return apiClient<{ roleIds: string[] }>(`/users/${userId}/roles`, {
    method: 'POST',
    body: JSON.stringify({ roleIds }),
  });
};

/**
 * Retire un rôle d'un utilisateur
 */
export const removeRoleFromUser = async (
  userId: string,
  roleId: string
): Promise<void> => {
  return apiClient<void>(`/users/${userId}/roles/${roleId}`, {
    method: 'DELETE',
  });
};

/**
 * Met à jour le mot de passe d'un utilisateur
 */
export const updateUserPassword = async (
  userId: string,
  password: string
): Promise<void> => {
  return apiClient<void>(`/users/${userId}/password`, {
    method: 'PATCH',
    body: JSON.stringify({ password }),
  });
};

/**
 * Vérifie si un utilisateur a un mot de passe
 */
export const checkUserHasPassword = async (userId: string): Promise<{ hasPassword: boolean }> => {
  return apiClient<{ hasPassword: boolean }>(`/users/${userId}/has-password`);
};

/**
 * Désactive ou réactive un utilisateur
 */
export const updateUserSuspensionStatus = async (
  userId: string,
  isSuspended: boolean
): Promise<User> => {
  return apiClient<User>(`/users/${userId}/suspension-status`, {
    method: 'PATCH',
    body: JSON.stringify({ isSuspended }),
  });
};

/**
 * Obtient les identités sociales d'un utilisateur
 */
export const getUserSocialIdentities = async (userId: string): Promise<Record<string, any>> => {
  return apiClient<Record<string, any>>(`/users/${userId}/identities`);
};

/**
 * Supprime une identité sociale d'un utilisateur
 */
export const deleteSocialIdentity = async (
  userId: string,
  target: string
): Promise<void> => {
  return apiClient<void>(`/users/${userId}/identities/${target}`, {
    method: 'DELETE',
  });
}; 