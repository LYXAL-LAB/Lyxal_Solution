/**
 * Service pour gérer les interactions avec l'API Logto concernant les connecteurs
 */

/**
 * Type pour les paramètres de création d'un connecteur
 */
type CreateConnectorParams = {
  connectorId: string;
  config?: Record<string, unknown>;
  metadata?: Record<string, unknown>;
};

/**
 * Type pour les paramètres de mise à jour d'un connecteur
 */
type UpdateConnectorParams = {
  config?: Record<string, unknown>;
  metadata?: Record<string, unknown>;
};

/**
 * Type pour les paramètres de test d'un connecteur sans mot de passe
 */
type TestPasswordlessConnectorParams = {
  config: Record<string, unknown>;
  type: 'sms' | 'email';
  phone?: string;
  email?: string;
};

/**
 * Type pour les paramètres de récupération de l'URI d'autorisation d'un connecteur
 */
type GetAuthorizationUriParams = {
  state: string;
  redirectUri: string;
  connectorId: string;
  connectorFactoryId: string;
  data?: Record<string, unknown>;
};

/**
 * Récupère tous les connecteurs
 */
export async function getConnectors() {
  const response = await fetch(`${process.env.LOGTO_URL}/api/connectors`, {
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
 * Crée un nouveau connecteur
 */
export async function createConnector(data: CreateConnectorParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/connectors`, {
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
 * Récupère un connecteur par son ID
 */
export async function getConnectorById(connectorId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/connectors/${connectorId}`, {
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
 * Supprime un connecteur
 */
export async function deleteConnector(connectorId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/connectors/${connectorId}`, {
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
 * Met à jour un connecteur
 */
export async function updateConnector(connectorId: string, data: UpdateConnectorParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/connectors/${connectorId}`, {
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
 * Teste un connecteur sans mot de passe
 */
export async function testPasswordlessConnector(data: TestPasswordlessConnectorParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/connectors/test-passwordless`, {
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
 * Récupère l'URI d'autorisation d'un connecteur
 */
export async function getConnectorAuthorizationUri(data: GetAuthorizationUriParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/connectors/${data.connectorId}/authorization-uri`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      state: data.state,
      redirectUri: data.redirectUri,
      connectorFactoryId: data.connectorFactoryId,
      data: data.data
    })
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
} 
