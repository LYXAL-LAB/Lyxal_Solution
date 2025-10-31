/**
 * Service pour gérer les interactions avec l'API Logto concernant les statistiques du tableau de bord
 */

/**
 * Type pour les paramètres de récupération des statistiques d'utilisateurs actifs
 */
type GetActiveUserParams = {
  startTimeExclusive?: number;
  endTimeInclusive?: number;
};

/**
 * Récupère le nombre total d'utilisateurs
 */
export async function getTotalUserCount() {
  const response = await fetch(`${process.env.LOGTO_URL}/api/dashboard/users/total`, {
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
 * Récupère le nombre de nouveaux utilisateurs
 * @param startTimeExclusive Timestamp de début exclusif (optionnel)
 * @param endTimeInclusive Timestamp de fin inclusif (optionnel)
 */
export async function getNewUserCount(startTimeExclusive?: number, endTimeInclusive?: number) {
  const url = new URL(`${process.env.LOGTO_URL}/api/dashboard/users/new`);
  
  if (startTimeExclusive) {
    url.searchParams.append('startTimeExclusive', startTimeExclusive.toString());
  }
  
  if (endTimeInclusive) {
    url.searchParams.append('endTimeInclusive', endTimeInclusive.toString());
  }

  const response = await fetch(url.toString(), {
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
 * Récupère les données d'utilisateurs actifs
 * @param params Paramètres pour la requête (startTimeExclusive, endTimeInclusive)
 */
export async function getActiveUserData(params?: GetActiveUserParams) {
  const url = new URL(`${process.env.LOGTO_URL}/api/dashboard/users/active`);
  
  if (params?.startTimeExclusive) {
    url.searchParams.append('startTimeExclusive', params.startTimeExclusive.toString());
  }
  
  if (params?.endTimeInclusive) {
    url.searchParams.append('endTimeInclusive', params.endTimeInclusive.toString());
  }

  const response = await fetch(url.toString(), {
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
