import { Hono } from 'hono';
import { structuredLogger as logger } from '../core/logger/structuredLogger';
import * as interactionService from '../logic/interactionService';
import * as experienceService from '../logic/experienceService';
import { validateZod } from '../validators/validateZod';
import {
  updateIdentifiersSchema,
  updateProfileSchema,
  patchProfileSchema,
  consentSchema,
  socialAuthorizationUriSchema,
  updateMfaSchema,
  singleSignOnAuthorizationUrlSchema,
  singleSignOnAuthenticationSchema,
  singleSignOnRegistrationSchema
} from '../validators/schemas/interactionSchemas';
import { rateLimiter } from '../middleware/rateLimiter';
import { cacheControl } from '../middleware/cacheControlMiddleware';

const router = new Hono();

// Limitation de débit pour protéger contre les abus
router.use('/mfa', rateLimiter({ 
  windowMs: 60000, // 1 minute
  maxRequests: 5,
  message: 'Trop de tentatives, veuillez réessayer plus tard'
}));
router.use('/single-sign-on/*', rateLimiter({ 
  windowMs: 60000, // 1 minute
  maxRequests: 5,
  message: 'Trop de tentatives, veuillez réessayer plus tard'
}));

// Empêcher le cache des données sensibles
router.use('*', cacheControl({ noStore: true, noCache: true }));

/**
 * DELETE /interaction
 * Supprime une interaction en cours
 */
router.delete('/', async (c) => {
  try {
    logger.info('Suppression de l\'interaction en cours', 'interaction');
    const result = await interactionService.deleteInteraction();
    return c.json({ success: true, message: 'Interaction supprimée avec succès' });
  } catch (error: any) {
    logger.error(`Erreur lors de la suppression de l'interaction: ${error.message}`, 'interaction');
    return c.json({ error: 'Erreur lors de la suppression de l\'interaction', details: error.message, success: false }, 500);
  }
});

/**
 * PATCH /interaction/identifiers
 * Met à jour les identifiants de l'interaction en cours
 */
router.patch('/identifiers', validateZod({ body: updateIdentifiersSchema }), async (c) => {
  try {
    logger.info('Mise à jour des identifiants de l\'interaction', 'interaction');
    
    // Les données sont déjà validées par le middleware validateZod
    const data = c.get('validatedBody');
    const result = await interactionService.updateIdentifiers(data);
    
    return c.json({ data: result, success: true });
  } catch (error: any) {
    logger.error(`Erreur lors de la mise à jour des identifiants: ${error.message}`, 'interaction');
    return c.json({ error: 'Erreur lors de la mise à jour des identifiants', details: error.message, success: false }, 500);
  }
});

/**
 * PUT /interaction/profile
 * Met à jour le profil de l'interaction en cours
 */
router.put('/profile', validateZod({ body: updateProfileSchema }), async (c) => {
  try {
    logger.info('Mise à jour du profil de l\'interaction', 'interaction');
    
    // Les données sont déjà validées par le middleware validateZod
    const data = c.get('validatedBody');
    const result = await interactionService.updateProfile(data);
    
    return c.json({ data: result, success: true });
  } catch (error: any) {
    logger.error(`Erreur lors de la mise à jour du profil: ${error.message}`, 'interaction');
    return c.json({ error: 'Erreur lors de la mise à jour du profil', details: error.message, success: false }, 500);
  }
});

/**
 * DELETE /interaction/profile
 * Supprime le profil de l'interaction en cours
 */
router.delete('/profile', async (c) => {
  try {
    logger.info('Suppression du profil de l\'interaction', 'interaction');
    const result = await interactionService.deleteProfile();
    return c.json({ success: true, message: 'Profil supprimé avec succès' });
  } catch (error: any) {
    logger.error(`Erreur lors de la suppression du profil: ${error.message}`, 'interaction');
    return c.json({ error: 'Erreur lors de la suppression du profil', details: error.message, success: false }, 500);
  }
});

/**
 * PATCH /interaction/profile
 * Met à jour partiellement le profil de l'interaction en cours
 */
router.patch('/profile', validateZod({ body: patchProfileSchema }), async (c) => {
  try {
    logger.info('Mise à jour partielle du profil de l\'interaction', 'interaction');
    
    // Les données sont déjà validées par le middleware validateZod
    const data = c.get('validatedBody');
    const result = await interactionService.patchProfile(data);
    
    return c.json({ data: result, success: true });
  } catch (error: any) {
    logger.error(`Erreur lors de la mise à jour partielle du profil: ${error.message}`, 'interaction');
    return c.json({ error: 'Erreur lors de la mise à jour partielle du profil', details: error.message, success: false }, 500);
  }
});

/**
 * GET /interaction/consent
 * Récupère les informations de consentement de l'interaction en cours
 */
router.get('/consent', async (c) => {
  try {
    logger.info('Récupération des informations de consentement', 'interaction');
    const result = await interactionService.getConsent();
    return c.json({ data: result, success: true });
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération du consentement: ${error.message}`, 'interaction');
    return c.json({ error: 'Erreur lors de la récupération du consentement', details: error.message, success: false }, 500);
  }
});

/**
 * POST /interaction/consent
 * Soumet le consentement pour l'interaction en cours
 */
router.post('/consent', validateZod({ body: consentSchema }), async (c) => {
  try {
    logger.info('Soumission du consentement', 'interaction');
    
    // Les données sont déjà validées par le middleware validateZod
    const data = c.get('validatedBody');
    const result = await interactionService.submitConsent(data);
    
    return c.json({ data: result, success: true });
  } catch (error: any) {
    logger.error(`Erreur lors de la soumission du consentement: ${error.message}`, 'interaction');
    return c.json({ error: 'Erreur lors de la soumission du consentement', details: error.message, success: false }, 500);
  }
});

/**
 * POST /interaction/social-authorization-uri
 * Génère une URI d'autorisation sociale
 */
router.post('/social-authorization-uri', validateZod({ body: socialAuthorizationUriSchema }), async (c) => {
  try {
    logger.info('Génération d\'une URI d\'autorisation sociale', 'interaction');
    
    // Les données sont déjà validées par le middleware validateZod
    const data = c.get('validatedBody');
    const result = await interactionService.createSocialAuthorizationUri(data);
    
    return c.json({ data: result, success: true });
  } catch (error: any) {
    logger.error(`Erreur lors de la génération de l'URI d'autorisation sociale: ${error.message}`, 'interaction');
    return c.json({ error: 'Erreur lors de la génération de l\'URI d\'autorisation sociale', details: error.message, success: false }, 500);
  }
});

/**
 * PUT /interaction/mfa
 * Met à jour la configuration MFA
 */
router.put('/mfa', validateZod({ body: updateMfaSchema }), async (c) => {
  try {
    logger.info('Mise à jour de la configuration MFA', 'interaction');
    
    // Les données sont déjà validées par le middleware validateZod
    const data = c.get('validatedBody');
    const result = await interactionService.updateMfa(data);
    
    return c.json({ data: result, success: true });
  } catch (error: any) {
    logger.error(`Erreur lors de la mise à jour de la configuration MFA: ${error.message}`, 'interaction');
    return c.json({ error: 'Erreur lors de la mise à jour de la configuration MFA', details: error.message, success: false }, 500);
  }
});

/**
 * POST /interaction/single-sign-on/authorization-url
 * Génère une URL d'autorisation SSO
 */
router.post('/single-sign-on/authorization-url', validateZod({ body: singleSignOnAuthorizationUrlSchema }), async (c) => {
  try {
    logger.info('Génération d\'une URL d\'autorisation SSO', 'interaction');
    
    // Les données sont déjà validées par le middleware validateZod
    const data = c.get('validatedBody');
    // Récupérer connectorId depuis l'URL ou le corps de la requête, à adapter selon votre conception
    const connectorId = c.req.query('connectorId') || 'default';
    
    const result = await interactionService.getSingleSignOnAuthorizationUrl(connectorId, data);
    
    return c.json({ data: result, success: true });
  } catch (error: any) {
    logger.error(`Erreur lors de la génération de l'URL d'autorisation SSO: ${error.message}`, 'interaction');
    return c.json({ error: 'Erreur lors de la génération de l\'URL d\'autorisation SSO', details: error.message, success: false }, 500);
  }
});

/**
 * POST /interaction/single-sign-on/authentication
 * Authentifie un utilisateur via SSO
 */
router.post('/single-sign-on/authentication', validateZod({ body: singleSignOnAuthenticationSchema }), async (c) => {
  try {
    logger.info('Authentification d\'un utilisateur via SSO', 'interaction');
    
    // Les données sont déjà validées par le middleware validateZod
    const data = c.get('validatedBody');
    // Récupérer connectorId depuis l'URL ou le corps de la requête, à adapter selon votre conception
    const connectorId = c.req.query('connectorId') || 'default';
    
    const result = await interactionService.authenticateSingleSignOn(connectorId, data);
    
    return c.json({ data: result, success: true });
  } catch (error: any) {
    logger.error(`Erreur lors de l'authentification SSO: ${error.message}`, 'interaction');
    return c.json({ error: 'Erreur lors de l\'authentification SSO', details: error.message, success: false }, 500);
  }
});

/**
 * POST /interaction/single-sign-on/registration
 * Enregistre un nouvel utilisateur via SSO
 */
router.post('/single-sign-on/registration', validateZod({ body: singleSignOnRegistrationSchema }), async (c) => {
  try {
    logger.info('Enregistrement d\'un nouvel utilisateur via SSO', 'interaction');
    
    // Les données sont déjà validées par le middleware validateZod
    const data = c.get('validatedBody');
    // Récupérer connectorId depuis l'URL ou le corps de la requête, à adapter selon votre conception
    const connectorId = c.req.query('connectorId') || 'default';
    
    const result = await interactionService.registerSingleSignOn(connectorId, data);
    
    return c.json({ data: result, success: true });
  } catch (error: any) {
    logger.error(`Erreur lors de l'enregistrement SSO: ${error.message}`, 'interaction');
    return c.json({ error: 'Erreur lors de l\'enregistrement SSO', details: error.message, success: false }, 500);
  }
});

export default router; 
