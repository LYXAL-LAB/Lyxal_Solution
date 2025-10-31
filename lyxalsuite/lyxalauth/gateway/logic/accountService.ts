/**
 * Service pour gérer les interactions avec l'API Logto concernant le centre de compte
 */

/**
 * Type pour les paramètres de mise à jour du centre de compte
 */
type UpdateAccountCenterSettingsParams = {
  uriTemplate?: string;
  privateUriTemplate?: string;
  branding?: {
    logoUrl?: string;
    darkLogoUrl?: string;
    favicon?: string;
    darkFavicon?: string;
    appName?: Record<string, string>;
    appNameAlt?: Record<string, string>;
    themeOverride?: Record<string, unknown>;
  };
  customCss?: string;
  customCssEnabled?: boolean;
  languageInfo?: {
    autoDetect?: boolean;
    fallbackLanguage?: string;
  };
  termsEnabled?: boolean;
  termsUrl?: Record<string, string>;
  privacyEnabled?: boolean;
  privacyUrl?: Record<string, string>;
};

/**
 * Récupère les paramètres du centre de compte
 */
export async function getAccountCenterSettings() {
  const response = await fetch(`${process.env.LOGTO_URL}/api/account-center/settings`, {
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
 * Met à jour les paramètres du centre de compte
 */
export async function updateAccountCenterSettings(data: UpdateAccountCenterSettingsParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/account-center/settings`, {
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
