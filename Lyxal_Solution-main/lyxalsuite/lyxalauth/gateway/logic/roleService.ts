/**
 * Service pour gérer les interactions avec l'API Logto concernant les rôles
 */

// Types pour les différentes opérations de rôles

/**
 * Type pour la création d'un rôle
 */
type CreateRoleParams = {
  name: string;
  description?: string;
};

/**
 * Type pour la mise à jour d'un rôle
 */
type UpdateRoleParams = {
  name?: string;
  description?: string;
};

/**
 * Type pour l'assignation de rôles à des utilisateurs
 */
type AssignRoleToUsersParams = {
  userIds: string[];
};

/**
 * Type pour l'assignation de rôles à des applications
 */
type AssignRoleToApplicationsParams = {
  applicationIds: string[];
};

/**
 * Type pour lier des scopes à un rôle
 */
type LinkScopesToRoleParams = {
  scopeIds: string[];
};

/**
 * Récupère tous les rôles
 * @param page Page à récupérer (par défaut: 1)
 * @param pageSize Nombre d'éléments par page (par défaut: 20)
 */
export async function getRoles(page: number = 1, pageSize: number = 20) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/roles?page=${page}&page_size=${pageSize}`, {
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
 * Crée un nouveau rôle
 */
export async function createRole(data: CreateRoleParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/roles`, {
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
 * Récupère un rôle par son ID
 */
export async function getRole(roleId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/roles/${roleId}`, {
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
 * Supprime un rôle
 */
export async function deleteRole(roleId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/roles/${roleId}`, {
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
 * Met à jour un rôle
 */
export async function updateRole(roleId: string, data: UpdateRoleParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/roles/${roleId}`, {
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
 * Récupère les utilisateurs ayant un rôle spécifique
 */
export async function getRoleUsers(roleId: string, page: number = 1, pageSize: number = 20) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/roles/${roleId}/users?page=${page}&page_size=${pageSize}`, {
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
 * Assigne un rôle à des utilisateurs
 */
export async function assignRoleToUsers(roleId: string, data: AssignRoleToUsersParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/roles/${roleId}/users`, {
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
 * Supprime un rôle d'un utilisateur
 */
export async function removeRoleFromUser(roleId: string, userId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/roles/${roleId}/users/${userId}`, {
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
 * Récupère les applications ayant un rôle spécifique
 */
export async function getRoleApplications(roleId: string, page: number = 1, pageSize: number = 20) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/roles/${roleId}/applications?page=${page}&page_size=${pageSize}`, {
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
 * Assigne un rôle à des applications
 */
export async function assignRoleToApplications(roleId: string, data: AssignRoleToApplicationsParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/roles/${roleId}/applications`, {
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
 * Supprime un rôle d'une application
 */
export async function removeRoleFromApplication(roleId: string, applicationId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/roles/${roleId}/applications/${applicationId}`, {
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
 * Récupère les scopes d'un rôle
 */
export async function getRoleScopes(roleId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/roles/${roleId}/scopes`, {
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
 * Lie des scopes à un rôle
 */
export async function linkScopesToRole(roleId: string, data: LinkScopesToRoleParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/roles/${roleId}/scopes`, {
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
 * Supprime un scope d'un rôle
 */
export async function unlinkScopeFromRole(roleId: string, scopeId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/roles/${roleId}/scopes/${scopeId}`, {
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
