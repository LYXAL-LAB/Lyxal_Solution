/**
 * Service pour gérer les interactions avec l'API Logto concernant les phrases personnalisées
 */

/**
 * Type pour les paramètres de mise à jour d'une phrase personnalisée
 */
type UpsertCustomPhraseParams = {
  languageTag: string;
  translation: Record<string, unknown>;
};

/**
 * Récupère toutes les phrases personnalisées
 */
export async function getAllCustomPhrases() {
  const response = await fetch(`${process.env.LOGTO_URL}/api/custom-phrases`, {
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
 * Récupère les phrases personnalisées pour une langue spécifique
 */
export async function getCustomPhrasesByLanguage(languageTag: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/custom-phrases/${languageTag}`, {
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
 * Crée ou met à jour des phrases personnalisées pour une langue spécifique
 */
export async function upsertCustomPhrases(data: UpsertCustomPhraseParams) {
  const { languageTag, translation } = data;
  
  const response = await fetch(`${process.env.LOGTO_URL}/api/custom-phrases/${languageTag}`, {
    method: 'PUT',
    headers: {
      Authorization: `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ translation })
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
}

/**
 * Supprime les phrases personnalisées pour une langue spécifique
 */
export async function deleteCustomPhrases(languageTag: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/custom-phrases/${languageTag}`, {
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
