/**
 * Service pour gérer les interactions avec l'API Logto concernant les fournisseurs de connecteurs SSO
 */

/**
 * Récupère tous les détails des fournisseurs de connecteurs SSO
 */
export async function getAllSsoConnectorProviders() {
  const response = await fetch(`${process.env.LOGTO_URL}/api/sso-connector-providers`, {
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
