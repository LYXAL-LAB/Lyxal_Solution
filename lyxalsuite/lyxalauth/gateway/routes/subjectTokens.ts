import { Hono } from 'hono';
import { structuredLogger as logger } from '../core/logger/structuredLogger';
import * as subjectTokenService from '../logic/subjectTokenService';
import { validateCreateSubjectToken } from '../validators/subjectTokenValidation';
import { AppError } from '../core/errors/AppError';

const router = new Hono();

/**
 * POST /subject-tokens
 * Crée un nouveau token de sujet
 */
router.post('/', async (c) => {
  try {
    logger.info('Création d\'un nouveau token de sujet', 'subjectTokens');
    
    const body = await c.req.json();
    const data = validateCreateSubjectToken(body);
    
    const result = await subjectTokenService.createSubjectToken(data);
    
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la création d'un token de sujet: ${error.message}`, 'subjectTokens', { error });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

export default router;
