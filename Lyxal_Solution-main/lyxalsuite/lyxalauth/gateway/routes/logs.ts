import { Hono } from 'hono';
import { structuredLogger as logger } from '../core/logger/structuredLogger';
import * as logService from '../logic/logService';
import { validateZod } from '../validators/validateZod';
import { getLogsQuerySchema } from '../validators/schemas/logSchemas';
import { cacheControl } from '../middleware/cacheControlMiddleware';

const router = new Hono();

// Appliquer les en-têtes de contrôle du cache pour éviter le stockage des données sensibles
router.use('*', cacheControl({ noStore: true, noCache: true }));

/**
 * GET /logs
 * Récupère les journaux d'audit avec possibilité de filtrage
 */
router.get('/', validateZod({ query: getLogsQuerySchema }), async (c) => {
  try {
    logger.info('Récupération des journaux d\'audit', 'logs');
    
    // Les données sont déjà validées par le middleware validateZod
    const validatedParams = c.get('validatedQuery');
    const result = await logService.getLogs(validatedParams);
    
    return c.json({ data: result, success: true });
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération des journaux d'audit: ${error.message}`, 'logs');
    return c.json({ error: 'Erreur lors de la récupération des journaux d\'audit', details: error.message, success: false }, 500);
  }
});

/**
 * GET /logs/:id
 * Récupère un journal d'audit spécifique par son ID
 */
router.get('/:id', async (c) => {
  try {
    const logId = c.req.param('id');
    if (!logId) {
      return c.json({ error: 'ID de journal manquant', success: false }, 400);
    }
    
    logger.info(`Récupération du journal d'audit ${logId}`, 'logs');
    const result = await logService.getLogById(logId);
    
    if (!result) {
      return c.json({ error: 'Journal d\'audit non trouvé', success: false }, 404);
    }
    
    return c.json({ data: result, success: true });
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération du journal d'audit: ${error.message}`, 'logs');
    return c.json({ error: 'Erreur lors de la récupération du journal d\'audit', details: error.message, success: false }, 500);
  }
});

export default router; 
