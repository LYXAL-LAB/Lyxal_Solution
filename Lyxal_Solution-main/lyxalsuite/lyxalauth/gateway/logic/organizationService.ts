/**
 * Service pour gérer les interactions avec l'API Logto concernant les organisations
 */

// Types pour les différentes opérations d'organisations

/**
 * Type pour la création d'une organisation
 */
type CreateOrganizationParams = {
  name: string;
  description?: string;
};

/**
 * Type pour la mise à jour d'une organisation
 */
type UpdateOrganizationParams = {
  name?: string;
  description?: string;
};

/**
 * Type pour l'ajout/attribution de membres utilisateurs à une organisation
 */
type OrganizationUserMembersParams = {
  userIds: string[];
};

/**
 * Type pour l'attribution de rôles à des utilisateurs dans une organisation
 */
type AssignRolesToUserParams = {
  roleIds: string[];
};

/**
 * Type pour l'ajout/attribution d'applications à une organisation
 */
type OrganizationApplicationsParams = {
  applicationIds: string[];
};

/**
 * Type pour l'attribution de rôles à des applications dans une organisation
 */
type AssignRolesToApplicationParams = {
  roleIds: string[];
};

/**
 * Type pour la gestion des domaines email JIT
 */
type JitEmailDomainsParams = {
  domains: string[];
};

/**
 * Type pour la gestion des rôles par défaut JIT
 */
type JitDefaultRolesParams = {
  roleIds: string[];
};

/**
 * Type pour la gestion des connecteurs SSO JIT
 */
type JitSsoConnectorsParams = {
  connectorIds: string[];
};

/**
 * Récupère toutes les organisations
 * @param page Page à récupérer (par défaut: 1)
 * @param pageSize Nombre d'éléments par page (par défaut: 20)
 */
export async function getOrganizations(page: number = 1, pageSize: number = 20) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations?page=${page}&page_size=${pageSize}`, {
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
 * Récupère une organisation par son ID
 */
export async function getOrganization(organizationId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}`, {
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
 * Crée une nouvelle organisation
 */
export async function createOrganization(data: CreateOrganizationParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations`, {
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
 * Met à jour une organisation
 */
export async function updateOrganization(organizationId: string, data: UpdateOrganizationParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}`, {
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
 * Supprime une organisation
 */
export async function deleteOrganization(organizationId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}`, {
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

// Gestion des membres utilisateurs

/**
 * Récupère les membres utilisateurs d'une organisation
 */
export async function getOrganizationUserMembers(organizationId: string, page: number = 1, pageSize: number = 20) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}/users?page=${page}&page_size=${pageSize}`, {
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
 * Remplace les membres utilisateurs d'une organisation
 */
export async function replaceOrganizationUserMembers(organizationId: string, data: OrganizationUserMembersParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}/users`, {
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
 * Ajoute des membres utilisateurs à une organisation
 */
export async function addOrganizationUserMembers(organizationId: string, data: OrganizationUserMembersParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}/users`, {
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
 * Supprime un membre utilisateur d'une organisation
 */
export async function removeOrganizationUserMember(organizationId: string, userId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}/users/${userId}`, {
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

// Gestion des rôles des utilisateurs

/**
 * Récupère les rôles d'un utilisateur dans une organisation
 */
export async function getUserRolesInOrganization(organizationId: string, userId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}/users/${userId}/roles`, {
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
 * Met à jour les rôles d'un utilisateur dans une organisation
 */
export async function updateUserRolesInOrganization(organizationId: string, userId: string, data: AssignRolesToUserParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}/users/${userId}/roles`, {
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
 * Attribue des rôles à un utilisateur dans une organisation
 */
export async function assignRolesToUser(organizationId: string, userId: string, data: AssignRolesToUserParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}/users/${userId}/roles`, {
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
 * Supprime un rôle d'un utilisateur dans une organisation
 */
export async function removeRoleFromUser(organizationId: string, userId: string, roleId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}/users/${userId}/roles/${roleId}`, {
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
 * Récupère les scopes pour un utilisateur dans une organisation
 */
export async function getUserScopesInOrganization(organizationId: string, userId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}/users/${userId}/scopes`, {
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

// Gestion des applications

/**
 * Récupère les applications d'une organisation
 */
export async function getOrganizationApplications(organizationId: string, page: number = 1, pageSize: number = 20) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}/applications?page=${page}&page_size=${pageSize}`, {
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
 * Remplace les applications d'une organisation
 */
export async function replaceOrganizationApplications(organizationId: string, data: OrganizationApplicationsParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}/applications`, {
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
 * Ajoute une application à une organisation
 */
export async function addOrganizationApplication(organizationId: string, data: OrganizationApplicationsParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}/applications`, {
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
 * Supprime une application d'une organisation
 */
export async function removeOrganizationApplication(organizationId: string, applicationId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}/applications/${applicationId}`, {
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

// Gestion des rôles des applications

/**
 * Récupère les rôles d'une application dans une organisation
 */
export async function getOrganizationApplicationRoles(organizationId: string, applicationId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}/applications/${applicationId}/roles`, {
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
 * Remplace les rôles d'une application dans une organisation
 */
export async function replaceOrganizationApplicationRoles(organizationId: string, applicationId: string, data: AssignRolesToApplicationParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}/applications/${applicationId}/roles`, {
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
 * Attribue des rôles à une application dans une organisation
 */
export async function assignRolesToApplication(organizationId: string, applicationId: string, data: AssignRolesToApplicationParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}/applications/${applicationId}/roles`, {
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
 * Supprime un rôle d'une application dans une organisation
 */
export async function removeOrganizationApplicationRole(organizationId: string, applicationId: string, roleId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}/applications/${applicationId}/roles/${roleId}`, {
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

// Gestion des domaines email JIT

/**
 * Récupère les domaines email JIT d'une organisation
 */
export async function getOrganizationJitEmailDomains(organizationId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}/jit/email-domains`, {
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
 * Remplace les domaines email JIT d'une organisation
 */
export async function replaceOrganizationJitEmailDomains(organizationId: string, data: JitEmailDomainsParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}/jit/email-domains`, {
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
 * Ajoute un domaine email JIT à une organisation
 */
export async function addOrganizationJitEmailDomain(organizationId: string, data: JitEmailDomainsParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}/jit/email-domains`, {
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
 * Supprime un domaine email JIT d'une organisation
 */
export async function removeOrganizationJitEmailDomain(organizationId: string, domain: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}/jit/email-domains/${domain}`, {
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

// Gestion des rôles par défaut JIT

/**
 * Récupère les rôles par défaut JIT d'une organisation
 */
export async function getOrganizationJitDefaultRoles(organizationId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}/jit/default-roles`, {
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
 * Remplace les rôles par défaut JIT d'une organisation
 */
export async function replaceOrganizationJitDefaultRoles(organizationId: string, data: JitDefaultRolesParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}/jit/default-roles`, {
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
 * Ajoute des rôles par défaut JIT à une organisation
 */
export async function addOrganizationJitDefaultRoles(organizationId: string, data: JitDefaultRolesParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}/jit/default-roles`, {
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
 * Supprime un rôle par défaut JIT d'une organisation
 */
export async function removeOrganizationJitDefaultRole(organizationId: string, roleId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}/jit/default-roles/${roleId}`, {
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

// Gestion des connecteurs SSO JIT

/**
 * Récupère les connecteurs SSO JIT d'une organisation
 */
export async function getOrganizationJitSsoConnectors(organizationId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}/jit/sso-connectors`, {
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
 * Remplace les connecteurs SSO JIT d'une organisation
 */
export async function replaceOrganizationJitSsoConnectors(organizationId: string, data: JitSsoConnectorsParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}/jit/sso-connectors`, {
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
 * Ajoute des connecteurs SSO JIT à une organisation
 */
export async function addOrganizationJitSsoConnectors(organizationId: string, data: JitSsoConnectorsParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}/jit/sso-connectors`, {
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
 * Supprime un connecteur SSO JIT d'une organisation
 */
export async function removeOrganizationJitSsoConnector(organizationId: string, connectorId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}/jit/sso-connectors/${connectorId}`, {
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
