/**
 * Service pour gérer les interactions avec l'API Logto concernant la vérification par mot de passe
 */
import { structuredLogger as logger } from '../core/logger/structuredLogger';

/**
 * Type pour les paramètres de création d'un enregistrement par mot de passe
 */
type CreateVerificationByPasswordParams = {
  username?: string;
  email?: string;
  phone?: string;
  password: string;
};

/**
 * Type pour les paramètres de création d'un enregistrement par code de vérification
 */
type CreateVerificationByCodeParams = {
  username?: string;
  email?: string;
  phone?: string;
  code: string;
  purpose: 'Register' | 'SignIn' | 'ForgotPassword' | 'Generic';
};

/**
 * Type pour les paramètres de vérification d'un code
 */
type VerifyVerificationCodeParams = {
  interactionEvent: string;
  code: string;
};

/**
 * Type pour les paramètres de création d'un enregistrement de vérification sociale
 */
type CreateSocialVerificationParams = {
  connectorId: string;
  state: string;
  redirectUri: string;
  code?: string;
  authCode?: string;
};

/**
 * Type pour les paramètres de vérification d'un enregistrement social
 */
type VerifySocialVerificationParams = {
  interactionEvent: string;
  data: Record<string, any>;
};

/**
 * Crée un enregistrement par mot de passe
 * @param data Données pour la création de l'enregistrement
 */
export async function createVerificationByPassword(data: CreateVerificationByPasswordParams) {
  logger.info('Création d\'un enregistrement par mot de passe', 'verificationByPassword');
  
  try {
    const response = await fetch(`${process.env.LOGTO_URL}/api/verification/by-password`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(data)
    });

    if (!response.ok) {
      const error = await response.json().catch(() => ({}));
      logger.error(`Erreur Logto lors de la création d'un enregistrement par mot de passe: ${error.message || response.statusText}`, 'verificationByPassword');
      throw new Error(`Logto error: ${error.message || response.statusText}`);
    }

    return response.json();
  } catch (error: any) {
    logger.error(`Exception lors de la création d'un enregistrement par mot de passe: ${error.message}`, 'verificationByPassword');
    throw error;
  }
}

/**
 * Crée un enregistrement par code de vérification
 * @param data Données pour la création de l'enregistrement
 */
export async function createVerificationByCode(data: CreateVerificationByCodeParams) {
  logger.info('Création d\'un enregistrement par code de vérification', 'verificationByPassword');
  
  try {
    const response = await fetch(`${process.env.LOGTO_URL}/api/verification/by-code`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(data)
    });

    if (!response.ok) {
      const error = await response.json().catch(() => ({}));
      logger.error(`Erreur Logto lors de la création d'un enregistrement par code: ${error.message || response.statusText}`, 'verificationByPassword');
      throw new Error(`Logto error: ${error.message || response.statusText}`);
    }

    return response.json();
  } catch (error: any) {
    logger.error(`Exception lors de la création d'un enregistrement par code: ${error.message}`, 'verificationByPassword');
    throw error;
  }
}

/**
 * Vérifie un code de vérification pour une interaction
 * @param data Données pour la vérification du code
 */
export async function verifyCode(data: VerifyVerificationCodeParams) {
  logger.info('Vérification d\'un code', 'verificationByPassword');
  
  try {
    const response = await fetch(`${process.env.LOGTO_URL}/api/verification/verify-code`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(data)
    });

    if (!response.ok) {
      const error = await response.json().catch(() => ({}));
      logger.error(`Erreur Logto lors de la vérification d'un code: ${error.message || response.statusText}`, 'verificationByPassword');
      throw new Error(`Logto error: ${error.message || response.statusText}`);
    }

    return response.json();
  } catch (error: any) {
    logger.error(`Exception lors de la vérification d'un code: ${error.message}`, 'verificationByPassword');
    throw error;
  }
}

/**
 * Crée un enregistrement de vérification sociale
 * @param data Données pour la création de l'enregistrement
 */
export async function createSocialVerification(data: CreateSocialVerificationParams) {
  logger.info('Création d\'un enregistrement de vérification sociale', 'verificationByPassword');
  
  try {
    const response = await fetch(`${process.env.LOGTO_URL}/api/verification/social`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(data)
    });

    if (!response.ok) {
      const error = await response.json().catch(() => ({}));
      logger.error(`Erreur Logto lors de la création d'un enregistrement social: ${error.message || response.statusText}`, 'verificationByPassword');
      throw new Error(`Logto error: ${error.message || response.statusText}`);
    }

    return response.json();
  } catch (error: any) {
    logger.error(`Exception lors de la création d'un enregistrement social: ${error.message}`, 'verificationByPassword');
    throw error;
  }
}

/**
 * Vérifie un enregistrement de vérification sociale
 * @param data Données pour la vérification de l'enregistrement
 */
export async function verifySocialVerification(data: VerifySocialVerificationParams) {
  logger.info('Vérification d\'un enregistrement social', 'verificationByPassword');
  
  try {
    const response = await fetch(`${process.env.LOGTO_URL}/api/verification/social/verify`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(data)
    });

    if (!response.ok) {
      const error = await response.json().catch(() => ({}));
      logger.error(`Erreur Logto lors de la vérification d'un enregistrement social: ${error.message || response.statusText}`, 'verificationByPassword');
      throw new Error(`Logto error: ${error.message || response.statusText}`);
    }

    return response.json();
  } catch (error: any) {
    logger.error(`Exception lors de la vérification d'un enregistrement social: ${error.message}`, 'verificationByPassword');
    throw error;
  }
}
