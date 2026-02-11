/**
 * Service pour gérer les interactions avec l'API Logto concernant les codes de vérification
 */
import { structuredLogger as logger } from '../core/logger/structuredLogger';

/**
 * Type pour les paramètres de demande de code de vérification
 */
type RequestVerificationCodeParams = {
  email?: string;
  phone?: string;
  connectorId?: string;
  purpose: 'Register' | 'SignIn' | 'ForgotPassword' | 'Generic';
};

/**
 * Type pour les paramètres de vérification de code
 */
type VerifyVerificationCodeParams = {
  email?: string;
  phone?: string;
  code: string;
  purpose: 'Register' | 'SignIn' | 'ForgotPassword' | 'Generic';
};

/**
 * Demande et envoie un code de vérification
 * @param data Données pour la demande de code
 */
export async function requestVerificationCode(data: RequestVerificationCodeParams) {
  logger.info('Demande d\'un code de vérification', 'verificationCode');
  
  try {
    const response = await fetch(`${process.env.LOGTO_URL}/api/verification-code`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(data)
    });

    if (!response.ok) {
      const error = await response.json().catch(() => ({}));
      logger.error(`Erreur Logto lors de la demande d'un code de vérification: ${error.message || response.statusText}`, 'verificationCode');
      throw new Error(`Logto error: ${error.message || response.statusText}`);
    }

    logger.info('Code de vérification demandé avec succès', 'verificationCode');
    return response.json();
  } catch (error: any) {
    logger.error(`Exception lors de la demande d'un code de vérification: ${error.message}`, 'verificationCode');
    throw error;
  }
}

/**
 * Vérifie un code de vérification
 * @param data Données pour la vérification du code
 */
export async function verifyVerificationCode(data: VerifyVerificationCodeParams) {
  logger.info('Vérification d\'un code', 'verificationCode');
  
  try {
    const response = await fetch(`${process.env.LOGTO_URL}/api/verification-code/verify`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${process.env.LOGTO_ADMIN_TOKEN}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(data)
    });

    if (!response.ok) {
      const error = await response.json().catch(() => ({}));
      logger.error(`Erreur Logto lors de la vérification d'un code: ${error.message || response.statusText}`, 'verificationCode');
      throw new Error(`Logto error: ${error.message || response.statusText}`);
    }

    logger.info('Code vérifié avec succès', 'verificationCode');
    return response.json();
  } catch (error: any) {
    logger.error(`Exception lors de la vérification d'un code: ${error.message}`, 'verificationCode');
    throw error;
  }
}
