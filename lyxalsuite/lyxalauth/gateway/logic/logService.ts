/**
 * Service pour gérer les interactions avec l'API Logto concernant les journaux d'audit
 */

/**
 * Type pour les paramètres de requête de logs
 */
type GetLogsParams = {
  page?: number;
  page_size?: number;
  application_id?: string;
  application_name?: string;
  user_id?: string;
  username?: string;
  event?: string;
  type?: string;
  ip_address?: string;
  range?: [string, string];
};

/**
 * Récupère les journaux d'audit avec possibilité de filtrage
 */
export async function getLogs(params: GetLogsParams = {}) {
  // Construction des paramètres de requête
  const queryParams = new URLSearchParams();
  
  if (params.page !== undefined) queryParams.append('page', params.page.toString());
  if (params.page_size !== undefined) queryParams.append('page_size', params.page_size.toString());
  if (params.application_id) queryParams.append('application_id', params.application_id);
  if (params.application_name) queryParams.append('application_name', params.application_name);
  if (params.user_id) queryParams.append('user_id', params.user_id);
  if (params.username) queryParams.append('username', params.username);
  if (params.event) queryParams.append('event', params.event);
  if (params.type) queryParams.append('type', params.type);
  if (params.ip_address) queryParams.append('ip_address', params.ip_address);
  if (params.range) {
    queryParams.append('range', params.range.join(','));
  }

  const url = `${process.env.LOGTO_URL}/api/logs?${queryParams.toString()}`;

  const response = await fetch(url, {
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
 * Récupère un journal d'audit spécifique par son ID
 */
export async function getLogById(logId: string) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/logs/${logId}`, {
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
