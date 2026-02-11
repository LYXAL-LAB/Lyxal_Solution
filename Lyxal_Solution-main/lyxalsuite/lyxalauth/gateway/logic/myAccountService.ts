/**
 * Service pour gérer les interactions avec l'API Logto concernant les comptes utilisateurs
 */

// Types pour les différentes opérations de compte utilisateur

/**
 * Type pour la mise à jour du profil
 */
type UpdateProfileParams = {
  name?: string;
  avatar?: string;
  customData?: Record<string, unknown>;
};

/**
 * Type pour la mise à jour d'un autre profil
 */
type UpdateOtherProfileParams = UpdateProfileParams;

/**
 * Type pour la mise à jour du mot de passe
 */
type UpdatePasswordParams = {
  oldPassword: string;
  newPassword: string;
};

/**
 * Type pour la mise à jour de l'email primaire
 */
type UpdatePrimaryEmailParams = {
  email: string;
  verificationCode: string;
};

/**
 * Type pour la mise à jour du téléphone primaire
 */
type UpdatePrimaryPhoneParams = {
  phone: string;
  verificationCode: string;
};

/**
 * Type pour l'ajout d'une identité utilisateur
 */
type AddUserIdentityParams = {
  target: string;
  connectorId: string;
};

/**
 * Type pour la suppression d'une identité utilisateur
 */
type DeleteUserIdentityParams = {
  target: string;
  connectorId: string;
};

/**
 * Récupère le profil de l'utilisateur connecté
 */
export async function getProfile() {
  const response = await fetch(`${process.env.LOGTO_URL}/api/me`, {
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
 * Met à jour le profil de l'utilisateur connecté
 */
export async function updateProfile(data: UpdateProfileParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/me`, {
    method: 'PATCH',
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

/**
 * Met à jour le profil d'un autre utilisateur
 */
export async function updateOtherProfile(data: UpdateOtherProfileParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/me/others`, {
    method: 'PATCH',
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

/**
 * Met à jour le mot de passe de l'utilisateur connecté
 */
export async function updatePassword(data: UpdatePasswordParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/me/password`, {
    method: 'POST',
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

/**
 * Met à jour l'email primaire de l'utilisateur connecté
 */
export async function updatePrimaryEmail(data: UpdatePrimaryEmailParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/me/email`, {
    method: 'POST',
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

/**
 * Supprime l'email primaire de l'utilisateur connecté
 */
export async function deletePrimaryEmail() {
  const response = await fetch(`${process.env.LOGTO_URL}/api/me/email`, {
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
 * Met à jour le téléphone primaire de l'utilisateur connecté
 */
export async function updatePrimaryPhone(data: UpdatePrimaryPhoneParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/me/phone`, {
    method: 'POST',
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

/**
 * Supprime le téléphone primaire de l'utilisateur connecté
 */
export async function deletePrimaryPhone() {
  const response = await fetch(`${process.env.LOGTO_URL}/api/me/phone`, {
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
 * Ajoute une identité utilisateur
 */
export async function addUserIdentity(data: AddUserIdentityParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/me/identities`, {
    method: 'POST',
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

/**
 * Supprime une identité utilisateur
 */
export async function deleteUserIdentity(data: DeleteUserIdentityParams) {
  const url = new URL(`${process.env.LOGTO_URL}/api/me/identities`);
  url.searchParams.append('target', data.target);
  url.searchParams.append('connectorId', data.connectorId);

  const response = await fetch(url.toString(), {
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
