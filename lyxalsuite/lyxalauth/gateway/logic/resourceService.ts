/**
 * Service pour gérer les interactions avec l'API Logto concernant les ressources API
 */

// Types pour les différentes opérations de ressources API

/**
 * Type pour la création d'une ressource API
 */
type CreateResourceParams = {
  name: string;
  indicator: string;
  accessTokenTtl?: number;
  isDefault?: boolean;
};

/**
 * Type pour la mise à jour d'une ressource API
 */
type UpdateResourceParams = {
  name?: string;
  accessTokenTtl?: number;
};

/**
 * Type pour définir une ressource API comme défaut
 */
type SetResourceAsDefaultParams = {
  isDefault: boolean;
};

/**
 * Type pour la création d'un scope de ressource API
 */
type CreateResourceScopeParams = {
  name: string;
  description?: string;
};

/**
 * Type pour la mise à jour d'un scope de ressource API
 */
type UpdateResourceScopeParams = {
  name?: string;
  description?: string;
};

/**
 * Récupère toutes les ressources API
 * @param page Page à récupérer (par défaut: 1)
 * @param pageSize Nombre d'éléments par page (par défaut: 20)
 */
export async function getResources(page: number = 1, pageSize: number = 20) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/resources?page=${page}&page_size=${pageSize}`, {
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
 * Crée une nouvelle ressource API
 */
export async function createResource(data: CreateResourceParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/resources`, {
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
 * Récupère une ressource API par son ID
 */
export async function getResource(resourceId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/resources/${resourceId}`, {
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
 * Supprime une ressource API
 */
export async function deleteResource(resourceId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/resources/${resourceId}`, {
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
 * Met à jour une ressource API
 */
export async function updateResource(resourceId: string, data: UpdateResourceParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/resources/${resourceId}`, {
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
 * Définit une ressource API comme défaut
 */
export async function setResourceAsDefault(resourceId: string, data: SetResourceAsDefaultParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/resources/${resourceId}/is-default`, {
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
 * Récupère les scopes d'une ressource API
 */
export async function getResourceScopes(resourceId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/resources/${resourceId}/scopes`, {
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
 * Crée un nouveau scope pour une ressource API
 */
export async function createResourceScope(resourceId: string, data: CreateResourceScopeParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/resources/${resourceId}/scopes`, {
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
 * Supprime un scope d'une ressource API
 */
export async function deleteResourceScope(resourceId: string, scopeId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/resources/${resourceId}/scopes/${scopeId}`, {
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
 * Met à jour un scope d'une ressource API
 */
export async function updateResourceScope(resourceId: string, scopeId: string, data: UpdateResourceScopeParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/resources/${resourceId}/scopes/${scopeId}`, {
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
