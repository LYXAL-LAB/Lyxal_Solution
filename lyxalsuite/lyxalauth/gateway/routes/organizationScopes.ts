import { Hono } from 'hono';
import { structuredLogger } from '../core/logger/structuredLogger';
import * as organizationScopeService from '../logic/organizationScopeService';
import { validateZod } from '../validators/validateZod';
import {
  createOrganizationScopeSchema,
  updateOrganizationScopeSchema,
  paginationSchema
} from '../validators/schemas/organizationScopeSchemas';
import {
  validateCreateOrganizationScope,
  validateUpdateOrganizationScope,
  validatePagination
} from '../validators/organizationScopeValidation';
import { authRequired } from '../middleware/authMiddleware';
import { rateLimiter } from '../middleware/rateLimiter';
import { AppError, ErrorCode } from '../core/errors/AppError';

const router = new Hono();

// Appliquer le middleware d'authentification à toutes les routes
router.use('*', authRequired);

// Appliquer le middleware de limitation de taux pour prévenir les abus
router.use('*', rateLimiter({ 
  windowMs: 15 * 60 * 1000, 
  maxRequests: 100,
  message: 'Trop de requêtes, veuillez réessayer plus tard'
}));

/**
 * GET /organizations/:organizationId/scopes
 * Récupère tous les scopes d'une organisation
 */
router.get('/:organizationId/scopes', async (c) => {
  try {
    const organizationId = c.req.param('organizationId');
    if (!organizationId) {
      throw new AppError('ID d\'organisation manquant', ErrorCode.MISSING_REQUIRED_FIELD);
    }
    
    structuredLogger.info('Récupération des scopes', 'organizationScopes', {
      organizationId
    });
    
    // Extraction et validation des paramètres de requête
    const page = c.req.query('page') ? parseInt(c.req.query('page') || '1', 10) : 1;
    const pageSize = c.req.query('page_size') ? parseInt(c.req.query('page_size') || '20', 10) : 20;
    
    const pagination = validatePagination({ page, pageSize });
    const result = await organizationScopeService.getOrganizationScopes(
      organizationId,
      pagination.page,
      pagination.pageSize
    );
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la récupération des scopes', 'organizationScopes', {
      error: error.message
    });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

/**
 * GET /organizations/:organizationId/scopes/:scopeId
 * Récupère un scope spécifique d'une organisation
 */
router.get('/:organizationId/scopes/:scopeId', async (c) => {
  try {
    const organizationId = c.req.param('organizationId');
    const scopeId = c.req.param('scopeId');
    
    if (!organizationId || !scopeId) {
      throw new AppError('Paramètres manquants', ErrorCode.MISSING_REQUIRED_FIELD);
    }
    
    structuredLogger.info('Récupération d\'un scope spécifique', 'organizationScopes', {
      organizationId,
      scopeId
    });
    
    const result = await organizationScopeService.getOrganizationScope(organizationId, scopeId);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la récupération du scope', 'organizationScopes', {
      error: error.message
    });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

/**
 * POST /organizations/:organizationId/scopes
 * Crée un nouveau scope d'organisation
 */
router.post('/:organizationId/scopes', validateZod({ body: createOrganizationScopeSchema }), async (c) => {
  try {
    const organizationId = c.req.param('organizationId');
    if (!organizationId) {
      throw new AppError('ID d\'organisation manquant', ErrorCode.MISSING_REQUIRED_FIELD);
    }
    
    structuredLogger.info('Création d\'un scope', 'organizationScopes', {
      organizationId
    });
    
    const data = c.get('validatedBody');
    // Ajouter l'ID de l'organisation si ce n'est pas déjà fait
    if (!data.organizationId) {
      data.organizationId = organizationId;
    }
    
    const result = await organizationScopeService.createOrganizationScope(data);
    
    return c.json(result, 201);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la création du scope', 'organizationScopes', {
      error: error.message
    });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

/**
 * PATCH /organizations/:organizationId/scopes/:scopeId
 * Met à jour un scope d'organisation
 */
router.patch('/:organizationId/scopes/:scopeId', validateZod({ body: updateOrganizationScopeSchema }), async (c) => {
  try {
    const organizationId = c.req.param('organizationId');
    const scopeId = c.req.param('scopeId');
    
    if (!organizationId || !scopeId) {
      throw new AppError('Paramètres manquants', ErrorCode.MISSING_REQUIRED_FIELD);
    }
    
    structuredLogger.info('Mise à jour d\'un scope', 'organizationScopes', {
      organizationId,
      scopeId
    });
    
    const data = c.get('validatedBody');
    
    const result = await organizationScopeService.updateOrganizationScope(organizationId, scopeId, data);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la mise à jour du scope', 'organizationScopes', {
      error: error.message
    });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

/**
 * DELETE /organizations/:organizationId/scopes/:scopeId
 * Supprime un scope d'organisation
 */
router.delete('/:organizationId/scopes/:scopeId', async (c) => {
  try {
    const organizationId = c.req.param('organizationId');
    const scopeId = c.req.param('scopeId');
    
    if (!organizationId || !scopeId) {
      throw new AppError('Paramètres manquants', ErrorCode.MISSING_REQUIRED_FIELD);
    }
    
    structuredLogger.info('Suppression d\'un scope', 'organizationScopes', {
      organizationId,
      scopeId
    });
    
    const result = await organizationScopeService.deleteOrganizationScope(organizationId, scopeId);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la suppression du scope', 'organizationScopes', {
      error: error.message
    });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

export default router; 
