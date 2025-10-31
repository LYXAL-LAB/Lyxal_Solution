import { Hono } from 'hono';
import { structuredLogger as logger } from '../core/logger/structuredLogger';
import * as ssoConnectorProviderService from '../logic/ssoConnectorProviderService';
import { validateGetSsoConnectorProviders } from '../validators/ssoConnectorProvidersValidation';

const router = new Hono();

/**
 * GET /sso-connector-providers
 * Liste tous les détails des fournisseurs de connecteurs SSO supportés
 */
router.get('/', validateGetSsoConnectorProviders(), async (c) => {
  try {
    logger.info('Récupération des fournisseurs de connecteurs SSO', 'ssoConnectorProviders');
    
    const filters = c.get('validatedQuery')?.filters;
    
    const result = await ssoConnectorProviderService.getAllSsoConnectorProviders();
    
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération des fournisseurs de connecteurs SSO: ${error.message}`, 'ssoConnectorProviders');
    return c.json({ error: error.message }, 400);
  }
});

export default router; 
