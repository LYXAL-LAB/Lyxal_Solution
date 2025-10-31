/**
 * Service pour gérer les interactions directes avec l'API Logto concernant le flux d'authentification
 */

// Types pour les différentes opérations d'interaction

/**
 * Type pour la suppression d'une interaction
 */
type DeleteInteractionParams = Record<string, never>;

/**
 * Type pour la mise à jour des identifiants d'interaction
 */
type UpdateIdentifiersParams = {
  username?: string;
  email?: string;
  phone?: string;
  connectorId?: string;
  code?: string;
};

/**
 * Type pour la mise à jour du profil d'interaction
 */
type UpdateProfileParams = {
  username?: string;
  primaryEmail?: string;
  primaryPhone?: string;
  name?: string;
  avatar?: string;
  customData?: Record<string, unknown>;
};

/**
 * Type pour la suppression du profil d'interaction
 */
type DeleteProfileParams = Record<string, never>;

/**
 * Type pour la mise à jour partielle du profil d'interaction
 */
type PatchProfileParams = {
  username?: string;
  primaryEmail?: string;
  primaryPhone?: string;
  name?: string;
  avatar?: string;
  customData?: Record<string, unknown>;
};

/**
 * Type pour le consentement d'interaction
 */
type ConsentParams = {
  consent: boolean;
};

/**
 * Type pour l'autorisation sociale
 */
type SocialAuthorizationUriParams = {
  connectorId: string;
  state?: string;
  redirectUri: string;
};

/**
 * Type pour la mise à jour MFA
 */
type UpdateMfaParams = {
  enabled: boolean;
};

/**
 * Type pour l'URL d'autorisation SSO
 */
type SingleSignOnAuthorizationUrlParams = {
  redirectUri: string;
};

/**
 * Type pour l'authentification SSO
 */
type SingleSignOnAuthenticationParams = {
  data: Record<string, unknown>;
};

/**
 * Type pour l'enregistrement SSO
 */
type SingleSignOnRegistrationParams = {
  data: Record<string, unknown>;
};

/**
 * Supprime une interaction en cours
 */
export async function deleteInteraction() {
  const response = await fetch(`${process.env.LOGTO_URL}/api/interaction`, {
    method: 'DELETE',
    headers: {
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
 * Met à jour les identifiants pour l'interaction en cours
 */
export async function updateIdentifiers(data: UpdateIdentifiersParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/interaction/identifiers`, {
    method: 'PATCH',
    headers: {
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
 * Met à jour le profil pour l'interaction en cours
 */
export async function updateProfile(data: UpdateProfileParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/interaction/profile`, {
    method: 'PUT',
    headers: {
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
 * Supprime le profil pour l'interaction en cours
 */
export async function deleteProfile() {
  const response = await fetch(`${process.env.LOGTO_URL}/api/interaction/profile`, {
    method: 'DELETE',
    headers: {
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
 * Met à jour partiellement le profil pour l'interaction en cours
 */
export async function patchProfile(data: PatchProfileParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/interaction/profile`, {
    method: 'PATCH',
    headers: {
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
 * Récupère les informations de consentement pour l'interaction en cours
 */
export async function getConsent() {
  const response = await fetch(`${process.env.LOGTO_URL}/api/interaction/consent`, {
    method: 'GET',
    headers: {
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
 * Soumet le consentement pour l'interaction en cours
 */
export async function submitConsent(data: ConsentParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/interaction/consent`, {
    method: 'POST',
    headers: {
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
 * Génère une URI d'autorisation sociale
 */
export async function createSocialAuthorizationUri(data: SocialAuthorizationUriParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/interaction/verification/social-authorization-uri`, {
    method: 'POST',
    headers: {
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
 * Met à jour les paramètres MFA pour l'interaction en cours
 */
export async function updateMfa(data: UpdateMfaParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/interaction/mfa`, {
    method: 'PUT',
    headers: {
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
 * Marque l'interaction MFA comme ignorée
 */
export async function markMfaSkipped() {
  const response = await fetch(`${process.env.LOGTO_URL}/api/interaction/mfa-skipped`, {
    method: 'PUT',
    headers: {
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
 * Génère une URL d'autorisation SSO pour un connecteur spécifique
 */
export async function getSingleSignOnAuthorizationUrl(connectorId: string, data: SingleSignOnAuthorizationUrlParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/interaction/single-sign-on/${connectorId}/authorization-url`, {
    method: 'POST',
    headers: {
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
 * Authentifie l'utilisateur via SSO
 */
export async function authenticateSingleSignOn(connectorId: string, data: SingleSignOnAuthenticationParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/interaction/single-sign-on/${connectorId}/authentication`, {
    method: 'POST',
    headers: {
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
 * Enregistre l'utilisateur via SSO
 */
export async function registerSingleSignOn(connectorId: string, data: SingleSignOnRegistrationParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/interaction/single-sign-on/${connectorId}/registration`, {
    method: 'POST',
    headers: {
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
