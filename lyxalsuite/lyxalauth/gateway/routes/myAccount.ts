import { Hono } from 'hono';
import { structuredLogger as logger } from '../core/logger/structuredLogger';
import * as myAccountService from '../logic/myAccountService';
import { validateZod } from '../validators/validateZod';
import {
  updateProfileSchema,
  updateOtherProfileSchema,
  updatePasswordSchema,
  updatePrimaryEmailSchema,
  updatePrimaryPhoneSchema,
  addUserIdentitySchema,
  deleteUserIdentitySchema
} from '../validators/schemas/myAccountSchemas';
import { authRequired } from '../middleware/authMiddleware';
import { rateLimiter } from '../middleware/rateLimiter';
import { cacheControl } from '../middleware/cacheControlMiddleware';

const router = new Hono();

// Middleware d'authentification pour toutes les routes
router.use('*', authRequired);

// Appliquer le contrôle de cache pour les données sensibles
router.use('*', cacheControl({ noStore: true, noCache: true }));

// Limiter les tentatives de modification sensibles (mot de passe, email, téléphone)
router.use('/password', rateLimiter({ 
  windowMs: 900000, // 15 minutes en millisecondes
  maxRequests: 5,
  message: 'Trop de tentatives de modification de mot de passe, veuillez réessayer plus tard'
}));
router.use('/email', rateLimiter({ 
  windowMs: 900000, // 15 minutes en millisecondes
  maxRequests: 5,
  message: 'Trop de tentatives de modification d\'email, veuillez réessayer plus tard'
}));
router.use('/phone', rateLimiter({ 
  windowMs: 900000, // 15 minutes en millisecondes
  maxRequests: 5,
  message: 'Trop de tentatives de modification de téléphone, veuillez réessayer plus tard'
}));

/**
 * GET /me
 * Récupère le profil de l'utilisateur connecté
 */
router.get('/', async (c) => {
  try {
    logger.info('Récupération du profil utilisateur', 'myAccount');
    const result = await myAccountService.getProfile();
    return c.json({ data: result, success: true });
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération du profil: ${error.message}`, 'myAccount');
    return c.json({ error: 'Erreur lors de la récupération du profil', details: error.message, success: false }, 500);
  }
});

/**
 * PATCH /me
 * Met à jour le profil de l'utilisateur connecté
 */
router.patch('/', validateZod({ body: updateProfileSchema }), async (c) => {
  try {
    logger.info('Mise à jour du profil utilisateur', 'myAccount');
    const data = c.get('validatedBody');
    const result = await myAccountService.updateProfile(data);
    return c.json({ data: result, success: true });
  } catch (error: any) {
    logger.error(`Erreur lors de la mise à jour du profil: ${error.message}`, 'myAccount');
    
    // Déterminer le code d'erreur approprié
    const statusCode = error.message.includes('validation') ? 400 : 500;
    
    return c.json({ error: 'Erreur lors de la mise à jour du profil', details: error.message, success: false }, statusCode);
  }
});

/**
 * PATCH /me/others
 * Met à jour le profil d'un autre utilisateur
 */
router.patch('/others', validateZod({ body: updateOtherProfileSchema }), async (c) => {
  try {
    logger.info('Mise à jour du profil d\'un autre utilisateur', 'myAccount');
    const data = c.get('validatedBody');
    
    if (!data.userId) {
      return c.json({ error: 'ID utilisateur manquant', success: false }, 400);
    }
    
    const result = await myAccountService.updateOtherProfile(data);
    return c.json({ data: result, success: true });
  } catch (error: any) {
    logger.error(`Erreur lors de la mise à jour du profil d'un autre utilisateur: ${error.message}`, 'myAccount');
    
    // Déterminer le code d'erreur approprié
    const statusCode = error.message.includes('validation') || error.message.includes('autorisation') ? 400 : 500;
    
    return c.json({ error: 'Erreur lors de la mise à jour du profil d\'un autre utilisateur', details: error.message, success: false }, statusCode);
  }
});

/**
 * POST /me/password
 * Met à jour le mot de passe de l'utilisateur connecté
 */
router.post('/password', validateZod({ body: updatePasswordSchema }), async (c) => {
  try {
    logger.info('Mise à jour du mot de passe', 'myAccount');
    const data = c.get('validatedBody');
    
    if (!data.oldPassword || !data.newPassword) {
      return c.json({ error: 'Mot de passe actuel et nouveau mot de passe requis', success: false }, 400);
    }
    
    const result = await myAccountService.updatePassword(data);
    return c.json({ data: result, success: true });
  } catch (error: any) {
    logger.error(`Erreur lors de la mise à jour du mot de passe: ${error.message}`, 'myAccount');
    
    // Codes d'erreur spécifiques pour les échecs de mot de passe
    if (error.message.includes('incorrect')) {
      return c.json({ error: 'Mot de passe actuel incorrect', details: error.message, success: false }, 401);
    }
    
    return c.json({ error: 'Erreur lors de la mise à jour du mot de passe', details: error.message, success: false }, 500);
  }
});

/**
 * POST /me/email
 * Met à jour l'email primaire de l'utilisateur connecté
 */
router.post('/email', validateZod({ body: updatePrimaryEmailSchema }), async (c) => {
  try {
    logger.info('Mise à jour de l\'email primaire', 'myAccount');
    const data = c.get('validatedBody');
    
    if (!data.email) {
      return c.json({ error: 'Email requis', success: false }, 400);
    }
    
    const result = await myAccountService.updatePrimaryEmail(data);
    return c.json({ data: result, success: true });
  } catch (error: any) {
    logger.error(`Erreur lors de la mise à jour de l'email primaire: ${error.message}`, 'myAccount');
    
    // Déterminer le code d'erreur approprié
    const statusCode = error.message.includes('existe déjà') ? 409 : 500;
    
    return c.json({ error: 'Erreur lors de la mise à jour de l\'email primaire', details: error.message, success: false }, statusCode);
  }
});

/**
 * DELETE /me/email
 * Supprime l'email primaire de l'utilisateur connecté
 */
router.delete('/email', async (c) => {
  try {
    logger.info('Suppression de l\'email primaire', 'myAccount');
    const result = await myAccountService.deletePrimaryEmail();
    return c.json({ success: true, message: 'Email primaire supprimé avec succès' });
  } catch (error: any) {
    logger.error(`Erreur lors de la suppression de l'email primaire: ${error.message}`, 'myAccount');
    return c.json({ error: 'Erreur lors de la suppression de l\'email primaire', details: error.message, success: false }, 500);
  }
});

/**
 * POST /me/phone
 * Met à jour le téléphone primaire de l'utilisateur connecté
 */
router.post('/phone', validateZod({ body: updatePrimaryPhoneSchema }), async (c) => {
  try {
    logger.info('Mise à jour du téléphone primaire', 'myAccount');
    const data = c.get('validatedBody');
    
    if (!data.phone) {
      return c.json({ error: 'Numéro de téléphone requis', success: false }, 400);
    }
    
    const result = await myAccountService.updatePrimaryPhone(data);
    return c.json({ data: result, success: true });
  } catch (error: any) {
    logger.error(`Erreur lors de la mise à jour du téléphone primaire: ${error.message}`, 'myAccount');
    
    // Déterminer le code d'erreur approprié
    const statusCode = error.message.includes('existe déjà') ? 409 : 500;
    
    return c.json({ error: 'Erreur lors de la mise à jour du téléphone primaire', details: error.message, success: false }, statusCode);
  }
});

/**
 * DELETE /me/phone
 * Supprime le téléphone primaire de l'utilisateur connecté
 */
router.delete('/phone', async (c) => {
  try {
    logger.info('Suppression du téléphone primaire', 'myAccount');
    const result = await myAccountService.deletePrimaryPhone();
    return c.json({ success: true, message: 'Téléphone primaire supprimé avec succès' });
  } catch (error: any) {
    logger.error(`Erreur lors de la suppression du téléphone primaire: ${error.message}`, 'myAccount');
    return c.json({ error: 'Erreur lors de la suppression du téléphone primaire', details: error.message, success: false }, 500);
  }
});

/**
 * POST /me/identities
 * Ajoute une identité utilisateur
 */
router.post('/identities', validateZod({ body: addUserIdentitySchema }), async (c) => {
  try {
    logger.info('Ajout d\'une identité utilisateur', 'myAccount');
    const data = c.get('validatedBody');
    
    if (!data.target || !data.connectorId) {
      return c.json({ error: 'Cible et ID du connecteur requis', success: false }, 400);
    }
    
    const result = await myAccountService.addUserIdentity(data);
    return c.json({ data: result, success: true });
  } catch (error: any) {
    logger.error(`Erreur lors de l'ajout d'une identité utilisateur: ${error.message}`, 'myAccount');
    
    // Déterminer le code d'erreur approprié
    const statusCode = error.message.includes('validation') ? 400 : 500;
    
    return c.json({ error: 'Erreur lors de l\'ajout d\'une identité utilisateur', details: error.message, success: false }, statusCode);
  }
});

/**
 * DELETE /me/identities
 * Supprime une identité utilisateur
 */
router.delete('/identities', async (c) => {
  try {
    logger.info('Suppression d\'une identité utilisateur', 'myAccount');
    const target = c.req.query('target');
    const connectorId = c.req.query('connectorId');
    
    if (!target || !connectorId) {
      return c.json({ error: 'Les paramètres target et connectorId sont requis', success: false }, 400);
    }
    
    const data = { target, connectorId };
    // Valider les données avec le schéma
    const validatedData = deleteUserIdentitySchema.parse(data);
    
    const result = await myAccountService.deleteUserIdentity(validatedData);
    return c.json({ success: true, message: 'Identité utilisateur supprimée avec succès' });
  } catch (error: any) {
    logger.error(`Erreur lors de la suppression d'une identité utilisateur: ${error.message}`, 'myAccount');
    
    // Déterminer le code d'erreur approprié
    const statusCode = error.message.includes('trouvé') ? 404 : 500;
    
    return c.json({ error: 'Erreur lors de la suppression d\'une identité utilisateur', details: error.message, success: false }, statusCode);
  }
});

export default router; 
