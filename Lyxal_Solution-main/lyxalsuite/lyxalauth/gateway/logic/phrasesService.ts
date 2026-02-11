/**
 * Service pour gérer les interactions avec l'API Logto concernant les phrases localisées
 */

/**
 * Type pour les paramètres de récupération des phrases localisées
 */
type GetLocalizedPhrasesParams = {
  /** Code de langue (ex: fr, en, etc.) */
  language?: string;
};

/**
 * Récupère les phrases localisées
 * @param params Paramètres optionnels pour la récupération des phrases
 */
export async function getLocalizedPhrases(params?: GetLocalizedPhrasesParams) {
  const queryParams = new URLSearchParams();
  
  if (params?.language) {
    queryParams.append('language', params.language);
  }
  
  const queryString = queryParams.toString() ? `?${queryParams.toString()}` : '';
  
  const response = await fetch(`${process.env.LOGTO_URL}/api/phrases${queryString}`, {
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
