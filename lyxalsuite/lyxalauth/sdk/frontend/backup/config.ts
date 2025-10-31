interface SDKConfig {
  baseUrl: string;
  headers: Record<string, string>;
  tokenKey: string;
}

/**
 * Configuration du SDK frontend
 */
let config: SDKConfig = {
  baseUrl: '',
  headers: {
    'Content-Type': 'application/json',
  },
  tokenKey: 'lyxalauth_token',
};

/**
 * Initialise la configuration du SDK
 */
export const fetchConfig = async (baseUrl: string): Promise<void> => {
  config.baseUrl = baseUrl;
};

/**
 * Récupère la configuration actuelle du SDK
 */
export const getConfig = (): SDKConfig => {
  return { ...config };
};

/**
 * Met à jour les headers de la configuration
 */
export const updateHeaders = (headers: Record<string, string>): void => {
  config.headers = {
    ...config.headers,
    ...headers,
  };
};

/**
 * Ajoute le token d'authentification aux headers
 */
export const setAuthToken = (token: string): void => {
  localStorage.setItem(config.tokenKey, token);
  updateHeaders({
    Authorization: `Bearer ${token}`,
  });
};

/**
 * Récupère le token d'authentification
 */
export const getAuthToken = (): string | null => {
  return localStorage.getItem(config.tokenKey);
};

/**
 * Supprime le token d'authentification
 */
export const removeAuthToken = (): void => {
  localStorage.removeItem(config.tokenKey);
  const { Authorization, ...restHeaders } = config.headers;
  config.headers = restHeaders;
};

/**
 * Client fetch de base pour toutes les requêtes API
 */
export const apiClient = async <T>(
  endpoint: string,
  options: RequestInit = {}
): Promise<T> => {
  const token = getAuthToken();
  
  const headers = {
    ...config.headers,
    ...(token ? { Authorization: `Bearer ${token}` } : {}),
    ...options.headers,
  };

  const url = endpoint.startsWith('http') 
    ? endpoint 
    : `${config.baseUrl}${endpoint.startsWith('/') ? '' : '/'}${endpoint}`;

  const response = await fetch(url, {
    ...options,
    headers,
  });

  if (!response.ok) {
    const errorData = await response.json().catch(() => ({ message: 'Erreur inconnue' }));
    throw new Error(errorData.message || `Erreur ${response.status}`);
  }

  // Pour les réponses 204 No Content
  if (response.status === 204) {
    return {} as T;
  }

  return await response.json();
};

export default {
  fetchConfig,
  getConfig,
  updateHeaders,
  setAuthToken,
  getAuthToken,
  removeAuthToken,
  apiClient,
}; 