/**
 * Service pour gérer les interactions avec l'API Logto concernant les invitations aux organisations
 */

// Types pour les différentes opérations d'invitations

/**
 * Type pour la création d'une invitation à une organisation
 */
type CreateOrganizationInvitationParams = {
  organizationId: string;
  invitee: string;
  expiresInSeconds?: number;
  role?: string;
};

/**
 * Type pour la mise à jour du statut d'une invitation
 */
type UpdateOrganizationInvitationStatusParams = {
  status: 'accepted' | 'declined';
};

/**
 * Récupère toutes les invitations d'une organisation
 * @param organizationId ID de l'organisation
 * @param page Page à récupérer (par défaut: 1)
 * @param pageSize Nombre d'éléments par page (par défaut: 20)
 */
export async function getOrganizationInvitations(organizationId: string, page: number = 1, pageSize: number = 20) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}/invitations?page=${page}&page_size=${pageSize}`, {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${process.env.LOGTO_TOKEN}`
    }
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
}

/**
 * Récupère une invitation à une organisation par son ID
 */
export async function getOrganizationInvitation(organizationId: string, invitationId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}/invitations/${invitationId}`, {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${process.env.LOGTO_TOKEN}`
    }
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
}

/**
 * Crée une nouvelle invitation à une organisation
 */
export async function createOrganizationInvitation(data: CreateOrganizationInvitationParams) {
  const { organizationId, ...invitationData } = data;
  
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}/invitations`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${process.env.LOGTO_TOKEN}`
    },
    body: JSON.stringify(invitationData)
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
}

/**
 * Supprime une invitation à une organisation
 */
export async function deleteOrganizationInvitation(organizationId: string, invitationId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}/invitations/${invitationId}`, {
    method: 'DELETE',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${process.env.LOGTO_TOKEN}`
    }
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
}

/**
 * Renvoie le message d'invitation
 */
export async function resendOrganizationInvitation(organizationId: string, invitationId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}/invitations/${invitationId}/resend`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${process.env.LOGTO_TOKEN}`
    }
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
}

/**
 * Met à jour le statut d'une invitation à une organisation
 */
export async function updateOrganizationInvitationStatus(
  organizationId: string,
  invitationId: string,
  data: UpdateOrganizationInvitationStatusParams
) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/organizations/${organizationId}/invitations/${invitationId}/status`, {
    method: 'PUT',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${process.env.LOGTO_TOKEN}`
    },
    body: JSON.stringify(data)
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
} 
