import { Hono } from 'hono';
import { structuredLogger as logger } from '../core/logger/structuredLogger';
import * as swaggerService from '../logic/swaggerService';
import { AppError } from '../core/errors/AppError';

const router = new Hono();

/**
 * GET /swagger/json
 * Récupère la documentation Swagger JSON générale
 */
router.get('/json', async (c) => {
  try {
    logger.info('Récupération de la documentation Swagger JSON', 'swagger');
    
    const result = await swaggerService.getSwaggerJson();
    
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération de la documentation Swagger: ${error.message}`, 'swagger', { error });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

/**
 * GET /swagger/management-api
 * Récupère la documentation Swagger JSON de l'API de gestion
 */
router.get('/management-api', async (c) => {
  try {
    logger.info('Récupération de la documentation Swagger JSON de l\'API de gestion', 'swagger');
    
    const result = await swaggerService.getManagementApiSwaggerJson();
    
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération de la documentation Swagger de l'API de gestion: ${error.message}`, 'swagger', { error });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

/**
 * GET /swagger/experience-api
 * Récupère la documentation Swagger JSON de l'API d'expérience
 */
router.get('/experience-api', async (c) => {
  try {
    logger.info('Récupération de la documentation Swagger JSON de l\'API d\'expérience', 'swagger');
    
    const result = await swaggerService.getExperienceApiSwaggerJson();
    
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération de la documentation Swagger de l'API d'expérience: ${error.message}`, 'swagger', { error });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

/**
 * GET /swagger/user-api
 * Récupère la documentation Swagger JSON de l'API utilisateur
 */
router.get('/user-api', async (c) => {
  try {
    logger.info('Récupération de la documentation Swagger JSON de l\'API utilisateur', 'swagger');
    
    const result = await swaggerService.getUserApiSwaggerJson();
    
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération de la documentation Swagger de l'API utilisateur: ${error.message}`, 'swagger', { error });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

export default router;
