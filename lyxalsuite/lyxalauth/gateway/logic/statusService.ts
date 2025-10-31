/**
 * Service pour gérer les interactions avec l'API Logto concernant l'état de santé du service
 */

/**
 * Vérifie l'état de santé du service Logto
 * Retourne true si le service est en bonne santé (statut 204)
 */
export async function checkHealth() {
  try {
    const response = await fetch(`${process.env.LOGTO_URL}/api/status`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json'
      }
    });

    // L'API Logto renvoie un 204 No Content quand tout va bien
    if (response.status === 204) {
      return { status: 'healthy' };
    }

    throw new Error(`Logto service unhealthy: ${response.statusText}`);
  } catch (error: any) {
    throw new Error(`Failed to check Logto health: ${error.message}`);
  }
} 
