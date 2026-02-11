import { apiClient } from './config';
import { Organization, OrganizationRole, OrganizationInvitation, PaginationOptions, PaginatedResponse } from './types';

/**
 * Récupère la liste des organisations
 */
export const getOrganizations = async (
  options?: PaginationOptions & { search?: string }
): Promise<PaginatedResponse<Organization>> => {
  const queryParams = new URLSearchParams();
  
  if (options) {
    if (options.page) queryParams.append('page', options.page.toString());
    if (options.pageSize) queryParams.append('page_size', options.pageSize.toString());
    if (options.search) queryParams.append('search', options.search);
  }
  
  const query = queryParams.toString() ? `?${queryParams.toString()}` : '';
  return apiClient<PaginatedResponse<Organization>>(`/organizations${query}`);
};

/**
 * Récupère une organisation par son ID
 */
export const getOrganization = async (organizationId: string): Promise<Organization> => {
  return apiClient<Organization>(`/organizations/${organizationId}`);
};

/**
 * Crée une nouvelle organisation
 */
export const createOrganization = async (organizationData: {
  name: string;
  description?: string;
  logo?: string;
}): Promise<Organization> => {
  return apiClient<Organization>('/organizations', {
    method: 'POST',
    body: JSON.stringify(organizationData),
  });
};

/**
 * Met à jour une organisation
 */
export const updateOrganization = async (
  organizationId: string,
  organizationData: {
    name?: string;
    description?: string;
    logo?: string;
  }
): Promise<Organization> => {
  return apiClient<Organization>(`/organizations/${organizationId}`, {
    method: 'PATCH',
    body: JSON.stringify(organizationData),
  });
};

/**
 * Supprime une organisation
 */
export const deleteOrganization = async (organizationId: string): Promise<void> => {
  return apiClient<void>(`/organizations/${organizationId}`, {
    method: 'DELETE',
  });
};

/**
 * Récupère les membres d'une organisation
 */
export const getOrganizationUsers = async (
  organizationId: string,
  options?: PaginationOptions
): Promise<PaginatedResponse<{ userId: string }>> => {
  const queryParams = new URLSearchParams();
  
  if (options) {
    if (options.page) queryParams.append('page', options.page.toString());
    if (options.pageSize) queryParams.append('page_size', options.pageSize.toString());
  }
  
  const query = queryParams.toString() ? `?${queryParams.toString()}` : '';
  return apiClient<PaginatedResponse<{ userId: string }>>(`/organizations/${organizationId}/users${query}`);
};

/**
 * Ajoute des membres à une organisation
 */
export const addUsersToOrganization = async (
  organizationId: string,
  userIds: string[]
): Promise<{ userIds: string[] }> => {
  return apiClient<{ userIds: string[] }>(`/organizations/${organizationId}/users`, {
    method: 'POST',
    body: JSON.stringify({ userIds }),
  });
};

/**
 * Retire un membre d'une organisation
 */
export const removeUserFromOrganization = async (
  organizationId: string,
  userId: string
): Promise<void> => {
  return apiClient<void>(`/organizations/${organizationId}/users/${userId}`, {
    method: 'DELETE',
  });
};

/**
 * Récupère les rôles d'un utilisateur dans une organisation
 */
export const getUserOrganizationRoles = async (
  organizationId: string,
  userId: string
): Promise<{ roleIds: string[] }> => {
  return apiClient<{ roleIds: string[] }>(`/organizations/${organizationId}/users/${userId}/roles`);
};

/**
 * Met à jour les rôles d'un utilisateur dans une organisation
 */
export const updateUserOrganizationRoles = async (
  organizationId: string,
  userId: string,
  roleIds: string[]
): Promise<{ roleIds: string[] }> => {
  return apiClient<{ roleIds: string[] }>(`/organizations/${organizationId}/users/${userId}/roles`, {
    method: 'PUT',
    body: JSON.stringify({ roleIds }),
  });
};

/**
 * Récupère les rôles d'une organisation
 */
export const getOrganizationRoles = async (
  organizationId: string,
  options?: PaginationOptions & { search?: string }
): Promise<PaginatedResponse<OrganizationRole>> => {
  const queryParams = new URLSearchParams();
  
  if (options) {
    if (options.page) queryParams.append('page', options.page.toString());
    if (options.pageSize) queryParams.append('page_size', options.pageSize.toString());
    if (options.search) queryParams.append('search', options.search);
  }
  
  const query = queryParams.toString() ? `?${queryParams.toString()}` : '';
  return apiClient<PaginatedResponse<OrganizationRole>>(`/organizations/${organizationId}/roles${query}`);
};

/**
 * Crée un rôle d'organisation
 */
export const createOrganizationRole = async (
  organizationId: string,
  roleData: {
    name: string;
    description?: string;
  }
): Promise<OrganizationRole> => {
  return apiClient<OrganizationRole>(`/organizations/${organizationId}/roles`, {
    method: 'POST',
    body: JSON.stringify(roleData),
  });
};

/**
 * Récupère un rôle d'organisation
 */
export const getOrganizationRole = async (
  organizationId: string,
  roleId: string
): Promise<OrganizationRole> => {
  return apiClient<OrganizationRole>(`/organizations/${organizationId}/roles/${roleId}`);
};

/**
 * Met à jour un rôle d'organisation
 */
export const updateOrganizationRole = async (
  organizationId: string,
  roleId: string,
  roleData: {
    name?: string;
    description?: string;
  }
): Promise<OrganizationRole> => {
  return apiClient<OrganizationRole>(`/organizations/${organizationId}/roles/${roleId}`, {
    method: 'PATCH',
    body: JSON.stringify(roleData),
  });
};

/**
 * Supprime un rôle d'organisation
 */
export const deleteOrganizationRole = async (
  organizationId: string,
  roleId: string
): Promise<void> => {
  return apiClient<void>(`/organizations/${organizationId}/roles/${roleId}`, {
    method: 'DELETE',
  });
};

/**
 * Récupère les invitations d'une organisation
 */
export const getOrganizationInvitations = async (
  organizationId: string,
  options?: PaginationOptions
): Promise<PaginatedResponse<OrganizationInvitation>> => {
  const queryParams = new URLSearchParams();
  
  if (options) {
    if (options.page) queryParams.append('page', options.page.toString());
    if (options.pageSize) queryParams.append('page_size', options.pageSize.toString());
  }
  
  const query = queryParams.toString() ? `?${queryParams.toString()}` : '';
  return apiClient<PaginatedResponse<OrganizationInvitation>>(`/organizations/${organizationId}/invitations${query}`);
};

/**
 * Crée une invitation d'organisation
 */
export const createOrganizationInvitation = async (
  organizationId: string,
  invitationData: {
    email: string;
    roleIds?: string[];
  }
): Promise<OrganizationInvitation> => {
  return apiClient<OrganizationInvitation>(`/organizations/${organizationId}/invitations`, {
    method: 'POST',
    body: JSON.stringify(invitationData),
  });
};

/**
 * Renvoie une invitation
 */
export const resendOrganizationInvitation = async (
  organizationId: string,
  invitationId: string
): Promise<{ success: boolean }> => {
  return apiClient<{ success: boolean }>(`/organizations/${organizationId}/invitations/${invitationId}/resend`, {
    method: 'POST',
  });
};

/**
 * Supprime une invitation
 */
export const deleteOrganizationInvitation = async (
  organizationId: string,
  invitationId: string
): Promise<void> => {
  return apiClient<void>(`/organizations/${organizationId}/invitations/${invitationId}`, {
    method: 'DELETE',
  });
}; 