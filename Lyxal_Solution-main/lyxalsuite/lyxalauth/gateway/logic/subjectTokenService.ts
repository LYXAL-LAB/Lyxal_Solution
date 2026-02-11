/**
 * Service pour gérer les interactions avec l'API Logto concernant les tokens de sujet
 */

/**
 * Type pour les paramètres de création d'un nouveau token de sujet
 */
type CreateSubjectTokenParams = {
  /** ID de l'utilisateur */
  userId: string;
  /** Durée de vie du token en secondes (optionnel) */
  expiresIn?: number;
  /** ID du tenant (optionnel) */
  tenantId?: string;
  /** Scopes (optionnel) */
  scope?: string | string[];
};

/**
 * Crée un nouveau token de sujet
 * @param data Données pour la création du token
 */
export async function createSubjectToken(data: CreateSubjectTokenParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/subject-tokens`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
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
