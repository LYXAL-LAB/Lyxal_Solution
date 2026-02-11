/**
 * Service pour gérer les interactions avec l'API Logto concernant les assets
 */

/**
 * Récupère le statut du service d'assets
 */
export async function getAssetServiceStatus() {
  const response = await fetch(`${process.env.LOGTO_URL}/api/assets/service-status`, {
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
 * Télécharge un asset vers Logto
 * @param file Fichier à télécharger (FormData)
 */
export async function uploadAsset(formData: FormData) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/assets`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`
      // Ne pas définir Content-Type ici, il sera automatiquement défini par fetch avec le boundary correct
    },
    body: formData
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
} 
