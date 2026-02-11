/**
 * Service pour gérer les interactions avec l'API Logto concernant les applications SAML
 */

// Types pour les différentes opérations d'applications SAML

/**
 * Type pour la création d'une application SAML
 */
type CreateSamlApplicationParams = {
  name: string;
  description?: string;
  acs: string;
  entityId: string;
  notBeforeMinutes?: number;
  expiresMinutes?: number;
  certificate?: {
    publicKey?: string;
    privateKey?: string;
  };
};

/**
 * Type pour la mise à jour d'une application SAML
 */
type UpdateSamlApplicationParams = {
  name?: string;
  description?: string;
  acs?: string;
  entityId?: string;
  notBeforeMinutes?: number;
  expiresMinutes?: number;
  certificate?: {
    publicKey?: string;
    privateKey?: string;
  };
};

/**
 * Type pour la création d'un secret d'application SAML
 */
type CreateSamlApplicationSecretParams = {
  name: string;
  expiresAt?: string; // ISO 8601 date
};

/**
 * Type pour la mise à jour d'un secret d'application SAML
 */
type UpdateSamlApplicationSecretParams = {
  name?: string;
  expiresAt?: string; // ISO 8601 date
};

/**
 * Crée une application SAML
 */
export async function createSamlApplication(data: CreateSamlApplicationParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/applications/saml`, {
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
 * Récupère une application SAML par son ID
 */
export async function getSamlApplication(applicationId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/applications/saml/${applicationId}`, {
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
 * Supprime une application SAML
 */
export async function deleteSamlApplication(applicationId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/applications/saml/${applicationId}`, {
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
 * Met à jour une application SAML
 */
export async function updateSamlApplication(applicationId: string, data: UpdateSamlApplicationParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/applications/saml/${applicationId}`, {
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
 * Liste les secrets d'une application SAML
 */
export async function listSamlApplicationSecrets(applicationId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/applications/saml/${applicationId}/secrets`, {
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
 * Crée un nouveau secret pour une application SAML
 */
export async function createSamlApplicationSecret(applicationId: string, data: CreateSamlApplicationSecretParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/applications/saml/${applicationId}/secrets`, {
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
 * Supprime un secret d'une application SAML
 */
export async function deleteSamlApplicationSecret(applicationId: string, secretId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/applications/saml/${applicationId}/secrets/${secretId}`, {
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
 * Met à jour un secret d'une application SAML
 */
export async function updateSamlApplicationSecret(applicationId: string, secretId: string, data: UpdateSamlApplicationSecretParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/applications/saml/${applicationId}/secrets/${secretId}`, {
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
 * Récupère les métadonnées d'une application SAML
 */
export async function getSamlApplicationMetadata(applicationId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/applications/saml/${applicationId}/metadata`, {
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
 * Gère le callback SAML
 * Note: Cette fonction est généralement utilisée côté serveur pour traiter les réponses SAML
 */
export async function handleSamlApplicationCallback(applicationId: string, queryParams: Record<string, string>) {
  // Construire l'URL avec les paramètres de requête
  const url = new URL(`${process.env.LOGTO_URL}/api/applications/saml/${applicationId}/callback`);
  Object.entries(queryParams).forEach(([key, value]) => {
    url.searchParams.append(key, value);
  });

  const response = await fetch(url.toString(), {
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
 * Gère la requête d'authentification SAML via Redirect binding (GET)
 * @param samlRequest Informations de requête SAML
 * @param relayState État de relais (optionnel)
 */
export async function handleSamlAuthRequestRedirect(samlRequest: string, relayState?: string) {
  // Construire l'URL avec les paramètres de requête
  const url = new URL(`${process.env.LOGTO_URL}/api/authn/saml`);
  url.searchParams.append('SAMLRequest', samlRequest);
  if (relayState) {
    url.searchParams.append('RelayState', relayState);
  }

  const response = await fetch(url.toString(), {
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
 * Type pour la requête d'authentification SAML via POST binding
 */
type SamlAuthPostBindingParams = {
  SAMLRequest: string;
  RelayState?: string;
};

/**
 * Gère la requête d'authentification SAML via POST binding (POST)
 * @param data Données de la requête SAML
 */
export async function handleSamlAuthRequestPost(data: SamlAuthPostBindingParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/authn/saml`, {
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
