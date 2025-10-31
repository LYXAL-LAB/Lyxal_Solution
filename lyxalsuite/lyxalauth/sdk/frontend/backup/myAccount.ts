import { apiClient } from './config';
import { User } from './types';

/**
 * Récupère le profil de l'utilisateur connecté
 */
export const getMyProfile = async (): Promise<User> => {
  return apiClient<User>('/my/profile');
};

/**
 * Met à jour le profil de l'utilisateur connecté
 */
export const updateMyProfile = async (
  profileData: {
    name?: string;
    avatar?: string;
    customData?: Record<string, any>;
  }
): Promise<User> => {
  return apiClient<User>('/my/profile', {
    method: 'PATCH',
    body: JSON.stringify(profileData),
  });
};

/**
 * Récupère les informations de sécurité de l'utilisateur connecté
 */
export const getMySecurityInfo = async (): Promise<{
  mfa: {
    enabled: boolean;
    primary?: string;
    verifications: Array<{
      id: string;
      type: string;
      createdAt: string;
    }>;
  };
  password: {
    set: boolean;
    updatedAt?: string;
  };
}> => {
  return apiClient<{
    mfa: {
      enabled: boolean;
      primary?: string;
      verifications: Array<{
        id: string;
        type: string;
        createdAt: string;
      }>;
    };
    password: {
      set: boolean;
      updatedAt?: string;
    };
  }>('/my/security');
};

/**
 * Met à jour le mot de passe de l'utilisateur connecté
 */
export const updateMyPassword = async (
  passwordData: {
    currentPassword: string;
    newPassword: string;
  }
): Promise<{ success: boolean }> => {
  return apiClient<{ success: boolean }>('/my/password', {
    method: 'PATCH',
    body: JSON.stringify(passwordData),
  });
};

/**
 * Récupère les identifiants de l'utilisateur connecté
 */
export const getMyIdentities = async (): Promise<Array<{
  target: string;
  type: 'email' | 'phone' | 'username' | 'social';
  details?: Record<string, any>;
}>> => {
  return apiClient<
    Array<{
      target: string;
      type: 'email' | 'phone' | 'username' | 'social';
      details?: Record<string, any>;
    }>
  >('/my/identities');
};

/**
 * Lie un identifiant à l'utilisateur connecté
 */
export const bindMyIdentity = async (
  identityData: {
    target: string;
    type: 'email' | 'phone' | 'username';
    code?: string;
    password?: string;
  }
): Promise<{
  target: string;
  type: 'email' | 'phone' | 'username';
}> => {
  return apiClient<{
    target: string;
    type: 'email' | 'phone' | 'username';
  }>('/my/identities', {
    method: 'POST',
    body: JSON.stringify(identityData),
  });
};

/**
 * Détache un identifiant de l'utilisateur connecté
 */
export const unbindMyIdentity = async (
  type: 'email' | 'phone' | 'username' | 'social',
  target: string
): Promise<void> => {
  return apiClient<void>(`/my/identities/${type}/${encodeURIComponent(target)}`, {
    method: 'DELETE',
  });
};

/**
 * Récupère les vérifications MFA de l'utilisateur connecté
 */
export const getMyMfaVerifications = async (): Promise<Array<{
  id: string;
  type: string;
  createdAt: string;
}>> => {
  return apiClient<
    Array<{
      id: string;
      type: string;
      createdAt: string;
    }>
  >('/my/mfa');
};

/**
 * Crée une vérification MFA pour l'utilisateur connecté
 */
export const createMyMfaVerification = async (
  verificationType: string
): Promise<{
  id: string;
  type: string;
  secret?: string;
  qrCode?: string;
}> => {
  return apiClient<{
    id: string;
    type: string;
    secret?: string;
    qrCode?: string;
  }>('/my/mfa', {
    method: 'POST',
    body: JSON.stringify({ type: verificationType }),
  });
};

/**
 * Supprime une vérification MFA de l'utilisateur connecté
 */
export const deleteMyMfaVerification = async (
  verificationId: string
): Promise<void> => {
  return apiClient<void>(`/my/mfa/${verificationId}`, {
    method: 'DELETE',
  });
};

/**
 * Définit une vérification MFA comme primaire
 */
export const setMyPrimaryMfaVerification = async (
  verificationId: string
): Promise<void> => {
  return apiClient<void>(`/my/mfa/${verificationId}/primary`, {
    method: 'PATCH',
  });
};

/**
 * Vérifie une vérification MFA
 */
export const verifyMyMfaVerification = async (
  verificationId: string,
  code: string
): Promise<{ success: boolean }> => {
  return apiClient<{ success: boolean }>(`/my/mfa/${verificationId}/verify`, {
    method: 'POST',
    body: JSON.stringify({ code }),
  });
};

/**
 * Récupère la clé d'API de l'utilisateur connecté
 */
export const getMyApiKey = async (): Promise<{
  id: string;
  name: string;
  key?: string;
  createdAt: string;
}> => {
  return apiClient<{
    id: string;
    name: string;
    key?: string;
    createdAt: string;
  }>('/my/api-key');
};

/**
 * Crée ou remplace la clé d'API de l'utilisateur connecté
 */
export const createOrReplaceMyApiKey = async (
  name: string
): Promise<{
  id: string;
  name: string;
  key: string;
  createdAt: string;
}> => {
  return apiClient<{
    id: string;
    name: string;
    key: string;
    createdAt: string;
  }>('/my/api-key', {
    method: 'PUT',
    body: JSON.stringify({ name }),
  });
};

/**
 * Supprime la clé d'API de l'utilisateur connecté
 */
export const deleteMyApiKey = async (): Promise<void> => {
  return apiClient<void>('/my/api-key', {
    method: 'DELETE',
  });
}; 