/**
 * @file authn.ts
 * @description Routes d'authentification externe (Hasura, SAML)
 */

import { Hono } from 'hono';
import { structuredLogger as logger } from '../core/logger/structuredLogger';
import * as authnService from '../logic/authnService';
import { validateZod } from '../validators/validateZod';
import { hasuraAuthQuerySchema, samlAcsBodySchema } from '../validators/schemas/authnSchemas';

const router = new Hono();

/**
 * @route GET /authn/hasura
 * @description Endpoint d'authentification Hasura
 * @access Public avec token
 */
router.get('/hasura', validateZod({ query: hasuraAuthQuerySchema }), async (c) => {
  try {
    logger.info('Requête d\'authentification Hasura', 'authn');
    const validatedParams = c.get('validatedQuery');
    
    // Récupération du header d'autorisation
    const authHeader = c.req.header('Authorization');
    
    logger.debug('Traitement de la requête d\'authentification Hasura', 'authn', {
      role: validatedParams.role || 'default'
    });
    
    const result = await authnService.getHasuraAuthHook({
      role: validatedParams.role || '',
      authorization: authHeader
    });
    
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de l'authentification Hasura: ${error.message}`, 'authn', {
      error: error.message,
      stack: error.stack
    });
    return c.json({ error: error.message }, 400);
  }
});

/**
 * @route POST /authn/saml/acs/social
 * @description Endpoint SAML ACS pour l'authentification sociale
 * @access Public
 */
router.post('/saml/acs/social', async (c) => {
  try {
    logger.info('Requête SAML ACS (social)', 'authn');
    
    // Les données SAML sont généralement envoyées sous forme de formulaire
    const formData = await c.req.formData();
    const samlData = {
      RelayState: formData.get('RelayState')?.toString(),
      SAMLResponse: formData.get('SAMLResponse')?.toString() || ''
    };
    
    // Validation manuelle des données SAML
    const validatedData = validateZod({ body: samlAcsBodySchema })(
      { ...c, req: { json: () => Promise.resolve(samlData) } } as any,
      async () => {}
    );
    
    logger.debug('Traitement des données SAML ACS (social)', 'authn', {
      relayStatePresent: !!samlData.RelayState,
      samlResponseLength: samlData.SAMLResponse.length
    });
    
    const result = await authnService.samlAcsSocial(samlData);
    
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors du traitement SAML ACS (social): ${error.message}`, 'authn', {
      error: error.message,
      stack: error.stack
    });
    return c.json({ error: error.message }, 400);
  }
});

/**
 * @route POST /authn/saml/acs/sso
 * @description Endpoint SAML ACS pour l'authentification SSO
 * @access Public
 */
router.post('/saml/acs/sso', async (c) => {
  try {
    logger.info('Requête SAML ACS (SSO)', 'authn');
    
    // Les données SAML sont généralement envoyées sous forme de formulaire
    const formData = await c.req.formData();
    const samlData = {
      RelayState: formData.get('RelayState')?.toString(),
      SAMLResponse: formData.get('SAMLResponse')?.toString() || ''
    };
    
    // Validation manuelle des données SAML
    const validatedData = validateZod({ body: samlAcsBodySchema })(
      { ...c, req: { json: () => Promise.resolve(samlData) } } as any,
      async () => {}
    );
    
    logger.debug('Traitement des données SAML ACS (SSO)', 'authn', {
      relayStatePresent: !!samlData.RelayState,
      samlResponseLength: samlData.SAMLResponse.length
    });
    
    const result = await authnService.samlAcsSso(samlData);
    
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors du traitement SAML ACS (SSO): ${error.message}`, 'authn', {
      error: error.message,
      stack: error.stack
    });
    return c.json({ error: error.message }, 400);
  }
});

export default router; 
