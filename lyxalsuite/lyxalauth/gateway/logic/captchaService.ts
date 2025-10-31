/**
 * Service pour gérer les interactions avec l'API Logto concernant le fournisseur de CAPTCHA
 */

/**
 * Type pour les paramètres de mise à jour du fournisseur de CAPTCHA
 */
type UpdateCaptchaProviderParams = {
  provider: string;
  config: Record<string, unknown>;
};

/**
 * Récupère les informations du fournisseur de CAPTCHA
 */
export async function getCaptchaProvider() {
  const response = await fetch(`${process.env.LOGTO_URL}/api/captcha-provider`, {
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
 * Met à jour le fournisseur de CAPTCHA
 */
export async function updateCaptchaProvider(data: UpdateCaptchaProviderParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/captcha-provider`, {
    method: 'PUT',
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
 * Supprime le fournisseur de CAPTCHA
 */
export async function deleteCaptchaProvider() {
  const response = await fetch(`${process.env.LOGTO_URL}/api/captcha-provider`, {
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

/**
 * Vérifie une réponse CAPTCHA
 * @param token Le jeton de réponse CAPTCHA
 * @param remoteIp L'adresse IP du client (optionnelle)
 * @returns Le résultat de la vérification avec success: true/false
 */
export async function verifyCaptcha(token: string, remoteIp?: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/captcha/verify`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ 
      response: token,
      remoteIp 
    })
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
} 
