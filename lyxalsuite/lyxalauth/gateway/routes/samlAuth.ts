import { Hono } from 'hono';
import { structuredLogger as logger } from '../core/logger/structuredLogger';
import * as samlApplicationService from '../logic/samlApplicationService';
import {
  validateSamlAuthRedirect,
  validateSamlAuthPost
} from '../validators/samlAuthValidation';
import { AppError } from '../core/errors/AppError';

const router = new Hono();

/**
 * GET /saml/authn
 * Gère les requêtes d'authentification SAML via Redirect binding
 */
router.get('/', async (c) => {
  try {
    logger.info('Traitement d\'une requête d\'authentification SAML (Redirect binding)', 'samlAuth');
    
    // Récupérer les paramètres de requête
    const query = c.req.query();
    const samlRequest = query.SAMLRequest;
    const relayState = query.RelayState;
    
    if (!samlRequest) {
      logger.error('La requête SAMLRequest est manquante', 'samlAuth');
      return c.json({ error: 'La requête SAMLRequest est requise', code: 'SAML_REQUEST_MISSING' }, 400);
    }
    
    // Valider les paramètres
    const validatedData = validateSamlAuthRedirect({ SAMLRequest: samlRequest, RelayState: relayState });
    
    const result = await samlApplicationService.handleSamlAuthRequestRedirect(validatedData.SAMLRequest, validatedData.RelayState);
    
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors du traitement de la requête d'authentification SAML: ${error.message}`, 'samlAuth', { error });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

/**
 * POST /saml/authn
 * Gère les requêtes d'authentification SAML via POST binding
 */
router.post('/', async (c) => {
  try {
    logger.info('Traitement d\'une requête d\'authentification SAML (POST binding)', 'samlAuth');
    
    // Récupérer et valider le corps de la requête
    const body = await c.req.json();
    const validatedData = validateSamlAuthPost(body);
    
    const result = await samlApplicationService.handleSamlAuthRequestPost(validatedData);
    
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors du traitement de la requête d'authentification SAML: ${error.message}`, 'samlAuth', { error });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

export default router;