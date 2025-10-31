/**
 * Service pour gérer les interactions avec l'API Logto concernant les webhooks
 */

// Types pour les différentes opérations liées aux webhooks

/**
 * Type pour la configuration d'un webhook
 */
type WebhookConfig = {
  url: string;
  headers?: Record<string, string>;
};

/**
 * Type pour la création d'un webhook
 */
type CreateHookParams = {
  name: string;
  events: string[];
  config: WebhookConfig;
  enabled?: boolean;
};

/**
 * Type pour la mise à jour d'un webhook
 */
type UpdateHookParams = {
  name?: string;
  events?: string[];
  config?: WebhookConfig;
  enabled?: boolean;
};

/**
 * Type pour la mise à jour de la clé de signature d'un webhook
 */
type UpdateSigningKeyParams = {
  signingKey?: string;
};

/**
 * Récupère tous les webhooks
 */
export async function getHooks() {
  const response = await fetch(`${process.env.LOGTO_URL}/api/hooks`, {
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
 * Crée un nouveau webhook
 */
export async function createHook(data: CreateHookParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/hooks`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${process.env.LOGTO_TOKEN}`
    },
    body: JSON.stringify({
      ...data,
      tenantId: process.env.LOGTO_TENANT_ID
    })
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
}

/**
 * Récupère un webhook par son ID
 */
export async function getHookById(id: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/hooks/${id}`, {
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
 * Supprime un webhook
 */
export async function deleteHook(id: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/hooks/${id}`, {
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
 * Met à jour un webhook
 */
export async function updateHook(id: string, data: UpdateHookParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/hooks/${id}`, {
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
 * Récupère les logs récents d'un webhook
 */
export async function getHookLogs(id: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/hooks/${id}/recent-logs`, {
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
 * Teste un webhook
 */
export async function testHook(id: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/hooks/${id}/test`, {
    method: 'POST',
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
 * Met à jour la clé de signature d'un webhook
 */
export async function updateSigningKey(id: string, data: UpdateSigningKeyParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/hooks/${id}/signing-key`, {
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
