/**
 * Service pour gérer les interactions avec l'API Logto concernant les constantes d'application système
 */

/**
 * Récupère les constantes d'application système
 */
export async function getSystemApplicationConfig() {
  const response = await fetch(`${process.env.LOGTO_URL}/api/system-app-config`, {
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
