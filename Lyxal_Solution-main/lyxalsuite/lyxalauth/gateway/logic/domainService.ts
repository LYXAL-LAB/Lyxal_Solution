/**
 * Service pour gérer les interactions avec l'API Logto concernant les domaines
 */

/**
 * Type pour les paramètres de création d'un domaine
 */
type CreateDomainParams = {
  domain: string;
};

/**
 * Récupère tous les domaines
 */
export async function getDomains() {
  const response = await fetch(`${process.env.LOGTO_URL}/api/domains`, {
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
 * Crée un nouveau domaine
 */
export async function createDomain(data: CreateDomainParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/domains`, {
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
 * Récupère un domaine par son ID
 */
export async function getDomainById(id: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/domains/${id}`, {
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
 * Supprime un domaine
 */
export async function deleteDomain(id: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/domains/${id}`, {
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
