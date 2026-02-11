import { Hono } from 'hono';
import { structuredLogger as logger } from '../core/logger/structuredLogger';
import * as oneTimeTokenService from '../logic/oneTimeTokenService';
import { validateZod } from '../validators/validateZod';
import {
  createOneTimeTokenSchema,
  verifyOneTimeTokenSchema,
  updateOneTimeTokenStatusSchema,
  paginationSchema
} from '../validators/schemas/oneTimeTokenSchemas';
import { authRateLimiter } from '../middleware/rateLimiter';

const router = new Hono();

// Appliquer une limitation de débit stricte pour les vérifications de tokens
router.use('/verify', authRateLimiter());

/**
 * GET /one-time-tokens
 * Récupère tous les jetons à usage unique
 */
router.get('/', async (c) => {
  try {
    logger.info('Récupération des jetons à usage unique', 'oneTimeTokens');
    
    // Extraction et validation des paramètres de requête
    const page = c.req.query('page') ? parseInt(c.req.query('page') || '1', 10) : 1;
    const pageSize = c.req.query('page_size') ? parseInt(c.req.query('page_size') || '20', 10) : 20;
    
    // Utilisation du schéma de validation pour la pagination
    const pagination = paginationSchema.parse({ page, pageSize });
    const result = await oneTimeTokenService.getOneTimeTokens(pagination.page, pagination.pageSize);
    
    return c.json({ data: result, success: true });
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération des jetons à usage unique: ${error.message}`, 'oneTimeTokens');
    
    // Déterminer le code d'erreur approprié
    const statusCode = error.message.includes('validation') ? 400 : 500;
    
    return c.json({ error: 'Erreur lors de la récupération des jetons à usage unique', details: error.message, success: false }, statusCode);
  }
});

/**
 * POST /one-time-tokens
 * Crée un nouveau jeton à usage unique
 */
router.post('/', validateZod({ body: createOneTimeTokenSchema }), async (c) => {
  try {
    logger.info('Création d\'un nouveau jeton à usage unique', 'oneTimeTokens');
    
    // Les données sont déjà validées par le middleware validateZod
    const data = c.get('validatedBody');
    const result = await oneTimeTokenService.createOneTimeToken(data);
    
    return c.json({ data: result, success: true }, 201);
  } catch (error: any) {
    logger.error(`Erreur lors de la création d'un jeton à usage unique: ${error.message}`, 'oneTimeTokens');
    return c.json({ error: 'Erreur lors de la création d\'un jeton à usage unique', details: error.message, success: false }, 500);
  }
});

/**
 * GET /one-time-tokens/:id
 * Récupère un jeton à usage unique par son ID
 */
router.get('/:id', async (c) => {
  try {
    const id = c.req.param('id');
    if (!id) {
      return c.json({ error: 'ID de jeton manquant', success: false }, 400);
    }
    
    logger.info(`Récupération du jeton à usage unique ${id}`, 'oneTimeTokens');
    const result = await oneTimeTokenService.getOneTimeTokenById(id);
    
    if (!result) {
      return c.json({ error: 'Jeton à usage unique non trouvé', success: false }, 404);
    }
    
    return c.json({ data: result, success: true });
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération du jeton à usage unique: ${error.message}`, 'oneTimeTokens');
    return c.json({ error: 'Erreur lors de la récupération du jeton à usage unique', details: error.message, success: false }, 500);
  }
});

/**
 * DELETE /one-time-tokens/:id
 * Supprime un jeton à usage unique
 */
router.delete('/:id', async (c) => {
  try {
    const id = c.req.param('id');
    if (!id) {
      return c.json({ error: 'ID de jeton manquant', success: false }, 400);
    }
    
    logger.info(`Suppression du jeton à usage unique ${id}`, 'oneTimeTokens');
    const result = await oneTimeTokenService.deleteOneTimeToken(id);
    
    if (!result) {
      return c.json({ error: 'Jeton à usage unique non trouvé ou déjà supprimé', success: false }, 404);
    }
    
    return c.json({ success: true, message: 'Jeton à usage unique supprimé avec succès' });
  } catch (error: any) {
    logger.error(`Erreur lors de la suppression du jeton à usage unique: ${error.message}`, 'oneTimeTokens');
    return c.json({ error: 'Erreur lors de la suppression du jeton à usage unique', details: error.message, success: false }, 500);
  }
});

/**
 * POST /one-time-tokens/verify
 * Vérifie un jeton à usage unique
 */
router.post('/verify', validateZod({ body: verifyOneTimeTokenSchema }), async (c) => {
  try {
    logger.info('Vérification d\'un jeton à usage unique', 'oneTimeTokens');
    
    // Les données sont déjà validées par le middleware validateZod
    const data = c.get('validatedBody');
    const result = await oneTimeTokenService.verifyOneTimeToken(data);
    
    return c.json({ data: result, success: true });
  } catch (error: any) {
    logger.error(`Erreur lors de la vérification du jeton à usage unique: ${error.message}`, 'oneTimeTokens');
    
    // Codes d'erreur spécifiques pour les échecs de vérification
    if (error.message.includes('expiré')) {
      return c.json({ error: 'Jeton expiré', details: error.message, success: false }, 401);
    } else if (error.message.includes('invalide') || error.message.includes('trouvé')) {
      return c.json({ error: 'Jeton invalide', details: error.message, success: false }, 401);
    }
    
    return c.json({ error: 'Erreur lors de la vérification du jeton à usage unique', details: error.message, success: false }, 500);
  }
});

/**
 * PUT /one-time-tokens/:id/status
 * Met à jour le statut d'un jeton à usage unique
 */
router.put('/:id/status', validateZod({ body: updateOneTimeTokenStatusSchema }), async (c) => {
  try {
    const id = c.req.param('id');
    if (!id) {
      return c.json({ error: 'ID de jeton manquant', success: false }, 400);
    }
    
    logger.info(`Mise à jour du statut du jeton à usage unique ${id}`, 'oneTimeTokens');
    
    // Les données sont déjà validées par le middleware validateZod
    const data = c.get('validatedBody');
    const result = await oneTimeTokenService.updateOneTimeTokenStatus(id, data);
    
    if (!result) {
      return c.json({ error: 'Jeton à usage unique non trouvé', success: false }, 404);
    }
    
    return c.json({ data: result, success: true });
  } catch (error: any) {
    logger.error(`Erreur lors de la mise à jour du statut du jeton à usage unique: ${error.message}`, 'oneTimeTokens');
    return c.json({ error: 'Erreur lors de la mise à jour du statut du jeton à usage unique', details: error.message, success: false }, 500);
  }
});

export default router; 
