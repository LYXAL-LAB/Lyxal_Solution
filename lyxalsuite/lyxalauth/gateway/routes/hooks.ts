import { Hono } from 'hono';
import { structuredLogger as logger } from '../core/logger/structuredLogger';
import * as hookService from '../logic/hookService';
import { validateZod } from '../validators/validateZod';
import {
  createHookSchema,
  updateHookSchema,
  updateSigningKeySchema
} from '../validators/schemas/hookSchemas';
import { rateLimiter } from '../middleware/rateLimiter';

const router = new Hono();

// Appliquer la limitation de débit à toutes les routes
router.use('*', rateLimiter({
  windowMs: 60000, // 1 minute
  maxRequests: 100, // 100 requêtes par minute
  message: 'Trop de requêtes, veuillez réessayer plus tard'
}));

/**
 * GET /hooks
 * Récupère tous les webhooks
 */
router.get('/', async (c) => {
  try {
    logger.info('Récupération de tous les webhooks', 'hooks');
    const result = await hookService.getHooks();
    return c.json({ data: result, success: true });
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération des webhooks: ${error.message}`, 'hooks');
    return c.json({ error: 'Erreur lors de la récupération des webhooks', details: error.message, success: false }, 500);
  }
});

/**
 * POST /hooks
 * Crée un nouveau webhook
 */
router.post('/', validateZod({ body: createHookSchema }), async (c) => {
  try {
    logger.info('Création d\'un nouveau webhook', 'hooks');
    
    // Les données sont déjà validées par le middleware validateZod
    const data = c.get('validatedBody');
    const result = await hookService.createHook(data);
    
    return c.json({ data: result, success: true }, 201);
  } catch (error: any) {
    logger.error(`Erreur lors de la création d'un webhook: ${error.message}`, 'hooks');
    return c.json({ error: 'Erreur lors de la création d\'un webhook', details: error.message, success: false }, 500);
  }
});

/**
 * GET /hooks/:id
 * Récupère un webhook par son ID
 */
router.get('/:id', async (c) => {
  try {
    const hookId = c.req.param('id');
    if (!hookId) {
      return c.json({ error: 'ID de webhook manquant', success: false }, 400);
    }
    
    logger.info(`Récupération du webhook ${hookId}`, 'hooks');
    const result = await hookService.getHookById(hookId);
    
    if (!result) {
      return c.json({ error: 'Webhook non trouvé', success: false }, 404);
    }
    
    return c.json({ data: result, success: true });
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération du webhook: ${error.message}`, 'hooks');
    return c.json({ error: 'Erreur lors de la récupération du webhook', details: error.message, success: false }, 500);
  }
});

/**
 * DELETE /hooks/:id
 * Supprime un webhook
 */
router.delete('/:id', async (c) => {
  try {
    const hookId = c.req.param('id');
    if (!hookId) {
      return c.json({ error: 'ID de webhook manquant', success: false }, 400);
    }
    
    logger.info(`Suppression du webhook ${hookId}`, 'hooks');
    const result = await hookService.deleteHook(hookId);
    
    if (!result) {
      return c.json({ error: 'Webhook non trouvé ou déjà supprimé', success: false }, 404);
    }
    
    return c.json({ success: true, message: 'Webhook supprimé avec succès' });
  } catch (error: any) {
    logger.error(`Erreur lors de la suppression du webhook: ${error.message}`, 'hooks');
    return c.json({ error: 'Erreur lors de la suppression du webhook', details: error.message, success: false }, 500);
  }
});

/**
 * PATCH /hooks/:id
 * Met à jour un webhook
 */
router.patch('/:id', validateZod({ body: updateHookSchema }), async (c) => {
  try {
    const hookId = c.req.param('id');
    if (!hookId) {
      return c.json({ error: 'ID de webhook manquant', success: false }, 400);
    }
    
    logger.info(`Mise à jour du webhook ${hookId}`, 'hooks');
    
    // Les données sont déjà validées par le middleware validateZod
    const data = c.get('validatedBody');
    const result = await hookService.updateHook(hookId, data);
    
    if (!result) {
      return c.json({ error: 'Webhook non trouvé', success: false }, 404);
    }
    
    return c.json({ data: result, success: true });
  } catch (error: any) {
    logger.error(`Erreur lors de la mise à jour du webhook: ${error.message}`, 'hooks');
    return c.json({ error: 'Erreur lors de la mise à jour du webhook', details: error.message, success: false }, 500);
  }
});

/**
 * GET /hooks/:id/recent-logs
 * Récupère les logs récents d'un webhook
 */
router.get('/:id/recent-logs', async (c) => {
  try {
    const hookId = c.req.param('id');
    if (!hookId) {
      return c.json({ error: 'ID de webhook manquant', success: false }, 400);
    }
    
    logger.info(`Récupération des logs récents pour le webhook ${hookId}`, 'hooks');
    const result = await hookService.getHookLogs(hookId);
    
    if (!result) {
      return c.json({ error: 'Webhook non trouvé', success: false }, 404);
    }
    
    return c.json({ data: result, success: true });
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération des logs du webhook: ${error.message}`, 'hooks');
    return c.json({ error: 'Erreur lors de la récupération des logs du webhook', details: error.message, success: false }, 500);
  }
});

/**
 * POST /hooks/:id/test
 * Teste un webhook
 */
router.post('/:id/test', async (c) => {
  try {
    const hookId = c.req.param('id');
    if (!hookId) {
      return c.json({ error: 'ID de webhook manquant', success: false }, 400);
    }
    
    logger.info(`Test du webhook ${hookId}`, 'hooks');
    const result = await hookService.testHook(hookId);
    
    if (!result) {
      return c.json({ error: 'Webhook non trouvé', success: false }, 404);
    }
    
    return c.json({ data: result, success: true });
  } catch (error: any) {
    logger.error(`Erreur lors du test du webhook: ${error.message}`, 'hooks');
    return c.json({ error: 'Erreur lors du test du webhook', details: error.message, success: false }, 500);
  }
});

/**
 * PATCH /hooks/:id/signing-key
 * Met à jour la clé de signature d'un webhook
 */
router.patch('/:id/signing-key', validateZod({ body: updateSigningKeySchema }), async (c) => {
  try {
    const hookId = c.req.param('id');
    if (!hookId) {
      return c.json({ error: 'ID de webhook manquant', success: false }, 400);
    }
    
    logger.info(`Mise à jour de la clé de signature pour le webhook ${hookId}`, 'hooks');
    
    // Les données sont déjà validées par le middleware validateZod
    const data = c.get('validatedBody');
    const result = await hookService.updateSigningKey(hookId, data);
    
    if (!result) {
      return c.json({ error: 'Webhook non trouvé', success: false }, 404);
    }
    
    return c.json({ data: result, success: true });
  } catch (error: any) {
    logger.error(`Erreur lors de la mise à jour de la clé de signature du webhook: ${error.message}`, 'hooks');
    return c.json({ error: 'Erreur lors de la mise à jour de la clé de signature du webhook', details: error.message, success: false }, 500);
  }
});

export default router; 
