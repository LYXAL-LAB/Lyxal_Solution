import { Hono } from 'hono';
import { structuredLogger as logger } from '../core/logger/structuredLogger';
import * as statusService from '../logic/statusService';
import { validateHealthCheck } from '../validators/statusValidation';

const router = new Hono();

/**
 * GET /status
 * Vérifie l'état de santé du service Logto
 */
router.get('/', validateHealthCheck(), async (c) => {
  try {
    logger.info('Vérification de l\'état de santé de Logto', 'status');
    
    // On récupère les paramètres validés mais on ne les passe pas à checkHealth
    // car la fonction n'attend pas d'arguments
    c.get('validatedQuery'); 
    await statusService.checkHealth();
    
    // On suit le comportement de l'API Logto et on renvoie un 204 No Content
    return c.body(null, 204);
  } catch (error: any) {
    logger.error(`Erreur lors de la vérification de l'état de santé: ${error.message}`, 'status');
    return c.json({ error: error.message }, 503);
  }
});

export default router; 
