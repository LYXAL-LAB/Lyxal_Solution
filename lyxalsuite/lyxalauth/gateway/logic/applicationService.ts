/**
 * Service pour gérer les interactions avec l'API Logto concernant les applications
 */

// Types pour les paramètres des fonctions
type CreateApplicationParams = {
  name: string;
  description?: string;
  type: 'native' | 'spa' | 'traditional' | 'machine_to_machine';
  oidcClientMetadata?: {
    redirectUris?: string[];
    postLogoutRedirectUris?: string[];
  };
  customClientMetadata?: Record<string, unknown>;
};

type UpdateApplicationParams = {
  name?: string;
  description?: string;
  oidcClientMetadata?: {
    redirectUris?: string[];
    postLogoutRedirectUris?: string[];
  };
  customClientMetadata?: Record<string, unknown>;
};

/**
 * Récupère toutes les applications
 */
export async function getApplications() {
  const response = await fetch(`${process.env.LOGTO_URL}/api/applications`, {
    method: 'GET',
    headers: {
      Authorization: `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
      'Content-Type': 'application/json'
    }
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
}

/**
 * Crée une nouvelle application
 */
export async function createApplication(data: {
  name: string;
  description?: string;
  type: 'native' | 'spa' | 'traditional' | 'machine_to_machine';
  redirectUris?: string[];
  postLogoutRedirectUris?: string[];
  allowedOrigins?: string[];
  logoUri?: string;
  customData?: Record<string, unknown>;
}) {
  // Transformer les données au format attendu par l'API
  const apiData: CreateApplicationParams = {
    name: data.name,
    description: data.description,
    type: data.type,
    oidcClientMetadata: {
      redirectUris: data.redirectUris,
      postLogoutRedirectUris: data.postLogoutRedirectUris
    },
    customClientMetadata: {
      ...data.customData,
      allowedOrigins: data.allowedOrigins,
      logoUri: data.logoUri
    }
  };

  const response = await fetch(`${process.env.LOGTO_URL}/api/applications`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(apiData)
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
}

/**
 * Récupère une application par son ID
 */
export async function getApplicationById(appId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/applications/${appId}`, {
    method: 'GET',
    headers: {
      Authorization: `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
      'Content-Type': 'application/json'
    }
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
}

/**
 * Supprime une application
 */
export async function deleteApplication(appId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/applications/${appId}`, {
    method: 'DELETE',
    headers: {
      Authorization: `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
      'Content-Type': 'application/json'
    }
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return { success: true };
}

/**
 * Met à jour une application
 */
export async function updateApplication(appId: string, data: UpdateApplicationParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/applications/${appId}`, {
    method: 'PATCH',
    headers: {
      Authorization: `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
      'Content-Type': 'application/json'
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
 * Met à jour les données personnalisées d'une application
 */
export async function updateApplicationCustomData(appId: string, customData: Record<string, unknown>) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/applications/${appId}/custom-data`, {
    method: 'PATCH',
    headers: {
      Authorization: `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(customData)
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
}

/**
 * Récupère les rôles de ressources API d'une application
 */
export async function getApplicationApiResourceRoles(appId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/applications/${appId}/api-resources/roles`, {
    method: 'GET',
    headers: {
      Authorization: `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
      'Content-Type': 'application/json'
    }
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
}

/**
 * Met à jour les rôles de ressources API pour une application
 */
export async function updateApiResourceRoles(appId: string, resources: { id: string; roles: string[] }[]) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/applications/${appId}/api-resources/roles`, {
    method: 'PUT',
    headers: {
      Authorization: `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ resources })
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
}

/**
 * Attribue des rôles de ressources API à une application
 */
export async function assignApiResourceRoles(appId: string, resources: { id: string; roles: string[] }[]) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/applications/${appId}/api-resources/roles`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ resources })
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
}

/**
 * Supprime un rôle de ressource API d'une application
 */
export async function removeApiResourceRole(appId: string, resourceId: string, roleId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/applications/${appId}/api-resources/${resourceId}/roles/${roleId}`, {
    method: 'DELETE',
    headers: {
      Authorization: `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
      'Content-Type': 'application/json'
    }
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return { success: true };
}

/**
 * Récupère les domaines personnalisés d'une application
 */
export async function getApplicationCustomDomains(appId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/applications/${appId}/custom-domains`, {
    method: 'GET',
    headers: {
      Authorization: `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
      'Content-Type': 'application/json'
    }
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
}

/**
 * Ajoute un domaine personnalisé à une application
 */
export async function addCustomDomain(appId: string, domain: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/applications/${appId}/custom-domains`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ domain })
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
}

/**
 * Supprime un domaine personnalisé d'une application
 */
export async function removeCustomDomain(appId: string, domain: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/applications/${appId}/custom-domains/${domain}`, {
    method: 'DELETE',
    headers: {
      Authorization: `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
      'Content-Type': 'application/json'
    }
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return { success: true };
}

/**
 * Récupère les organisations d'une application
 */
export async function getApplicationOrganizations(appId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/applications/${appId}/organizations`, {
    method: 'GET',
    headers: {
      Authorization: `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
      'Content-Type': 'application/json'
    }
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
}

/**
 * Supprime un secret legacy d'une application
 */
export async function deleteLegacySecret(appId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/applications/${appId}/secrets/legacy`, {
    method: 'DELETE',
    headers: {
      Authorization: `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
      'Content-Type': 'application/json'
    }
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return { success: true };
}

/**
 * Récupère les secrets d'une application
 */
export async function getApplicationSecrets(appId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/applications/${appId}/secrets`, {
    method: 'GET',
    headers: {
      Authorization: `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
      'Content-Type': 'application/json'
    }
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
}

/**
 * Ajoute un secret à une application
 */
export async function addApplicationSecret(appId: string, data: { name: string; expiresAt?: number }) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/applications/${appId}/secrets`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
      'Content-Type': 'application/json'
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
 * Supprime un secret d'une application
 */
export async function deleteApplicationSecret(appId: string, secretId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/applications/${appId}/secrets/${secretId}`, {
    method: 'DELETE',
    headers: {
      Authorization: `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
      'Content-Type': 'application/json'
    }
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return { success: true };
}

/**
 * Met à jour un secret d'application
 */
export async function updateApplicationSecret(appId: string, secretId: string, data: { name: string }) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/applications/${appId}/secrets/${secretId}`, {
    method: 'PATCH',
    headers: {
      Authorization: `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
      'Content-Type': 'application/json'
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
 * Liste tous les scopes de consentement utilisateur d'une application
 */
export async function getUserConsentScopes(appId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/applications/${appId}/user-consent-scopes`, {
    method: 'GET',
    headers: {
      Authorization: `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
      'Content-Type': 'application/json'
    }
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
}

/**
 * Attribue des scopes de consentement utilisateur à une application
 */
export async function assignUserConsentScopes(appId: string, scopeIds: string[]) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/applications/${appId}/user-consent-scopes`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ scopeIds })
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
}

/**
 * Supprime un scope de consentement utilisateur d'une application
 */
export async function removeUserConsentScope(appId: string, scopeId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/applications/${appId}/user-consent-scopes/${scopeId}`, {
    method: 'DELETE',
    headers: {
      Authorization: `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
      'Content-Type': 'application/json'
    }
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return { success: true };
}

/**
 * Récupère l'expérience de connexion au niveau de l'application
 */
export async function getAppSignInExperience(appId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/applications/${appId}/sign-in-experience`, {
    method: 'GET',
    headers: {
      Authorization: `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
      'Content-Type': 'application/json'
    }
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
}

/**
 * Met à jour l'expérience de connexion au niveau de l'application
 */
export async function updateAppSignInExperience(appId: string, data: Record<string, unknown>) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/applications/${appId}/sign-in-experience`, {
    method: 'PUT',
    headers: {
      Authorization: `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
      'Content-Type': 'application/json'
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
 * Liste toutes les organisations consenties par un utilisateur pour une application
 */
export async function getUserConsentedOrganizations(appId: string, userId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/applications/${appId}/user-consented-organizations/${userId}`, {
    method: 'GET',
    headers: {
      Authorization: `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
      'Content-Type': 'application/json'
    }
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
}

/**
 * Accorde l'accès à plusieurs organisations pour un utilisateur et une application (PUT)
 */
export async function putUserOrganizationAccess(appId: string, userId: string, organizationIds: string[]) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/applications/${appId}/user-consented-organizations/${userId}`, {
    method: 'PUT',
    headers: {
      Authorization: `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ organizationIds })
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
}

/**
 * Accorde l'accès à plusieurs organisations pour un utilisateur et une application (POST)
 */
export async function postUserOrganizationAccess(appId: string, userId: string, organizationIds: string[]) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/applications/${appId}/user-consented-organizations/${userId}`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ organizationIds })
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
}

/**
 * Révoque l'accès d'un utilisateur à une organisation pour une application
 */
export async function revokeUserOrganizationAccess(appId: string, userId: string, organizationId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/applications/${appId}/user-consented-organizations/${userId}/${organizationId}`, {
    method: 'DELETE',
    headers: {
      Authorization: `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
      'Content-Type': 'application/json'
    }
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return { success: true };
} 
