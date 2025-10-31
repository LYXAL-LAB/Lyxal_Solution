import { apiClient } from './config';
import { PaginationOptions, PaginatedResponse } from './types';

interface SAMLApplication {
  id: string;
  name: string;
  description?: string;
  protocol: 'saml';
  oidcClientMetadata: {
    redirectUris: string[];
    postLogoutRedirectUris: string[];
    clientUri?: string;
    logoUri?: string;
  };
  samlConfig: {
    entityId: string;
    acsUrl: string;
    certificateType: string;
    certificate: string;
    encryptedAssertion: boolean;
    signatureAlgorithm: string;
    digestAlgorithm: string;
    attributeMapping?: Record<string, string>;
    customAttributes?: Record<string, string>;
  };
  customClientMetadata?: Record<string, any>;
  createdAt: string;
}

/**
 * Crée une application SAML
 */
export const createSAMLApplication = async (
  applicationData: {
    name: string;
    description?: string;
    samlConfig: {
      entityId: string;
      acsUrl: string;
      certificateType: string;
      certificate: string;
      encryptedAssertion?: boolean;
      signatureAlgorithm?: string;
      digestAlgorithm?: string;
      attributeMapping?: Record<string, string>;
      customAttributes?: Record<string, string>;
    };
  }
): Promise<SAMLApplication> => {
  return apiClient<SAMLApplication>('/saml-applications', {
    method: 'POST',
    body: JSON.stringify(applicationData),
  });
};

/**
 * Récupère une application SAML par son ID
 */
export const getSAMLApplication = async (applicationId: string): Promise<SAMLApplication> => {
  return apiClient<SAMLApplication>(`/saml-applications/${applicationId}`);
};

/**
 * Supprime une application SAML
 */
export const deleteSAMLApplication = async (applicationId: string): Promise<void> => {
  return apiClient<void>(`/saml-applications/${applicationId}`, {
    method: 'DELETE',
  });
};

/**
 * Met à jour une application SAML
 */
export const updateSAMLApplication = async (
  applicationId: string,
  applicationData: {
    name?: string;
    description?: string;
    samlConfig?: {
      encryptedAssertion?: boolean;
      signatureAlgorithm?: string;
      digestAlgorithm?: string;
      attributeMapping?: Record<string, string>;
      customAttributes?: Record<string, string>;
    };
  }
): Promise<SAMLApplication> => {
  return apiClient<SAMLApplication>(`/saml-applications/${applicationId}`, {
    method: 'PATCH',
    body: JSON.stringify(applicationData),
  });
};

/**
 * Récupère les secrets d'une application SAML
 */
export const getSAMLApplicationSecrets = async (
  applicationId: string
): Promise<{ secrets: Array<{ id: string; createdAt: string }> }> => {
  return apiClient<{ secrets: Array<{ id: string; createdAt: string }> }>(
    `/saml-applications/${applicationId}/secrets`
  );
};

/**
 * Crée un secret pour une application SAML
 */
export const createSAMLApplicationSecret = async (
  applicationId: string
): Promise<{ id: string; secret: string; createdAt: string }> => {
  return apiClient<{ id: string; secret: string; createdAt: string }>(
    `/saml-applications/${applicationId}/secrets`,
    {
      method: 'POST',
    }
  );
};

/**
 * Supprime un secret d'une application SAML
 */
export const deleteSAMLApplicationSecret = async (
  applicationId: string,
  secretId: string
): Promise<void> => {
  return apiClient<void>(`/saml-applications/${applicationId}/secrets/${secretId}`, {
    method: 'DELETE',
  });
};

/**
 * Met à jour un secret d'une application SAML
 */
export const updateSAMLApplicationSecret = async (
  applicationId: string,
  secretId: string,
  status: 'Active' | 'Revoked'
): Promise<{ id: string; createdAt: string; status: string }> => {
  return apiClient<{ id: string; createdAt: string; status: string }>(
    `/saml-applications/${applicationId}/secrets/${secretId}`,
    {
      method: 'PATCH',
      body: JSON.stringify({ status }),
    }
  );
};

/**
 * Récupère les métadonnées d'une application SAML
 */
export const getSAMLApplicationMetadata = async (
  applicationId: string
): Promise<string> => {
  return apiClient<string>(`/saml-applications/${applicationId}/metadata`, {
    headers: {
      Accept: 'application/xml',
    },
  });
}; 