/**
 * Service pour gérer les interactions avec l'API Logto concernant les activités Sentinel
 */

/**
 * Type pour la suppression en masse d'activités Sentinel
 */
type BulkDeleteSentinelActivitiesParams = {
  ids: string[];
};

/**
 * Supprime en masse des activités Sentinel
 * @param data Données contenant les IDs des activités à supprimer
 */
export async function bulkDeleteSentinelActivities(data: BulkDeleteSentinelActivitiesParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/sentinel/activities`, {
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
