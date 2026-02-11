/**
 * Service pour gérer les interactions avec l'API Logto concernant l'expérience utilisateur et les interactions
 */

// Types pour les différentes opérations d'interaction

/**
 * Type pour l'initialisation d'une nouvelle interaction
 */
type InitInteractionParams = {
  redirectUri: string;
  clientId?: string;
  state?: string;
  scope?: string;
  nonce?: string;
  responseType?: string;
  codeChallenge?: string;
  codeChallengeMethod?: string;
  maxAge?: number;
  responseMode?: string;
  idTokenHint?: string;
  prompt?: string;
  loginHint?: string;
  acr?: string;
  connector?: string;
  authorizationId?: string;
};

/**
 * Type pour la mise à jour d'un événement d'interaction
 */
type UpdateInteractionEventParams = {
  interactionId: string;
  event: string;
  params?: Record<string, unknown>;
};

/**
 * Type pour l'identification d'un utilisateur
 */
type IdentifyUserParams = {
  interactionId: string;
  email?: string;
  phone?: string;
  username?: string;
  connectorId?: string;
  code?: string;
};

/**
 * Type pour la soumission d'une interaction
 */
type SubmitInteractionParams = {
  interactionId: string;
  verifierId?: string;
  interactionEvent?: string;
};

/**
 * Type pour la création d'un enregistrement de vérification par mot de passe
 */
type CreatePasswordVerificationParams = {
  interactionId: string;
  password: string;
};

/**
 * Type pour la création et l'envoi d'un code de vérification
 */
type CreateVerificationCodeParams = {
  interactionId: string;
  email?: string;
  phone?: string;
  purpose: string;
};

/**
 * Type pour la vérification d'un code de vérification
 */
type VerifyVerificationCodeParams = {
  interactionId: string;
  email?: string;
  phone?: string;
  code: string;
  purpose: string;
};

/**
 * Type pour la création d'une vérification sociale
 */
type CreateSocialVerificationParams = {
  interactionId: string;
  connectorId: string;
  state?: string;
  redirectUri: string;
};

/**
 * Type pour la vérification d'une vérification sociale
 */
type VerifySocialVerificationParams = {
  interactionId: string;
  connectorId: string;
  data: Record<string, unknown>;
};

/**
 * Type pour la création d'une vérification SSO d'entreprise
 */
type CreateEnterpriseVerificationParams = {
  connectorId: string;
  state?: string;
  redirectUri: string;
};

/**
 * Type pour la vérification d'une vérification SSO d'entreprise
 */
type VerifyEnterpriseVerificationParams = {
  connectorId: string;
  data: Record<string, unknown>;
};

/**
 * Type pour la création d'un secret TOTP
 */
type CreateTotpSecretParams = {
  issuer?: string;
  userName?: string;
};

/**
 * Type pour la vérification d'une vérification TOTP
 */
type VerifyTotpVerificationParams = {
  totp: string;
};

/**
 * Type pour la création d'une vérification d'enregistrement WebAuthn
 */
type CreateWebAuthnRegistrationParams = {
  name: string;
};

/**
 * Type pour la vérification d'une vérification d'enregistrement WebAuthn
 */
type VerifyWebAuthnRegistrationParams = {
  credential: Record<string, unknown>;
  name: string;
};

/**
 * Type pour la création d'une vérification d'authentification WebAuthn
 */
type CreateWebAuthnAuthenticationParams = Record<string, never>;

/**
 * Type pour la vérification d'une vérification d'authentification WebAuthn
 */
type VerifyWebAuthnAuthenticationParams = {
  credential: Record<string, unknown>;
};

/**
 * Type pour la vérification d'un code de secours
 */
type VerifyBackupCodeParams = {
  code: string;
};

/**
 * Type pour la création d'une vérification d'identité par nouveau mot de passe
 */
type CreatePasswordIdentityParams = {
  password: string;
};

/**
 * Type pour la vérification d'un jeton à usage unique
 */
type VerifyOneTimeTokenParams = {
  token: string;
};

/**
 * Type pour l'ajout d'un profil utilisateur
 */
type AddUserProfileParams = {
  username?: string;
  primaryEmail?: string;
  primaryPhone?: string;
  name?: string;
  customData?: Record<string, unknown>;
};

/**
 * Type pour la réinitialisation du mot de passe utilisateur
 */
type ResetUserPasswordParams = {
  password: string;
};

/**
 * Type pour lier une vérification MFA par ID de vérification
 */
type BindMfaVerificationParams = {
  verificationId: string;
};

// Implémentation des fonctions de service

/**
 * Initialise une nouvelle interaction
 */
export async function initInteraction(data: InitInteractionParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/interaction`, {
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
 * Met à jour un événement d'interaction
 */
export async function updateInteractionEvent(data: UpdateInteractionEventParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/interaction/event`, {
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
 * Identifie un utilisateur pour l'interaction en cours
 */
export async function identifyUser(data: IdentifyUserParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/interaction/identifiers`, {
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
 * Soumet une interaction
 */
export async function submitInteraction(data: SubmitInteractionParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/interaction/submit`, {
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
 * Crée un enregistrement de vérification par mot de passe
 */
export async function createPasswordVerification(data: CreatePasswordVerificationParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/interaction/verification/password`, {
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
 * Crée et envoie un code de vérification
 */
export async function createVerificationCode(data: CreateVerificationCodeParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/interaction/verification/verification-code`, {
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
 * Vérifie un code de vérification
 */
export async function verifyVerificationCode(data: VerifyVerificationCodeParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/interaction/verification/verification-code/verify`, {
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
 * Crée une vérification sociale
 */
export async function createSocialVerification(data: CreateSocialVerificationParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/interaction/verification/social`, {
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
 * Vérifie une vérification sociale
 */
export async function verifySocialVerification(data: VerifySocialVerificationParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/interaction/verification/social/verify`, {
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
 * Crée une vérification SSO d'entreprise
 */
export async function createEnterpriseVerification(data: CreateEnterpriseVerificationParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/interaction/verification/enterprise-sso`, {
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
 * Vérifie une vérification SSO d'entreprise
 */
export async function verifyEnterpriseVerification(data: VerifyEnterpriseVerificationParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/interaction/verification/enterprise-sso/verify`, {
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
 * Crée un secret TOTP
 */
export async function createTotpSecret(data: CreateTotpSecretParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/interaction/verification/totp`, {
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
 * Vérifie une vérification TOTP
 */
export async function verifyTotpVerification(data: VerifyTotpVerificationParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/interaction/verification/totp/verify`, {
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
 * Crée une vérification d'enregistrement WebAuthn
 */
export async function createWebAuthnRegistration(data: CreateWebAuthnRegistrationParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/interaction/verification/webauthn-registration`, {
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
 * Vérifie une vérification d'enregistrement WebAuthn
 */
export async function verifyWebAuthnRegistration(data: VerifyWebAuthnRegistrationParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/interaction/verification/webauthn-registration/verify`, {
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
 * Crée une vérification d'authentification WebAuthn
 */
export async function createWebAuthnAuthentication() {
  const response = await fetch(`${process.env.LOGTO_URL}/api/interaction/verification/webauthn-authentication`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({})
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
}

/**
 * Vérifie une vérification d'authentification WebAuthn
 */
export async function verifyWebAuthnAuthentication(data: VerifyWebAuthnAuthenticationParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/interaction/verification/webauthn-authentication/verify`, {
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
 * Génère des codes de secours
 */
export async function generateBackupCodes() {
  const response = await fetch(`${process.env.LOGTO_URL}/api/interaction/verification/backup-code`, {
    method: 'POST',
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
 * Vérifie un code de secours
 */
export async function verifyBackupCode(data: VerifyBackupCodeParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/interaction/verification/backup-code/verify`, {
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
 * Crée une vérification d'identité par nouveau mot de passe
 */
export async function createPasswordIdentity(data: CreatePasswordIdentityParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/interaction/verification/new-password`, {
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
 * Vérifie un jeton à usage unique
 */
export async function verifyOneTimeToken(data: VerifyOneTimeTokenParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/interaction/verification/token`, {
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
 * Ajoute un profil utilisateur
 */
export async function addUserProfile(data: AddUserProfileParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/interaction/profile`, {
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
 * Réinitialise le mot de passe utilisateur
 */
export async function resetUserPassword(data: ResetUserPasswordParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/interaction/password`, {
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
 * Ignore le flux de liaison MFA
 */
export async function skipMfaBinding() {
  const response = await fetch(`${process.env.LOGTO_URL}/api/interaction/mfa-skipped`, {
    method: 'POST',
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
 * Lie une vérification MFA par ID de vérification
 */
export async function bindMfaVerification(data: BindMfaVerificationParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/interaction/bind-mfa`, {
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
 * Récupère les connecteurs SSO activés pour un domaine d'email donné
 */
export async function getEnabledSsoConnectors(email: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/interaction/single-sign-on/connectors?email=${encodeURIComponent(email)}`, {
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
