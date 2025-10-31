import { apiClient } from './config';
import { Connector, PaginationOptions, PaginatedResponse } from './types';

/**
 * Récupère la liste des connecteurs
 */
export const getConnectors = async (
  options?: PaginationOptions & { 
    target?: 'social' | 'email' | 'sms'; 
    enabled?: boolean;
  }
): Promise<PaginatedResponse<Connector>> => {
  const queryParams = new URLSearchParams();
  
  if (options) {
    if (options.page) queryParams.append('page', options.page.toString());
    if (options.pageSize) queryParams.append('page_size', options.pageSize.toString());
    if (options.target) queryParams.append('target', options.target);
    if (options.enabled !== undefined) queryParams.append('enabled', options.enabled.toString());
  }
  
  const query = queryParams.toString() ? `?${queryParams.toString()}` : '';
  return apiClient<PaginatedResponse<Connector>>(`/connectors${query}`);
};

/**
 * Récupère un connecteur par son ID
 */
export const getConnector = async (connectorId: string): Promise<Connector> => {
  return apiClient<Connector>(`/connectors/${connectorId}`);
};

/**
 * Crée un nouveau connecteur
 */
export const createConnector = async (connectorData: {
  connectorId: string;
  config: Record<string, any>;
}): Promise<Connector> => {
  return apiClient<Connector>('/connectors', {
    method: 'POST',
    body: JSON.stringify(connectorData),
  });
};

/**
 * Met à jour un connecteur
 */
export const updateConnector = async (
  connectorId: string,
  connectorData: {
    config?: Record<string, any>;
    enabled?: boolean;
  }
): Promise<Connector> => {
  return apiClient<Connector>(`/connectors/${connectorId}`, {
    method: 'PATCH',
    body: JSON.stringify(connectorData),
  });
};

/**
 * Supprime un connecteur
 */
export const deleteConnector = async (connectorId: string): Promise<void> => {
  return apiClient<void>(`/connectors/${connectorId}`, {
    method: 'DELETE',
  });
};

/**
 * Teste un connecteur sans mot de passe
 */
export const testPasswordlessConnector = async (
  connectorId: string,
  config: Record<string, any>,
  phone?: string,
  email?: string
): Promise<{ success: boolean; message?: string }> => {
  return apiClient<{ success: boolean; message?: string }>(`/connectors/${connectorId}/test`, {
    method: 'POST',
    body: JSON.stringify({ config, phone, email }),
  });
};

/**
 * Récupère l'URI d'autorisation d'un connecteur
 */
export const getConnectorAuthorizationUri = async (
  connectorId: string,
  state?: string,
  redirectUri?: string
): Promise<{ redirectTo: string }> => {
  return apiClient<{ redirectTo: string }>('/connectors/authorization-uri', {
    method: 'POST',
    body: JSON.stringify({ connectorId, state, redirectUri }),
  });
};

/**
 * Récupère la liste des usines de connecteurs
 */
export const getConnectorFactories = async (
  type?: 'social' | 'email' | 'sms'
): Promise<Array<{
  id: string;
  name: string;
  type: string;
  description: string;
  logo: string;
  logoDark?: string;
  target: string[];
  isStandard: boolean;
}>> => {
  const query = type ? `?type=${type}` : '';
  return apiClient<
    Array<{
      id: string;
      name: string;
      type: string;
      description: string;
      logo: string;
      logoDark?: string;
      target: string[];
      isStandard: boolean;
    }>
  >(`/connector-factories${query}`);
};

/**
 * Récupère une usine de connecteur par son ID
 */
export const getConnectorFactory = async (factoryId: string): Promise<{
  id: string;
  name: string;
  type: string;
  description: string;
  logo: string;
  logoDark?: string;
  target: string[];
  isStandard: boolean;
  configTemplate: Record<string, any>;
}> => {
  return apiClient<{
    id: string;
    name: string;
    type: string;
    description: string;
    logo: string;
    logoDark?: string;
    target: string[];
    isStandard: boolean;
    configTemplate: Record<string, any>;
  }>(`/connector-factories/${factoryId}`);
};

/**
 * Récupère les fournisseurs de connecteurs SSO
 */
export const getSSOConnectorProviders = async (): Promise<Array<{
  id: string;
  name: string;
  logo: string;
  logoDark?: string;
  description: string;
}>> => {
  return apiClient<
    Array<{
      id: string;
      name: string;
      logo: string;
      logoDark?: string;
      description: string;
    }>
  >('/sso-connector-providers');
};

/**
 * Récupère la liste des connecteurs SSO
 */
export const getSSOConnectors = async (
  options?: PaginationOptions & { enabled?: boolean }
): Promise<PaginatedResponse<{
  id: string;
  connectorId: string;
  name: string;
  logo?: string;
  logoDark?: string;
  config: Record<string, any>;
  domains: string[];
  enabled: boolean;
  createdAt: string;
}>> => {
  const queryParams = new URLSearchParams();
  
  if (options) {
    if (options.page) queryParams.append('page', options.page.toString());
    if (options.pageSize) queryParams.append('page_size', options.pageSize.toString());
    if (options.enabled !== undefined) queryParams.append('enabled', options.enabled.toString());
  }
  
  const query = queryParams.toString() ? `?${queryParams.toString()}` : '';
  return apiClient<
    PaginatedResponse<{
      id: string;
      connectorId: string;
      name: string;
      logo?: string;
      logoDark?: string;
      config: Record<string, any>;
      domains: string[];
      enabled: boolean;
      createdAt: string;
    }>
  >(`/sso-connectors${query}`);
}; 