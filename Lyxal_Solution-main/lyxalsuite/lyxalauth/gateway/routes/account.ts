import { Hono } from 'hono';
import { structuredLogger as logger } from '../core/logger/structuredLogger';
import * as accountService from '../logic/accountService';
import { validateZod } from '../validators/validateZod';
import { updateAccountCenterSettingsSchema } from '../validators/schemas/accountSchemas';

const router = new Hono();

/**
 * GET /account-center/settings
 * Récupère les paramètres du centre de compte
 */
router.get('/settings', async (c) => {
  try {
    logger.info('Récupération des paramètres du centre de compte', 'account-center');
    const result = await accountService.getAccountCenterSettings();
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération des paramètres du centre de compte: ${error.message}`, 'account-center');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * PATCH /account-center/settings
 * Met à jour les paramètres du centre de compte
 */
router.patch('/settings', validateZod({ body: updateAccountCenterSettingsSchema }), async (c) => {
  try {
    logger.info('Mise à jour des paramètres du centre de compte', 'account-center');
    const data = c.get('validatedBody');
    const result = await accountService.updateAccountCenterSettings(data);
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la mise à jour des paramètres du centre de compte: ${error.message}`, 'account-center');
    return c.json({ error: error.message }, 400);
  }
});

export default router; 
