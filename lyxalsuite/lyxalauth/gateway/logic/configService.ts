/**
 * Service pour gérer les interactions avec l'API Logto concernant les configurations
 */

/**
 * Type pour les paramètres de mise à jour de la configuration de la console d'administration
 */
type UpdateAdminConsoleConfigParams = Record<string, unknown>;

/**
 * Type pour les paramètres de création/mise à jour d'un personnalisateur JWT
 */
type UpsertJwtCustomizerParams = {
  targetId: string;
  script: string;
  config?: Record<string, unknown>;
};

/**
 * Type pour les paramètres de mise à jour partielle d'un personnalisateur JWT
 */
type PatchJwtCustomizerParams = {
  script?: string;
  config?: Record<string, unknown>;
};

/**
 * Type pour les paramètres de test d'un personnalisateur JWT
 */
type TestJwtCustomizerParams = {
  targetId: string;
  script: string;
  payload: Record<string, unknown>;
  config?: Record<string, unknown>;
};

/**
 * Récupère la configuration de la console d'administration
 */
export async function getAdminConsoleConfig() {
  const response = await fetch(`${process.env.LOGTO_URL}/api/configs/admin-console`, {
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
 * Met à jour la configuration de la console d'administration
 */
export async function updateAdminConsoleConfig(data: UpdateAdminConsoleConfigParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/configs/admin-console`, {
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
 * Récupère les clés OIDC
 */
export async function getOidcKeys() {
  const response = await fetch(`${process.env.LOGTO_URL}/api/configs/oidc/keys`, {
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
 * Supprime une clé OIDC
 */
export async function deleteOidcKey(keyId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/configs/oidc/keys/${keyId}`, {
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
 * Rotation des clés OIDC
 */
export async function rotateOidcKeys() {
  const response = await fetch(`${process.env.LOGTO_URL}/api/configs/oidc/keys/rotate`, {
    method: 'POST',
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
 * Récupère un personnalisateur JWT spécifique
 */
export async function getJwtCustomizer(targetId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/configs/jwt-customizer/${targetId}`, {
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
 * Crée ou met à jour un personnalisateur JWT
 */
export async function upsertJwtCustomizer(data: UpsertJwtCustomizerParams) {
  const { targetId, ...body } = data;
  const response = await fetch(`${process.env.LOGTO_URL}/api/configs/jwt-customizer/${targetId}`, {
    method: 'PUT',
    headers: {
      Authorization: `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(body)
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
}

/**
 * Supprime un personnalisateur JWT
 */
export async function deleteJwtCustomizer(targetId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/configs/jwt-customizer/${targetId}`, {
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
 * Met à jour partiellement un personnalisateur JWT
 */
export async function patchJwtCustomizer(targetId: string, data: PatchJwtCustomizerParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/configs/jwt-customizer/${targetId}`, {
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
 * Récupère tous les personnalisateurs JWT
 */
export async function getAllJwtCustomizers() {
  const response = await fetch(`${process.env.LOGTO_URL}/api/configs/jwt-customizers`, {
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
 * Teste un personnalisateur JWT
 */
export async function testJwtCustomizer(data: TestJwtCustomizerParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/configs/jwt-customizer/test`, {
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
