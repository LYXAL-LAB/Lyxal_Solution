import { apiClient } from './config';

/**
 * Crée et envoie un code de vérification
 */
export const createVerificationCode = async (
  data: {
    identifier: string;
    type: 'Email' | 'Phone';
    purpose: 'SignIn' | 'Register' | 'ForgotPassword' | 'ResetPassword';
  }
): Promise<{ id: string; message?: string }> => {
  return apiClient<{ id: string; message?: string }>('/verification/code', {
    method: 'POST',
    body: JSON.stringify(data),
  });
};

/**
 * Vérifie un code de vérification
 */
export const verifyCode = async (
  verificationId: string,
  code: string
): Promise<{ success: boolean }> => {
  return apiClient<{ success: boolean }>(`/verification/code/${verificationId}`, {
    method: 'POST',
    body: JSON.stringify({ code }),
  });
};

/**
 * Crée un lien de vérification par email
 */
export const createEmailLink = async (
  data: {
    email: string;
    purpose: 'SignIn' | 'Register' | 'ForgotPassword' | 'ResetPassword';
    redirectUri?: string;
  }
): Promise<{ id: string; message?: string }> => {
  return apiClient<{ id: string; message?: string }>('/verification/email-link', {
    method: 'POST',
    body: JSON.stringify(data),
  });
};

/**
 * Vérifie un lien de vérification par email
 */
export const verifyEmailLink = async (
  token: string
): Promise<{ success: boolean; redirectUri?: string }> => {
  return apiClient<{ success: boolean; redirectUri?: string }>('/verification/email-link/verify', {
    method: 'POST',
    body: JSON.stringify({ token }),
  });
};

/**
 * Crée une vérification TOTP
 */
export const createTOTPVerification = async (
  purpose?: string
): Promise<{
  id: string;
  secret: string;
  qrCode: string;
}> => {
  const params = purpose ? `?purpose=${encodeURIComponent(purpose)}` : '';
  return apiClient<{
    id: string;
    secret: string;
    qrCode: string;
  }>(`/verification/totp${params}`, {
    method: 'POST',
  });
};

/**
 * Vérifie un code TOTP
 */
export const verifyTOTP = async (
  verificationId: string,
  code: string
): Promise<{ success: boolean }> => {
  return apiClient<{ success: boolean }>(`/verification/totp/${verificationId}`, {
    method: 'POST',
    body: JSON.stringify({ code }),
  });
};

/**
 * Crée une vérification sociale
 */
export const createSocialVerification = async (
  data: {
    connectorId: string;
    redirectUri?: string;
    state?: string;
  }
): Promise<{ redirectTo: string }> => {
  return apiClient<{ redirectTo: string }>('/verification/social', {
    method: 'POST',
    body: JSON.stringify(data),
  });
};

/**
 * Vérifie une vérification sociale
 */
export const verifySocial = async (
  data: {
    state: string;
    code: string;
  }
): Promise<{
  connectorId: string;
  connectorName?: string;
  userInfo: {
    id: string;
    name?: string;
    avatar?: string;
    email?: string;
    phone?: string;
    identities?: Record<string, any>;
  };
}> => {
  return apiClient<{
    connectorId: string;
    connectorName?: string;
    userInfo: {
      id: string;
      name?: string;
      avatar?: string;
      email?: string;
      phone?: string;
      identities?: Record<string, any>;
    };
  }>('/verification/social/verify', {
    method: 'POST',
    body: JSON.stringify(data),
  });
}; 