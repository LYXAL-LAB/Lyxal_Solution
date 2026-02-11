import { apiClient } from './config';
import { PaginationOptions, PaginatedResponse } from './types';

interface EmailTemplate {
  id: string;
  type: string;
  subject: string;
  content: {
    title?: string;
    sender?: string;
    actionUrl?: string;
    code?: string;
    identities?: Array<{
      target: string;
      details?: Record<string, any>;
    }>;
  };
  createdAt: string;
}

/**
 * Récupère les modèles d'emails
 */
export const getEmailTemplates = async (
  options?: PaginationOptions
): Promise<PaginatedResponse<EmailTemplate>> => {
  const queryParams = new URLSearchParams();
  
  if (options) {
    if (options.page) queryParams.append('page', options.page.toString());
    if (options.pageSize) queryParams.append('page_size', options.pageSize.toString());
  }
  
  const query = queryParams.toString() ? `?${queryParams.toString()}` : '';
  return apiClient<PaginatedResponse<EmailTemplate>>(`/email-templates${query}`);
};

/**
 * Remplace les modèles d'emails
 */
export const replaceEmailTemplates = async (
  templates: Array<{
    type: string;
    subject: string;
    content: {
      title?: string;
      sender?: string;
      actionUrl?: string;
      code?: string;
      identities?: Array<{
        target: string;
        details?: Record<string, any>;
      }>;
    };
  }>
): Promise<EmailTemplate[]> => {
  return apiClient<EmailTemplate[]>('/email-templates', {
    method: 'PUT',
    body: JSON.stringify({ templates }),
  });
};

/**
 * Supprime les modèles d'emails
 */
export const deleteEmailTemplates = async (): Promise<void> => {
  return apiClient<void>('/email-templates', {
    method: 'DELETE',
  });
};

/**
 * Récupère un modèle d'email par son ID
 */
export const getEmailTemplateById = async (templateId: string): Promise<EmailTemplate> => {
  return apiClient<EmailTemplate>(`/email-templates/${templateId}`);
};

/**
 * Supprime un modèle d'email
 */
export const deleteEmailTemplate = async (templateId: string): Promise<void> => {
  return apiClient<void>(`/email-templates/${templateId}`, {
    method: 'DELETE',
  });
};

/**
 * Met à jour un modèle d'email
 */
export const updateEmailTemplate = async (
  templateId: string,
  templateData: {
    subject?: string;
    content?: {
      title?: string;
      sender?: string;
      actionUrl?: string;
      code?: string;
      identities?: Array<{
        target: string;
        details?: Record<string, any>;
      }>;
    };
  }
): Promise<EmailTemplate> => {
  return apiClient<EmailTemplate>(`/email-templates/${templateId}`, {
    method: 'PATCH',
    body: JSON.stringify(templateData),
  });
}; 