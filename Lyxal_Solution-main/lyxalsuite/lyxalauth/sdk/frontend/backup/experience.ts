import { apiClient } from './config';
import { SignInExperience } from './types';

/**
 * Initialise une nouvelle interaction
 */
export const initNewInteraction = async (
  interactionData: {
    clientId: string;
    redirectUri: string;
    state?: string;
    scope?: string;
    responseType?: string;
    prompt?: string;
  }
): Promise<{ interactionId: string; redirectTo: string }> => {
  return apiClient<{ interactionId: string; redirectTo: string }>('/experience/interaction', {
    method: 'PUT',
    body: JSON.stringify(interactionData),
  });
};

/**
 * Met à jour un événement d'interaction
 */
export const updateInteractionEvent = async (
  interactionId: string,
  event: string
): Promise<{ success: boolean }> => {
  return apiClient<{ success: boolean }>('/experience/interaction/event', {
    method: 'PUT',
    body: JSON.stringify({ interactionId, event }),
  });
};

/**
 * Identifie un utilisateur pour l'interaction en cours
 */
export const identifyUserForInteraction = async (
  interactionId: string,
  identityData: {
    email?: string;
    phone?: string;
    username?: string;
    connectorId?: string;
  }
): Promise<{ redirectTo?: string; exists: boolean }> => {
  return apiClient<{ redirectTo?: string; exists: boolean }>('/experience/interaction/identify', {
    method: 'POST',
    body: JSON.stringify({ interactionId, ...identityData }),
  });
};

/**
 * Soumet une interaction
 */
export const submitInteraction = async (
  interactionId: string,
  data?: Record<string, any>
): Promise<{ redirectTo: string }> => {
  return apiClient<{ redirectTo: string }>('/experience/interaction/submit', {
    method: 'POST',
    body: JSON.stringify({ interactionId, ...data }),
  });
};

/**
 * Crée une vérification par mot de passe
 */
export const createPasswordVerification = async (
  interactionId: string,
  password: string
): Promise<{ success: boolean }> => {
  return apiClient<{ success: boolean }>('/experience/verification-password', {
    method: 'POST',
    body: JSON.stringify({ interactionId, password }),
  });
};

/**
 * Crée et envoie un code de vérification
 */
export const createAndSendVerificationCode = async (
  interactionId: string,
  target: {
    email?: string;
    phone?: string;
  },
  purpose: 'SignIn' | 'Register' | 'ForgotPassword'
): Promise<{ success: boolean }> => {
  return apiClient<{ success: boolean }>('/experience/verification-code', {
    method: 'POST',
    body: JSON.stringify({ interactionId, target, purpose }),
  });
};

/**
 * Vérifie un code de vérification
 */
export const verifyVerificationCode = async (
  interactionId: string,
  code: string
): Promise<{ success: boolean }> => {
  return apiClient<{ success: boolean }>('/experience/verify-code', {
    method: 'POST',
    body: JSON.stringify({ interactionId, code }),
  });
};

/**
 * Crée une vérification sociale
 */
export const createSocialVerification = async (
  interactionId: string,
  connectorId: string
): Promise<{ redirectTo: string }> => {
  return apiClient<{ redirectTo: string }>('/experience/social-verification', {
    method: 'POST',
    body: JSON.stringify({ interactionId, connectorId }),
  });
};

/**
 * Vérifie une vérification sociale
 */
export const verifySocialVerification = async (
  interactionId: string,
  data: {
    code: string;
    state: string;
  }
): Promise<{ success: boolean }> => {
  return apiClient<{ success: boolean }>('/experience/verify-social', {
    method: 'POST',
    body: JSON.stringify({ interactionId, ...data }),
  });
};

/**
 * Crée une vérification SSO d'entreprise
 */
export const createEnterpriseSSOVerification = async (
  interactionId: string,
  connectorId: string
): Promise<{ redirectTo: string }> => {
  return apiClient<{ redirectTo: string }>('/experience/enterprise-sso-verification', {
    method: 'POST',
    body: JSON.stringify({ interactionId, connectorId }),
  });
};

/**
 * Vérifie une vérification SSO d'entreprise
 */
export const verifyEnterpriseSSOVerification = async (
  interactionId: string,
  data: {
    code: string;
    state: string;
  }
): Promise<{ success: boolean }> => {
  return apiClient<{ success: boolean }>('/experience/verify-enterprise-sso', {
    method: 'POST',
    body: JSON.stringify({ interactionId, ...data }),
  });
};

/**
 * Ajoute un profil utilisateur
 */
export const addUserProfile = async (
  interactionId: string,
  profile: {
    name?: string;
    avatar?: string;
    customData?: Record<string, any>;
  }
): Promise<{ success: boolean }> => {
  return apiClient<{ success: boolean }>('/experience/profile', {
    method: 'POST',
    body: JSON.stringify({ interactionId, profile }),
  });
};

/**
 * Réinitialise le mot de passe d'un utilisateur
 */
export const resetUserPassword = async (
  interactionId: string,
  password: string
): Promise<{ success: boolean }> => {
  return apiClient<{ success: boolean }>('/experience/reset-password', {
    method: 'PUT',
    body: JSON.stringify({ interactionId, password }),
  });
};

/**
 * Ignore le flux de liaison MFA
 */
export const skipMFABindingFlow = async (
  interactionId: string
): Promise<{ success: boolean }> => {
  return apiClient<{ success: boolean }>('/experience/skip-mfa', {
    method: 'POST',
    body: JSON.stringify({ interactionId }),
  });
};

/**
 * Lie une vérification MFA par ID de vérification
 */
export const bindMFAVerificationById = async (
  interactionId: string,
  verificationId: string
): Promise<{ success: boolean }> => {
  return apiClient<{ success: boolean }>('/experience/bind-mfa', {
    method: 'POST',
    body: JSON.stringify({ interactionId, verificationId }),
  });
};

/**
 * Récupère les connecteurs SSO activés pour un domaine d'email donné
 */
export const getEnabledSSOConnectorsByEmail = async (
  email: string
): Promise<{ connectors: Array<{ id: string; name: string; type: string }> }> => {
  return apiClient<{ connectors: Array<{ id: string; name: string; type: string }> }>(
    `/experience/sso-connectors?email=${encodeURIComponent(email)}`
  );
};

/**
 * Récupère l'expérience de connexion par défaut
 */
export const getDefaultSignInExperience = async (): Promise<SignInExperience> => {
  return apiClient<SignInExperience>('/experience/sign-in');
};

/**
 * Met à jour l'expérience de connexion par défaut
 */
export const updateDefaultSignInExperience = async (
  experienceData: Partial<SignInExperience>
): Promise<SignInExperience> => {
  return apiClient<SignInExperience>('/experience/sign-in', {
    method: 'PATCH',
    body: JSON.stringify(experienceData),
  });
};

/**
 * Vérifie si un mot de passe répond aux critères de la politique de mot de passe
 */
export const checkPasswordMeetsPolicy = async (
  password: string
): Promise<{ success: boolean; validateResults: Array<{ message: string; satisfied: boolean }> }> => {
  return apiClient<{ success: boolean; validateResults: Array<{ message: string; satisfied: boolean }> }>(
    '/experience/password-policy',
    {
      method: 'POST',
      body: JSON.stringify({ password }),
    }
  );
}; 