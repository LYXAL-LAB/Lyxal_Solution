/**
 * Service pour gérer les interactions avec l'API Logto concernant l'authentification
 */

/**
 * Type pour les paramètres de la requête Hasura auth hook
 */
type HasuraAuthParams = {
  role?: string;
  authorization?: string;
};

/**
 * Type pour les paramètres de la requête SAML ACS (social)
 */
type SamlAcsSocialParams = {
  RelayState?: string;
  SAMLResponse: string;
};

/**
 * Type pour les paramètres de la requête SAML ACS (SSO)
 */
type SamlAcsSsoParams = {
  RelayState?: string;
  SAMLResponse: string;
};

/**
 * Endpoint d'authentification Hasura
 */
export async function getHasuraAuthHook(params: HasuraAuthParams = {}) {
  const queryParams = new URLSearchParams();
  
  if (params.role) queryParams.append('role', params.role);
  
  const url = `${process.env.LOGTO_URL}/api/authn/hasura?${queryParams.toString()}`;

  const headers: Record<string, string> = {
    'Content-Type': 'application/json'
  };

  if (params.authorization) {
    headers['Authorization'] = params.authorization;
  }

  const response = await fetch(url, {
    method: 'GET',
    headers
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
}

/**
 * Endpoint SAML ACS (social)
 */
export async function samlAcsSocial(data: SamlAcsSocialParams) {
  // Conversion des données en FormData pour la requête POST
  const formData = new FormData();
  if (data.RelayState) formData.append('RelayState', data.RelayState);
  formData.append('SAMLResponse', data.SAMLResponse);

  const response = await fetch(`${process.env.LOGTO_URL}/api/authn/saml/acs/social`, {
    method: 'POST',
    body: formData
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
}

/**
 * Endpoint SAML ACS (SSO)
 */
export async function samlAcsSso(data: SamlAcsSsoParams) {
  // Conversion des données en FormData pour la requête POST
  const formData = new FormData();
  if (data.RelayState) formData.append('RelayState', data.RelayState);
  formData.append('SAMLResponse', data.SAMLResponse);

  const response = await fetch(`${process.env.LOGTO_URL}/api/authn/saml/acs/sso`, {
    method: 'POST',
    body: formData
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
} 
