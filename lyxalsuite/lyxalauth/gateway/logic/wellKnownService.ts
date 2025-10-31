/**
 * Service pour gérer les interactions avec les endpoints well-known de l'API Logto
 */

/**
 * Récupère la configuration complète de l'expérience de connexion
 * @param params Paramètres optionnels
 */
export async function getFullSignInExperience(params?: { organizationId?: string; appId?: string }) {
  const queryParams = new URLSearchParams();
  
  if (params?.organizationId) {
    queryParams.append('organizationId', params.organizationId);
  }
  
  if (params?.appId) {
    queryParams.append('appId', params.appId);
  }
  
  const queryString = queryParams.toString() ? `?${queryParams.toString()}` : '';
  
  const response = await fetch(`${process.env.LOGTO_URL}/api/.well-known/sign-in-exp${queryString}`, {
    method: 'GET',
    headers: {
      'Authorization': `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
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
 * Récupère les phrases localisées
 * @param params Paramètres optionnels
 */
export async function getWellKnownLocalizedPhrases(params?: { language?: string }) {
  const queryParams = new URLSearchParams();
  
  if (params?.language) {
    queryParams.append('language', params.language);
  }
  
  const queryString = queryParams.toString() ? `?${queryParams.toString()}` : '';
  
  const response = await fetch(`${process.env.LOGTO_URL}/api/.well-known/phrases${queryString}`, {
    method: 'GET',
    headers: {
      'Authorization': `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
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
 * Récupère la documentation Swagger JSON de l'API de gestion via l'endpoint well-known
 */
export async function getWellKnownManagementApiSwaggerJson() {
  const response = await fetch(`${process.env.LOGTO_URL}/api/.well-known/management-api-swagger.json`, {
    method: 'GET',
    headers: {
      'Authorization': `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
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
 * Récupère la documentation Swagger JSON de l'API d'expérience via l'endpoint well-known
 */
export async function getWellKnownExperienceApiSwaggerJson() {
  const response = await fetch(`${process.env.LOGTO_URL}/api/.well-known/experience-api-swagger.json`, {
    method: 'GET',
    headers: {
      'Authorization': `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
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
 * Récupère la documentation Swagger JSON de l'API utilisateur via l'endpoint well-known
 */
export async function getWellKnownUserApiSwaggerJson() {
  const response = await fetch(`${process.env.LOGTO_URL}/api/.well-known/user-api-swagger.json`, {
    method: 'GET',
    headers: {
      'Authorization': `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
      'Content-Type': 'application/json'
    }
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
} 
