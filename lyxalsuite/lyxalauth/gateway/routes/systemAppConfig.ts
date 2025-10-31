import { Hono } from 'hono';
import { structuredLogger as logger } from '../core/logger/structuredLogger';
import * as systemAppConfigService from '../logic/systemAppConfigService';
import { AppError } from '../core/errors/AppError';

const router = new Hono();

/**
 * GET /system-app-config
 * Récupère les constantes d'application système
 */
router.get('/', async (c) => {
  try {
    logger.info('Récupération des constantes d\'application système', 'systemAppConfig');
    
    const result = await systemAppConfigService.getSystemApplicationConfig();
    
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération des constantes d'application: ${error.message}`, 'systemAppConfig', { error });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

export default router;
