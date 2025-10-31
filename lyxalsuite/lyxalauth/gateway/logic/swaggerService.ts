/**
 * Service pour gérer les interactions avec l'API Logto concernant la documentation Swagger
 */

/**
 * Récupère la documentation Swagger JSON
 */
export async function getSwaggerJson() {
  const response = await fetch(`${process.env.LOGTO_URL}/api/swagger.json`, {
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
 * Récupère la documentation Swagger JSON de l'API de gestion
 */
export async function getManagementApiSwaggerJson() {
  const response = await fetch(`${process.env.LOGTO_URL}/api/swagger/management-api.json`, {
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
 * Récupère la documentation Swagger JSON de l'API d'expérience
 */
export async function getExperienceApiSwaggerJson() {
  const response = await fetch(`${process.env.LOGTO_URL}/api/swagger/experience-api.json`, {
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
 * Récupère la documentation Swagger JSON de l'API utilisateur
 */
export async function getUserApiSwaggerJson() {
  const response = await fetch(`${process.env.LOGTO_URL}/api/swagger/user-api.json`, {
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
