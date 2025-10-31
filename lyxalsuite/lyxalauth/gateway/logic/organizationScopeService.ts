/**
 * Service pour gérer les interactions avec l'API Logto concernant les scopes d'organisation
 */

// Types pour les différentes opérations de scopes d'organisation

/**
 * Type pour la création d'un scope d'organisation
 */
type CreateOrganizationScopeParams = {
  organizationId: string;
  name: string;
  description?: string;
};

/**
 * Type pour la mise à jour d'un scope d'organisation
 */
type UpdateOrganizationScopeParams = {
  name?: string;
  description?: string;
};

/**
 * Récupère tous les scopes d'une organisation
 * @param organizationId ID de l'organisation
 * @param page Page à récupérer (par défaut: 1)
 * @param pageSize Nombre d'éléments par page (par défaut: 20)
 */
export async function getOrganizationScopes(organizationId: string, page: number = 1, pageSize: number = 20) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}/scopes?page=${page}&page_size=${pageSize}`, {
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
 * Récupère un scope d'organisation par son ID
 */
export async function getOrganizationScope(organizationId: string, scopeId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}/scopes/${scopeId}`, {
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
 * Crée un nouveau scope d'organisation
 */
export async function createOrganizationScope(data: CreateOrganizationScopeParams) {
  const { organizationId, ...scopeData } = data;
  
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}/scopes`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${process.env.LOGTO_TOKEN}`
    },
    body: JSON.stringify(scopeData)
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
}

/**
 * Supprime un scope d'organisation
 */
export async function deleteOrganizationScope(organizationId: string, scopeId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}/scopes/${scopeId}`, {
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
 * Met à jour un scope d'organisation
 */
export async function updateOrganizationScope(organizationId: string, scopeId: string, data: UpdateOrganizationScopeParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}/scopes/${scopeId}`, {
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
