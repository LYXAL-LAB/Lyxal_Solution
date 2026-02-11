import { Hono } from 'hono';
import { structuredLogger as logger } from '../core/logger/structuredLogger';
import * as sentinelService from '../logic/sentinelService';
import { validateBulkDeleteSentinelActivities } from '../validators/sentinelValidation';

const router = new Hono();

/**
 * POST /sentinel/activities
 * Supprime en masse des activités Sentinel
 */
router.post('/activities', async (c) => {
  try {
    logger.info('Suppression en masse d\'activités Sentinel', 'sentinel');
    
    const body = await c.req.json();
    const data = validateBulkDeleteSentinelActivities(body);
    
    const result = await sentinelService.bulkDeleteSentinelActivities(data);
    
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la suppression en masse d'activités Sentinel: ${error.message}`, 'sentinel');
    return c.json({ error: error.message }, 400);
  }
});

export default router; 
