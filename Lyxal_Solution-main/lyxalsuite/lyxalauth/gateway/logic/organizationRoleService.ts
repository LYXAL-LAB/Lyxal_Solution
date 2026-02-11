/**
 * Service pour gérer les interactions avec l'API Logto concernant les rôles d'organisation
 */

// Types pour les différentes opérations de rôles d'organisation

/**
 * Type pour la création d'un rôle d'organisation
 */
type CreateOrganizationRoleParams = {
  organizationId: string;
  name: string;
  description?: string;
};

/**
 * Type pour la mise à jour d'un rôle d'organisation
 */
type UpdateOrganizationRoleParams = {
  name?: string;
  description?: string;
};

/**
 * Type pour l'attribution de scopes à un rôle d'organisation
 */
type AssignOrganizationScopesParams = {
  scopes: string[];
};

/**
 * Type pour l'attribution de scopes de ressource à un rôle d'organisation
 */
type AssignResourceScopesParams = {
  resourceScopes: Array<{
    resourceId: string;
    scopeIds: string[];
  }>;
};

/**
 * Récupère tous les rôles d'une organisation
 * @param organizationId ID de l'organisation
 * @param page Page à récupérer (par défaut: 1)
 * @param pageSize Nombre d'éléments par page (par défaut: 20)
 */
export async function getOrganizationRoles(organizationId: string, page: number = 1, pageSize: number = 20) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}/roles?page=${page}&page_size=${pageSize}`, {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${process.env.LOGTO_TOKEN}`
    }
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
}

/**
 * Récupère un rôle d'organisation par son ID
 */
export async function getOrganizationRole(organizationId: string, roleId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}/roles/${roleId}`, {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${process.env.LOGTO_TOKEN}`
    }
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
}

/**
 * Crée un nouveau rôle d'organisation
 */
export async function createOrganizationRole(data: CreateOrganizationRoleParams) {
  const { organizationId, ...roleData } = data;
  
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}/roles`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${process.env.LOGTO_TOKEN}`
    },
    body: JSON.stringify(roleData)
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
}

/**
 * Supprime un rôle d'organisation
 */
export async function deleteOrganizationRole(organizationId: string, roleId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}/roles/${roleId}`, {
    method: 'DELETE',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${process.env.LOGTO_TOKEN}`
    }
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
}

/**
 * Met à jour un rôle d'organisation
 */
export async function updateOrganizationRole(organizationId: string, roleId: string, data: UpdateOrganizationRoleParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}/roles/${roleId}`, {
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${process.env.LOGTO_TOKEN}`
    },
    body: JSON.stringify(data)
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
}

/**
 * Récupère les scopes d'un rôle d'organisation
 */
export async function getOrganizationRoleScopes(organizationId: string, roleId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}/roles/${roleId}/scopes`, {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${process.env.LOGTO_TOKEN}`
    }
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
}

/**
 * Remplace les scopes d'un rôle d'organisation
 */
export async function replaceOrganizationRoleScopes(organizationId: string, roleId: string, data: AssignOrganizationScopesParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}/roles/${roleId}/scopes`, {
    method: 'PUT',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${process.env.LOGTO_TOKEN}`
    },
    body: JSON.stringify(data)
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
}

/**
 * Attribue des scopes à un rôle d'organisation
 */
export async function assignOrganizationRoleScopes(organizationId: string, roleId: string, data: AssignOrganizationScopesParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}/roles/${roleId}/scopes`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${process.env.LOGTO_TOKEN}`
    },
    body: JSON.stringify(data)
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
}

/**
 * Supprime un scope d'un rôle d'organisation
 */
export async function removeOrganizationRoleScope(organizationId: string, roleId: string, scopeId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}/roles/${roleId}/scopes/${scopeId}`, {
    method: 'DELETE',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${process.env.LOGTO_TOKEN}`
    }
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
}

/**
 * Récupère les scopes de ressource d'un rôle d'organisation
 */
export async function getOrganizationRoleResourceScopes(organizationId: string, roleId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}/roles/${roleId}/resource-scopes`, {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${process.env.LOGTO_TOKEN}`
    }
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
}

/**
 * Remplace les scopes de ressource d'un rôle d'organisation
 */
export async function replaceOrganizationRoleResourceScopes(organizationId: string, roleId: string, data: AssignResourceScopesParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}/roles/${roleId}/resource-scopes`, {
    method: 'PUT',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${process.env.LOGTO_TOKEN}`
    },
    body: JSON.stringify(data)
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
}

/**
 * Attribue des scopes de ressource à un rôle d'organisation
 */
export async function assignOrganizationRoleResourceScopes(organizationId: string, roleId: string, data: AssignResourceScopesParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}/roles/${roleId}/resource-scopes`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${process.env.LOGTO_TOKEN}`
    },
    body: JSON.stringify(data)
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
}

/**
 * Supprime un scope de ressource d'un rôle d'organisation
 */
export async function removeOrganizationRoleResourceScope(organizationId: string, roleId: string, resourceId: string, scopeId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}/roles/${roleId}/resource-scopes/${resourceId}/${scopeId}`, {
    method: 'DELETE',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${process.env.LOGTO_TOKEN}`
    }
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
} 
