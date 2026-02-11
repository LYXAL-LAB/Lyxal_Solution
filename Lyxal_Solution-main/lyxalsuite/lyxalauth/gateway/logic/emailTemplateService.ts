/**
 * Service pour gérer les interactions avec l'API Logto concernant les modèles d'emails
 */

/**
 * Type pour les paramètres de mise à jour des détails d'un modèle d'email
 */
type UpdateEmailTemplateParams = {
  subject?: string;
  content?: {
    title?: string;
    subtitle?: string;
    actionLabel?: string;
    content?: string[];
  };
};

/**
 * Récupère tous les modèles d'emails
 */
export async function getEmailTemplates() {
  const response = await fetch(`${process.env.LOGTO_URL}/api/email-templates`, {
    method: 'GET',
    headers: {
      Authorization: `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
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
 * Remplace les modèles d'emails
 * @param templates Les nouveaux modèles d'emails
 */
export async function replaceEmailTemplates(templates: Record<string, unknown>) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/email-templates`, {
    method: 'PUT',
    headers: {
      Authorization: `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(templates)
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
}

/**
 * Supprime tous les modèles d'emails
 */
export async function deleteAllEmailTemplates() {
  const response = await fetch(`${process.env.LOGTO_URL}/api/email-templates`, {
    method: 'DELETE',
    headers: {
      Authorization: `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
      'Content-Type': 'application/json'
    }
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return { success: true };
}

/**
 * Récupère un modèle d'email par son ID
 * @param id L'ID du modèle d'email
 */
export async function getEmailTemplateById(id: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/email-templates/${id}`, {
    method: 'GET',
    headers: {
      Authorization: `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
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
 * Supprime un modèle d'email par son ID
 * @param id L'ID du modèle d'email
 */
export async function deleteEmailTemplate(id: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/email-templates/${id}`, {
    method: 'DELETE',
    headers: {
      Authorization: `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
      'Content-Type': 'application/json'
    }
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return { success: true };
}

/**
 * Met à jour les détails d'un modèle d'email
 * @param id L'ID du modèle d'email
 * @param data Les données à mettre à jour
 */
export async function updateEmailTemplateDetails(id: string, data: UpdateEmailTemplateParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/email-templates/${id}`, {
    method: 'PATCH',
    headers: {
      Authorization: `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
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
