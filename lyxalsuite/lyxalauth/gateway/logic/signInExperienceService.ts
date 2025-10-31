/**
 * Service pour gérer les interactions avec l'API Logto concernant l'expérience de connexion
 */

/**
 * Type pour mettre à jour l'expérience de connexion par défaut
 */
type UpdateSignInExperienceParams = {
  branding?: {
    logoUrl?: string;
    darkLogoUrl?: string;
    favicon?: string;
    darkFavicon?: string;
    appName?: Record<string, string>;
    appNameAlt?: Record<string, string>;
    themeOverride?: Record<string, any>;
  };
  color?: {
    primaryColor?: string;
    isDarkModeEnabled?: boolean;
    darkPrimaryColor?: string;
  };
  customCSS?: string;
  customCSSEnabled?: boolean;
  languageInfo?: {
    autoDetect?: boolean;
    fallbackLanguage?: string;
  };
  termsEnabled?: boolean;
  termsUrl?: Record<string, string>;
  privacyEnabled?: boolean;
  privacyUrl?: Record<string, string>;
  signIn?: {
    methods?: Array<{
      identifier: 'username' | 'email' | 'phone';
      password: boolean;
      verificationCode: boolean;
      isPasswordPrimary: boolean;
    }>;
  };
  signUp?: {
    identifiers?: Array<'username' | 'email' | 'phone'>;
    password?: boolean;
    verify?: boolean;
    secondaryIdentifiers?: Array<{
      identifier: 'username' | 'email' | 'phone' | 'emailOrPhone';
      verify?: boolean;
    }>;
  };
  mfa?: {
    factors?: Array<'Totp' | 'WebAuthn' | 'BackupCode'>;
    policy?: 'UserControlled' | 'Mandatory' | 'PromptOnlyAtSignIn' | 'PromptAtSignInAndSignUp' | 'NoPrompt';
    organizationRequiredMfaPolicy?: 'NoPrompt' | 'Mandatory';
  };
  passwordPolicy?: {
    length?: {
      min?: number;
      max?: number;
    };
    characterTypes?: {
      min?: number;
    };
    rejects?: {
      pwned?: boolean;
      repetitionAndSequence?: boolean;
      userInfo?: boolean;
      words?: string[];
    };
  };
};

/**
 * Type pour la vérification de politique de mot de passe
 */
type CheckPasswordPolicyParams = {
  password: string;
  username?: string;
  name?: string;
  email?: string;
};

/**
 * Récupère les paramètres d'expérience de connexion par défaut
 */
export async function getDefaultSignInExperience() {
  const response = await fetch(`${process.env.LOGTO_URL}/api/sign-in-exp`, {
    method: 'GET',
    headers: {
      'Authorization': `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
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
 * Met à jour les paramètres d'expérience de connexion par défaut
 */
export async function updateDefaultSignInExperience(data: UpdateSignInExperienceParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/sign-in-exp`, {
    method: 'PATCH',
    headers: {
      'Authorization': `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
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

/**
 * Vérifie si un mot de passe respecte la politique de mot de passe
 */
export async function checkPasswordPolicy(data: CheckPasswordPolicyParams) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/sign-in-exp/password-policy`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
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

/**
 * Télécharge des assets UI personnalisés
 */
export async function uploadCustomUIAssets(formData: FormData) {
  const response = await fetch(`${process.env.LOGTO_URL}/api/sign-in-exp/custom-ui-assets`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`
    },
    body: formData
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(`Logto error: ${error.message || response.statusText}`);
  }

  return response.json();
} 
