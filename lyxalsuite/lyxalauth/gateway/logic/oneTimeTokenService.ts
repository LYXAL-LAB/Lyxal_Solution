/**
 * Service pour gérer les interactions avec l'API Logto concernant les jetons à usage unique
 */

// Types pour les différentes opérations de jetons à usage unique

/**
 * Type pour la création d'un jeton à usage unique
 */
type CreateOneTimeTokenParams = {
  type: string;
  code?: string;
  pattern?: string;
  userId?: string;
  action?: string;
  payload?: Record<string, unknown>;
  resource?: string;
  expiresInSeconds?: number;
};

/**
 * Type pour la vérification d'un jeton à usage unique
 */
type VerifyOneTimeTokenParams = {
  token: string;
  userId?: string;
  interactionId?: string;
  action?: string;
  resource?: string;
};

/**
 * Type pour la mise à jour du statut d'un jeton à usage unique
 */
type UpdateOneTimeTokenStatusParams = {
  status: 'consumed' | 'expired' | 'inactive';
};

/**
 * Récupère tous les jetons à usage unique
 * @param page Page à récupérer (par défaut: 1)
 * @param pageSize Nombre d'éléments par page (par défaut: 20)
 */
export async function getOneTimeTokens(page: number = 1, pageSize: number = 20) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/one-time-tokens?page=${page}&page_size=${pageSize}`, {
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
 * Crée un nouveau jeton à usage unique
 */
export async function createOneTimeToken(data: CreateOneTimeTokenParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/one-time-tokens`, {
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
 * Récupère un jeton à usage unique par son ID
 */
export async function getOneTimeTokenById(id: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/one-time-tokens/${id}`, {
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
 * Supprime un jeton à usage unique par son ID
 */
export async function deleteOneTimeToken(id: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/one-time-tokens/${id}`, {
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
 * Vérifie un jeton à usage unique
 */
export async function verifyOneTimeToken(data: VerifyOneTimeTokenParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/one-time-tokens/verify`, {
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
 * Met à jour le statut d'un jeton à usage unique
 */
export async function updateOneTimeTokenStatus(id: string, data: UpdateOneTimeTokenStatusParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/one-time-tokens/${id}/status`, {
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
