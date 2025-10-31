import { Hono } from 'hono';
import { structuredLogger } from '../core/logger/structuredLogger';
import * as resourceService from '../logic/resourceService';
import { validateZod } from '../validators/validateZod';
import {
  createResourceSchema,
  updateResourceSchema,
  setResourceAsDefaultSchema,
  createResourceScopeSchema,
  updateResourceScopeSchema,
  paginationSchema
} from '../validators/schemas/resourceSchemas';
import {
  validateCreateResource,
  validateUpdateResource,
  validateSetResourceAsDefault,
  validateCreateResourceScope,
  validateUpdateResourceScope,
  validatePagination
} from '../validators/resourceValidation';
import { AppError, ErrorCode } from '../core/errors/AppError';

const router = new Hono();

/**
 * GET /resources
 * Récupère toutes les ressources API
 */
router.get('/', async (c) => {
  try {
    structuredLogger.info('Récupération des ressources API', 'resources');
    
    // Extraction et validation des paramètres de requête
    const page = c.req.query('page') ? parseInt(c.req.query('page') || '1', 10) : 1;
    const pageSize = c.req.query('page_size') ? parseInt(c.req.query('page_size') || '20', 10) : 20;
    
    const pagination = validatePagination({ page, pageSize });
    const result = await resourceService.getResources(
      pagination.page,
      pagination.pageSize
    );
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la récupération des ressources API', 'resources', {
      error: error.message
    });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

/**
 * POST /resources
 * Crée une nouvelle ressource API
 */
router.post('/', validateZod({ body: createResourceSchema }), async (c) => {
  try {
    structuredLogger.info('Création d\'une ressource API', 'resources');
    
    const data = c.get('validatedBody');
    
    const result = await resourceService.createResource(data);
    
    return c.json(result, 201);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la création de la ressource API', 'resources', {
      error: error.message
    });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

/**
 * GET /resources/:resourceId
 * Récupère une ressource API spécifique
 */
router.get('/:id', async (c) => {
  try {
    const resourceId = c.req.param('id');
    structuredLogger.info(`Récupération de la ressource API ${resourceId}`, 'resources', {
      resourceId
    });
    
    const result = await resourceService.getResource(resourceId);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la récupération de la ressource API', 'resources', {
      error: error.message
    });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

/**
 * DELETE /resources/:resourceId
 * Supprime une ressource API
 */
router.delete('/:id', async (c) => {
  try {
    const resourceId = c.req.param('id');
    structuredLogger.info(`Suppression de la ressource API ${resourceId}`, 'resources', {
      resourceId
    });
    
    const result = await resourceService.deleteResource(resourceId);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la suppression de la ressource API', 'resources', {
      error: error.message
    });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

/**
 * PATCH /resources/:resourceId
 * Met à jour une ressource API
 */
router.patch('/:id', validateZod({ body: updateResourceSchema }), async (c) => {
  try {
    const resourceId = c.req.param('id');
    structuredLogger.info(`Mise à jour de la ressource API ${resourceId}`, 'resources', {
      resourceId
    });
    
    const data = c.get('validatedBody');
    
    const result = await resourceService.updateResource(resourceId, data);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la mise à jour de la ressource API', 'resources', {
      error: error.message
    });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

/**
 * PATCH /resources/:resourceId/is-default
 * Définit une ressource API comme défaut
 */
router.patch('/:id/is-default', validateZod({ body: setResourceAsDefaultSchema }), async (c) => {
  try {
    const resourceId = c.req.param('id');
    structuredLogger.info(`Définition de la ressource API ${resourceId} comme défaut`, 'resources', {
      resourceId
    });
    
    const data = c.get('validatedBody');
    
    const result = await resourceService.setResourceAsDefault(resourceId, data);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la définition de la ressource API comme défaut', 'resources', {
      error: error.message
    });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

/**
 * GET /resources/:resourceId/scopes
 * Récupère les scopes d'une ressource API
 */
router.get('/:id/scopes', async (c) => {
  try {
    const resourceId = c.req.param('id');
    structuredLogger.info(`Récupération des scopes pour la ressource API ${resourceId}`, 'resources', {
      resourceId
    });
    
    const result = await resourceService.getResourceScopes(resourceId);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la récupération des scopes de la ressource API', 'resources', {
      error: error.message
    });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

/**
 * POST /resources/:resourceId/scopes
 * Crée un nouveau scope pour une ressource API
 */
router.post('/:id/scopes', validateZod({ body: createResourceScopeSchema }), async (c) => {
  try {
    const resourceId = c.req.param('id');
    structuredLogger.info(`Création d'un scope pour la ressource API ${resourceId}`, 'resources', {
      resourceId
    });
    
    const data = c.get('validatedBody');
    
    const result = await resourceService.createResourceScope(resourceId, data);
    
    return c.json(result, 201);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la création du scope pour la ressource API', 'resources', {
      error: error.message
    });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

/**
 * DELETE /resources/:resourceId/scopes/:scopeId
 * Supprime un scope d'une ressource API
 */
router.delete('/:id/scopes/:scopeId', async (c) => {
  try {
    const resourceId = c.req.param('id');
    const scopeId = c.req.param('scopeId');
    structuredLogger.info(`Suppression du scope ${scopeId} de la ressource API ${resourceId}`, 'resources', {
      resourceId,
      scopeId
    });
    
    const result = await resourceService.deleteResourceScope(resourceId, scopeId);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la suppression du scope de la ressource API', 'resources', {
      error: error.message
    });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

/**
 * PATCH /resources/:resourceId/scopes/:scopeId
 * Met à jour un scope d'une ressource API
 */
router.patch('/:id/scopes/:scopeId', validateZod({ body: updateResourceScopeSchema }), async (c) => {
  try {
    const resourceId = c.req.param('id');
    const scopeId = c.req.param('scopeId');
    structuredLogger.info(`Mise à jour du scope ${scopeId} de la ressource API ${resourceId}`, 'resources', {
      resourceId,
      scopeId
    });
    
    const data = c.get('validatedBody');
    
    const result = await resourceService.updateResourceScope(resourceId, scopeId, data);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la mise à jour du scope de la ressource API', 'resources', {
      error: error.message
    });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

export default router; 
