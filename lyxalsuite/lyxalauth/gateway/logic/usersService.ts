/**
 * Service pour gérer les interactions avec l'API Logto concernant les utilisateurs
 */

// Types pour les paramètres des fonctions
type CreateUserParams = {
  username: string;
  primaryEmail?: string;
  primaryPhone?: string;
  name?: string;
  password?: string;
  customData?: Record<string, unknown>;
};

type UpdateUserParams = {
  username?: string;
  primaryEmail?: string;
  primaryPhone?: string;
  name?: string;
  customData?: Record<string, unknown>;
};

/**
 * Récupère un utilisateur par son ID depuis Logto
 */
export async function getUserById(userId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/users/${userId}`, {
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
 * Supprime un utilisateur de Logto
 */
export async function deleteUser(userId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/users/${userId}`, {
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
 * Met à jour un utilisateur dans Logto
 */
export async function updateUser(userId: string, userData: UpdateUserParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/users/${userId}`, {
    method: 'PATCH',
    headers: {
      Authorization: `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(userData)
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
}

/**
 * Récupère les données personnalisées d'un utilisateur
 */
export async function getUserCustomData(userId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/users/${userId}/custom-data`, {
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
 * Met à jour les données personnalisées d'un utilisateur
 */
export async function updateUserCustomData(userId: string, customData: Record<string, unknown>) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/users/${userId}/custom-data`, {
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
 * Met à jour le profil d'un utilisateur
 */
export async function updateUserProfile(userId: string, profileData: UpdateUserParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/users/${userId}/profile`, {
    method: 'PATCH',
    headers: {
      Authorization: `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(profileData)
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
}

/**
 * Récupère tous les utilisateurs avec pagination
 */
export async function getUsers(page = 1, page_size = 20) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/users?page=${page}&page_size=${page_size}`, {
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
 * Crée un nouvel utilisateur dans Logto
 */
export async function createUser(userData: CreateUserParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/users`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(userData)
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
}

/**
 * Met à jour le mot de passe d'un utilisateur
 */
export async function updateUserPassword(userId: string, password: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/users/${userId}/password`, {
    method: 'PATCH',
    headers: {
      Authorization: `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ password })
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return { success: true };
}

/**
 * Vérifie le mot de passe d'un utilisateur
 */
export async function verifyUserPassword(userId: string, password: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/users/${userId}/password/verify`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ password })
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
}

/**
 * Vérifie si un utilisateur a un mot de passe
 */
export async function checkUserHasPassword(userId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/users/${userId}/has-password`, {
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
 * Met à jour le statut de suspension d'un utilisateur
 */
export async function updateUserSuspensionStatus(userId: string, isSuspended: boolean) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/users/${userId}/is-suspended`, {
    method: 'PATCH',
    headers: {
      Authorization: `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ isSuspended })
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
}

/**
 * Récupère les rôles d'un utilisateur
 */
export async function getUserRoles(userId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/users/${userId}/roles`, {
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
 * Met à jour les rôles d'un utilisateur
 */
export async function updateUserRoles(userId: string, roleIds: string[]) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/users/${userId}/roles`, {
    method: 'PUT',
    headers: {
      Authorization: `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ roleIds })
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
}

/**
 * Attribue des rôles à un utilisateur
 */
export async function assignRolesToUser(userId: string, roleIds: string[]) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/users/${userId}/roles`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ roleIds })
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
export async function removeRoleFromUser(userId: string, roleId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/users/${userId}/roles/${roleId}`, {
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
 * Met à jour l'identité sociale d'un utilisateur
 */
export async function updateUserSocialIdentity(userId: string, target: string, connectorId: string, userInfo: Record<string, unknown>) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/users/${userId}/identities/${target}`, {
    method: 'PUT',
    headers: {
      Authorization: `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ connectorId, userInfo })
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
}

/**
 * Supprime l'identité sociale d'un utilisateur
 */
export async function deleteSocialIdentityFromUser(userId: string, target: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/users/${userId}/identities/${target}`, {
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
 * Lie une identité sociale à un utilisateur
 */
export async function linkSocialIdentityToUser(userId: string, connectorId: string, userInfo: Record<string, unknown>) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/users/${userId}/identities`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ connectorId, userInfo })
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
}

/**
 * Récupère les organisations d'un utilisateur
 */
export async function getUserOrganizations(userId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/users/${userId}/organizations`, {
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
 * Récupère les vérifications MFA d'un utilisateur
 */
export async function getUserMfaVerifications(userId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/users/${userId}/mfa-verifications`, {
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
 * Crée une vérification MFA pour un utilisateur
 */
export async function createMfaVerificationForUser(userId: string, payload: Record<string, unknown>) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/users/${userId}/mfa-verifications`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(payload)
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
}

/**
 * Supprime une vérification MFA pour un utilisateur
 */
export async function deleteMfaVerificationForUser(userId: string, verificationId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/users/${userId}/mfa-verifications/${verificationId}`, {
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
 * Récupère les tokens d'accès personnels d'un utilisateur
 */
export async function getPersonalAccessTokens(userId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/users/${userId}/personal-access-tokens`, {
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
 * Ajoute un token d'accès personnel à un utilisateur
 */
export async function addPersonalAccessToken(userId: string, tokenData: { name: string; description?: string; expiresIn?: number }) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/users/${userId}/personal-access-tokens`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(tokenData)
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
}

/**
 * Supprime un token d'accès personnel d'un utilisateur
 */
export async function deletePersonalAccessToken(userId: string, tokenId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/users/${userId}/personal-access-tokens/${tokenId}`, {
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
 * Met à jour un token d'accès personnel d'un utilisateur
 */
export async function updatePersonalAccessToken(userId: string, tokenId: string, tokenData: { name?: string; description?: string }) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/users/${userId}/personal-access-tokens/${tokenId}`, {
    method: 'PATCH',
    headers: {
      Authorization: `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(tokenData)
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
} 
