import { Hono } from 'hono';
import { structuredLogger as logger } from '../core/logger/structuredLogger';
import * as samlApplicationService from '../logic/samlApplicationService';
import {
  validateCreateSamlApplication,
  validateUpdateSamlApplication,
  validateCreateSamlApplicationSecret,
  validateUpdateSamlApplicationSecret
} from '../validators/samlApplicationsValidation';
import { AppError } from '../core/errors/AppError';

const router = new Hono();

/**
 * POST /saml-applications
 * Crée une nouvelle application SAML
 */
router.post('/', async (c) => {
  try {
    logger.info('Création d\'une application SAML', 'samlApplications');
    
    const body = await c.req.json();
    const data = validateCreateSamlApplication(body);
    
    const result = await samlApplicationService.createSamlApplication(data);
    
    return c.json(result, 201);
  } catch (error: any) {
    logger.error(`Erreur lors de la création de l'application SAML: ${error.message}`, 'samlApplications', { error });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

/**
 * GET /saml-applications/:applicationId
 * Récupère une application SAML spécifique
 */
router.get('/:id', async (c) => {
  try {
    const applicationId = c.req.param('id');
    logger.info(`Récupération de l'application SAML ${applicationId}`, 'samlApplications');
    
    const result = await samlApplicationService.getSamlApplication(applicationId);
    
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération de l'application SAML: ${error.message}`, 'samlApplications', { error });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

/**
 * DELETE /saml-applications/:applicationId
 * Supprime une application SAML
 */
router.delete('/:id', async (c) => {
  try {
    const applicationId = c.req.param('id');
    logger.info(`Suppression de l'application SAML ${applicationId}`, 'samlApplications');
    
    const result = await samlApplicationService.deleteSamlApplication(applicationId);
    
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la suppression de l'application SAML: ${error.message}`, 'samlApplications', { error });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

/**
 * PATCH /saml-applications/:applicationId
 * Met à jour une application SAML
 */
router.patch('/:id', async (c) => {
  try {
    const applicationId = c.req.param('id');
    logger.info(`Mise à jour de l'application SAML ${applicationId}`, 'samlApplications');
    
    const body = await c.req.json();
    const data = validateUpdateSamlApplication(body);
    
    const result = await samlApplicationService.updateSamlApplication(applicationId, data);
    
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la mise à jour de l'application SAML: ${error.message}`, 'samlApplications', { error });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

/**
 * GET /saml-applications/:applicationId/secrets
 * Liste les secrets d'une application SAML
 */
router.get('/:id/secrets', async (c) => {
  try {
    const applicationId = c.req.param('id');
    logger.info(`Récupération des secrets pour l'application SAML ${applicationId}`, 'samlApplications');
    
    const result = await samlApplicationService.listSamlApplicationSecrets(applicationId);
    
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération des secrets de l'application SAML: ${error.message}`, 'samlApplications', { error });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

/**
 * POST /saml-applications/:applicationId/secrets
 * Crée un nouveau secret pour une application SAML
 */
router.post('/:id/secrets', async (c) => {
  try {
    const applicationId = c.req.param('id');
    logger.info(`Création d'un secret pour l'application SAML ${applicationId}`, 'samlApplications');
    
    const body = await c.req.json();
    const data = validateCreateSamlApplicationSecret(body);
    
    const result = await samlApplicationService.createSamlApplicationSecret(applicationId, data);
    
    return c.json(result, 201);
  } catch (error: any) {
    logger.error(`Erreur lors de la création du secret pour l'application SAML: ${error.message}`, 'samlApplications', { error });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

/**
 * DELETE /saml-applications/:applicationId/secrets/:secretId
 * Supprime un secret d'une application SAML
 */
router.delete('/:id/secrets/:secretId', async (c) => {
  try {
    const applicationId = c.req.param('id');
    const secretId = c.req.param('secretId');
    logger.info(`Suppression du secret ${secretId} de l'application SAML ${applicationId}`, 'samlApplications');
    
    const result = await samlApplicationService.deleteSamlApplicationSecret(applicationId, secretId);
    
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la suppression du secret de l'application SAML: ${error.message}`, 'samlApplications', { error });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

/**
 * PATCH /saml-applications/:applicationId/secrets/:secretId
 * Met à jour un secret d'une application SAML
 */
router.patch('/:id/secrets/:secretId', async (c) => {
  try {
    const applicationId = c.req.param('id');
    const secretId = c.req.param('secretId');
    logger.info(`Mise à jour du secret ${secretId} de l'application SAML ${applicationId}`, 'samlApplications');
    
    const body = await c.req.json();
    const data = validateUpdateSamlApplicationSecret(body);
    
    const result = await samlApplicationService.updateSamlApplicationSecret(applicationId, secretId, data);
    
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la mise à jour du secret de l'application SAML: ${error.message}`, 'samlApplications', { error });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

/**
 * GET /saml-applications/:applicationId/metadata
 * Récupère les métadonnées d'une application SAML
 */
router.get('/:id/metadata', async (c) => {
  try {
    const applicationId = c.req.param('id');
    logger.info(`Récupération des métadonnées pour l'application SAML ${applicationId}`, 'samlApplications');
    
    const result = await samlApplicationService.getSamlApplicationMetadata(applicationId);
    
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération des métadonnées de l'application SAML: ${error.message}`, 'samlApplications', { error });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

/**
 * GET /saml-applications/:applicationId/callback
 * Gère le callback SAML
 */
router.get('/:id/callback', async (c) => {
  try {
    const applicationId = c.req.param('id');
    logger.info(`Traitement du callback pour l'application SAML ${applicationId}`, 'samlApplications');
    
    // Récupérer tous les paramètres de requête
    const queryParams: Record<string, string> = {};
    const query = c.req.query();
    Object.keys(query).forEach(key => {
      const value = query[key];
      if (value) {
        queryParams[key] = value;
      }
    });
    
    const result = await samlApplicationService.handleSamlApplicationCallback(applicationId, queryParams);
    
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors du traitement du callback SAML: ${error.message}`, 'samlApplications', { error });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

export default router; 
