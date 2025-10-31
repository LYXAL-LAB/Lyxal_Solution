import { apiClient, setAuthToken, removeAuthToken } from './config';
import { AuthResponse } from './types';

/**
 * Authentifie un utilisateur avec son email/username et mot de passe
 */
export const login = async (
  identifier: string, 
  password: string
): Promise<AuthResponse> => {
  const response = await apiClient<AuthResponse>('/auth/login', {
    method: 'POST',
    body: JSON.stringify({ identifier, password }),
  });
  
  if (response.accessToken) {
    setAuthToken(response.accessToken);
  }
  
  return response;
};

/**
 * Authentifie avec un code de vérification (email ou SMS)
 */
export const loginWithCode = async (
  identifier: string,
  code: string
): Promise<AuthResponse> => {
  const response = await apiClient<AuthResponse>('/auth/login/code', {
    method: 'POST',
    body: JSON.stringify({ identifier, code }),
  });
  
  if (response.accessToken) {
    setAuthToken(response.accessToken);
  }
  
  return response;
};

/**
 * Enregistre un nouvel utilisateur
 */
export const register = async (
  userData: {
    username?: string;
    email?: string;
    phone?: string;
    password?: string;
    name?: string;
  }
): Promise<AuthResponse> => {
  const response = await apiClient<AuthResponse>('/auth/register', {
    method: 'POST',
    body: JSON.stringify(userData),
  });
  
  if (response.accessToken) {
    setAuthToken(response.accessToken);
  }
  
  return response;
};

/**
 * Déconnecte l'utilisateur courant
 */
export const logout = async (): Promise<void> => {
  await apiClient('/auth/logout', { method: 'POST' });
  removeAuthToken();
};

/**
 * Rafraîchit le token d'accès
 */
export const refreshToken = async (
  refreshToken: string
): Promise<AuthResponse> => {
  const response = await apiClient<AuthResponse>('/auth/token', {
    method: 'POST',
    body: JSON.stringify({ grant_type: 'refresh_token', refresh_token: refreshToken }),
  });
  
  if (response.accessToken) {
    setAuthToken(response.accessToken);
  }
  
  return response;
};

/**
 * Initialise la réinitialisation du mot de passe
 */
export const forgotPassword = async (
  email: string
): Promise<{ success: boolean }> => {
  return apiClient<{ success: boolean }>('/auth/forgot-password', {
    method: 'POST',
    body: JSON.stringify({ email }),
  });
};

/**
 * Réinitialise le mot de passe avec un token
 */
export const resetPassword = async (
  token: string,
  newPassword: string
): Promise<{ success: boolean }> => {
  return apiClient<{ success: boolean }>('/auth/reset-password', {
    method: 'POST',
    body: JSON.stringify({ token, password: newPassword }),
  });
};

/**
 * Vérifie si l'utilisateur est authentifié
 */
export const isAuthenticated = (): boolean => {
  const token = localStorage.getItem('lyxalauth_token');
  return !!token;
};

/**
 * Récupère les informations sur l'utilisateur courant
 */
export const getCurrentUser = async () => {
  return apiClient('/auth/me');
};

/**
 * Obtenir un token pour accéder à une API spécifique
 */
export const getAccessToken = async (
  resource: string,
  scopes: string[]
): Promise<{ access_token: string; expires_in: number }> => {
  return apiClient('/auth/token', {
    method: 'POST',
    body: JSON.stringify({
      grant_type: 'client_credentials',
      resource,
      scope: scopes.join(' '),
    }),
  });
}; 