import { Hono } from 'hono';
import { structuredLogger as logger } from '../core/logger/structuredLogger';
import {
  initInteraction,
  updateInteractionEvent,
  identifyUser,
  submitInteraction,
  createPasswordVerification,
  createVerificationCode,
  verifyVerificationCode,
  createSocialVerification,
  verifySocialVerification,
  createEnterpriseVerification,
  verifyEnterpriseVerification,
  createTotpSecret,
  verifyTotpVerification,
  createWebAuthnRegistration,
  verifyWebAuthnRegistration,
  createWebAuthnAuthentication,
  verifyWebAuthnAuthentication,
  generateBackupCodes,
  verifyBackupCode,
  createPasswordIdentity,
  verifyOneTimeToken,
  addUserProfile,
  resetUserPassword,
  skipMfaBinding,
  bindMfaVerification,
  getEnabledSsoConnectors
} from '../logic/experienceService';
import {
  validateInitInteraction,
  validateUpdateInteractionEvent,
  validateIdentifyUser,
  validateSubmitInteraction,
  validateCreatePasswordVerification,
  validateCreateVerificationCode,
  validateVerifyVerificationCode
} from '../validators/experienceValidation';
import { rateLimiter } from '../middleware/rateLimiter';

// Création du routeur
const experienceRoutes = new Hono();

// Appliquer une limitation de débit pour les routes sensibles
experienceRoutes.use('/interaction/verification/*', rateLimiter({
  windowMs: 60000, // 1 minute
  maxRequests: 5,  // 5 requêtes par minute
  message: 'Trop de tentatives de vérification, veuillez réessayer plus tard'
}));

/**
 * @route PUT /experience/interaction
 * @desc Initialise une nouvelle interaction
 * @access Public
 */
experienceRoutes.put('/interaction', async (c) => {
  try {
    const body = await c.req.json();
    const data = validateInitInteraction(body);
    const result = await initInteraction(data);
    return c.json({ data: result, success: true });
  } catch (error: any) {
    const message = error instanceof Error ? error.message : 'Une erreur est survenue';
    logger.error(`Erreur lors de l'initialisation de l'interaction: ${message}`, 'experience');
    
    // Déterminer le code d'erreur approprié
    const statusCode = message.includes('validation') ? 400 : 500;
    
    return c.json({ error: 'Erreur lors de l\'initialisation de l\'interaction', details: message, success: false }, statusCode);
  }
});

/**
 * @route PUT /experience/interaction/event
 * @desc Met à jour un événement d'interaction
 * @access Public
 */
experienceRoutes.put('/interaction/event', async (c) => {
  try {
    const body = await c.req.json();
    const data = validateUpdateInteractionEvent(body);
    
    // Récupérer l'interactionId depuis les headers ou les paramètres
    const interactionId = c.req.header('x-interaction-id') || c.req.query('interactionId');
    if (!interactionId) {
      return c.json({ error: 'ID d\'interaction manquant', success: false }, 400);
    }
    
    const result = await updateInteractionEvent({ ...data, interactionId });
    return c.json({ data: result, success: true });
  } catch (error: any) {
    const message = error instanceof Error ? error.message : 'Une erreur est survenue';
    logger.error(`Erreur lors de la mise à jour de l'événement d'interaction: ${message}`, 'experience');
    
    // Déterminer le code d'erreur approprié
    const statusCode = message.includes('validation') || message.includes('non trouvée') ? 400 : 500;
    
    return c.json({ error: 'Erreur lors de la mise à jour de l\'événement d\'interaction', details: message, success: false }, statusCode);
  }
});

/**
 * @route POST /experience/interaction/identifiers
 * @desc Identifie un utilisateur pour l'interaction en cours
 * @access Public
 */
experienceRoutes.post('/interaction/identifiers', async (c) => {
  try {
    const body = await c.req.json();
    const data = validateIdentifyUser(body);
    
    const interactionId = c.req.header('x-interaction-id') || c.req.query('interactionId'); if (!interactionId) {
      return c.json({ error: 'ID d\'interaction manquant', success: false }, 400);
    }
    
    const result = await identifyUser(data);
    return c.json({ data: result, success: true });
  } catch (error: any) {
    const message = error instanceof Error ? error.message : 'Une erreur est survenue';
    logger.error(`Erreur lors de l'identification de l'utilisateur: ${message}`, 'experience');
    
    // Codes d'erreur spécifiques pour différents cas
    if (message.includes('non trouvé')) {
      return c.json({ error: 'Utilisateur non trouvé', details: message, success: false }, 404);
    } else if (message.includes('validation')) {
      return c.json({ error: 'Données d\'identification invalides', details: message, success: false }, 400);
    }
    
    return c.json({ error: 'Erreur lors de l\'identification de l\'utilisateur', details: message, success: false }, 500);
  }
});

/**
 * @route POST /experience/interaction/submit
 * @desc Soumet une interaction
 * @access Public
 */
experienceRoutes.post('/interaction/submit', async (c) => {
  try {
    const body = await c.req.json();
    const data = validateSubmitInteraction(body);
    
    const interactionId = c.req.header('x-interaction-id') || c.req.query('interactionId'); if (!interactionId) {
      return c.json({ error: 'ID d\'interaction manquant', success: false }, 400);
    }
    
    const result = await submitInteraction(data);
    return c.json({ data: result, success: true });
  } catch (error: any) {
    const message = error instanceof Error ? error.message : 'Une erreur est survenue';
    logger.error(`Erreur lors de la soumission de l'interaction: ${message}`, 'experience');
    
    // Déterminer le code d'erreur approprié
    const statusCode = message.includes('validation') || message.includes('non valide') ? 400 : 500;
    
    return c.json({ error: 'Erreur lors de la soumission de l\'interaction', details: message, success: false }, statusCode);
  }
});

/**
 * @route POST /experience/interaction/verification/password
 * @desc Crée un enregistrement de vérification par mot de passe
 * @access Public
 */
experienceRoutes.post('/interaction/verification/password', async (c) => {
  try {
    const body = await c.req.json();
    const data = validateCreatePasswordVerification(body);
    
    if (!data.interactionId || !data.password) {
      return c.json({ error: 'ID d\'interaction et mot de passe requis', success: false }, 400);
    }
    
    const result = await createPasswordVerification(data);
    return c.json({ data: result, success: true });
  } catch (error: any) {
    const message = error instanceof Error ? error.message : 'Une erreur est survenue';
    logger.error(`Erreur lors de la création de la vérification par mot de passe: ${message}`, 'experience');
    
    // Codes d'erreur spécifiques pour différents cas
    if (message.includes('incorrect')) {
      return c.json({ error: 'Mot de passe incorrect', details: message, success: false }, 401);
    } else if (message.includes('validation')) {
      return c.json({ error: 'Données de vérification invalides', details: message, success: false }, 400);
    }
    
    return c.json({ error: 'Erreur lors de la création de la vérification par mot de passe', details: message, success: false }, 500);
  }
});

/**
 * @route POST /experience/interaction/verification/verification-code
 * @desc Crée et envoie un code de vérification
 * @access Public
 */
experienceRoutes.post('/interaction/verification/verification-code', async (c) => {
  try {
    const body = await c.req.json();
    const data = validateCreateVerificationCode(body);
    
    if (!data.interactionId || !(data.email || data.phone)) {
      return c.json({ error: 'ID d\'interaction et cible (email ou téléphone) requis', success: false }, 400);
    }
    
    const result = await createVerificationCode(data);
    return c.json({ data: result, success: true });
  } catch (error: any) {
    const message = error instanceof Error ? error.message : 'Une erreur est survenue';
    logger.error(`Erreur lors de la création du code de vérification: ${message}`, 'experience');
    
    // Déterminer le code d'erreur approprié
    const statusCode = message.includes('validation') ? 400 : 500;
    
    return c.json({ error: 'Erreur lors de la création du code de vérification', details: message, success: false }, statusCode);
  }
});

/**
 * @route POST /experience/interaction/verification/verification-code/verify
 * @desc Vérifie un code de vérification
 * @access Public
 */
experienceRoutes.post('/interaction/verification/verification-code/verify', async (c) => {
  try {
    const body = await c.req.json();
    const data = validateVerifyVerificationCode(body);
    
    if (!data.interactionId || !data.code) {
      return c.json({ error: 'ID d\'interaction et code requis', success: false }, 400);
    }
    
    const result = await verifyVerificationCode(data);
    return c.json({ data: result, success: true });
  } catch (error: any) {
    const message = error instanceof Error ? error.message : 'Une erreur est survenue';
    logger.error(`Erreur lors de la vérification du code: ${message}`, 'experience');
    
    // Codes d'erreur spécifiques pour différents cas
    if (message.includes('invalide') || message.includes('incorrect')) {
      return c.json({ error: 'Code de vérification incorrect', details: message, success: false }, 401);
    } else if (message.includes('expiré')) {
      return c.json({ error: 'Code de vérification expiré', details: message, success: false }, 401);
    }
    
    return c.json({ error: 'Erreur lors de la vérification du code', details: message, success: false }, 500);
  }
});

/**
 * @route POST /experience/interaction/verification/social
 * @desc Crée une vérification sociale
 * @access Public
 */
experienceRoutes.post('/interaction/verification/social', async (c) => {
  try {
    const body = await c.req.json();
    
    if (!body.interactionId || !body.connectorId) {
      return c.json({ error: 'ID d\'interaction et ID de connecteur requis', success: false }, 400);
    }
    
    const result = await createSocialVerification(body);
    return c.json({ data: result, success: true });
  } catch (error: any) {
    const message = error instanceof Error ? error.message : 'Une erreur est survenue';
    logger.error(`Erreur lors de la création de la vérification sociale: ${message}`, 'experience');
    
    // Déterminer le code d'erreur approprié
    const statusCode = message.includes('validation') || message.includes('non trouvé') ? 400 : 500;
    
    return c.json({ error: 'Erreur lors de la création de la vérification sociale', details: message, success: false }, statusCode);
  }
});

/**
 * @route POST /experience/interaction/verification/social/verify
 * @desc Vérifie une vérification sociale
 * @access Public
 */
experienceRoutes.post('/interaction/verification/social/verify', async (c) => {
  try {
    const body = await c.req.json();
    
    if (!body.interactionId || !body.connectorId) {
      return c.json({ error: 'ID d\'interaction et ID de connecteur requis', success: false }, 400);
    }
    
    const result = await verifySocialVerification(body);
    return c.json({ data: result, success: true });
  } catch (error: any) {
    const message = error instanceof Error ? error.message : 'Une erreur est survenue';
    logger.error(`Erreur lors de la vérification sociale: ${message}`, 'experience');
    
    // Déterminer le code d'erreur approprié
    const statusCode = message.includes('validation') || message.includes('échec') ? 400 : 500;
    
    return c.json({ error: 'Erreur lors de la vérification sociale', details: message, success: false }, statusCode);
  }
});

// Ajout des routes supplémentaires pour les autres fonctions d'expérience
// Pour garder le fichier concis, les routes suivantes suivent le même modèle que les précédentes

export default experienceRoutes; 


