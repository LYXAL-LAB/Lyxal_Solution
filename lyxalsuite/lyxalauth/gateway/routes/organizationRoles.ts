import { Hono } from 'hono';
import { structuredLogger } from '../core/logger/structuredLogger';
import * as organizationRoleService from '../logic/organizationRoleService';
import { validateZod } from '../validators/validateZod';
import {
  createOrganizationRoleSchema,
  updateOrganizationRoleSchema,
  assignOrganizationScopesSchema,
  assignResourceScopesSchema,
  paginationSchema
} from '../validators/schemas/organizationRoleSchemas';
import {
  validateCreateOrganizationRole,
  validateUpdateOrganizationRole,
  validateAssignOrganizationScopes,
  validateAssignResourceScopes,
  validatePagination
} from '../validators/organizationRoleValidation';
import { authRequired } from '../middleware/authMiddleware';
import { rateLimiter } from '../middleware/rateLimiter';
import { AppError, ErrorCode } from '../core/errors/AppError';

const router = new Hono();

// Appliquer le middleware d'authentification à toutes les routes
router.use('*', authRequired);

// Appliquer le middleware de limitation de taux pour prévenir les abus
router.use('*', rateLimiter({ windowMs: 15 * 60 * 1000, maxRequests: 100 }));

/**
 * GET /organizations/:organizationId/roles
 * Récupère tous les rôles d'une organisation
 */
router.get('/:organizationId/roles', async (c) => {
  try {
    const organizationId = c.req.param('organizationId');
    if (!organizationId) {
      throw new AppError('ID d\'organisation manquant', ErrorCode.MISSING_REQUIRED_FIELD);
    }
    
    structuredLogger.info('Récupération des rôles', 'organizationRoles', {
      organizationId
    });
    
    // Extraction et validation des paramètres de requête
    const page = c.req.query('page') ? parseInt(c.req.query('page') || '1', 10) : 1;
    const pageSize = c.req.query('page_size') ? parseInt(c.req.query('page_size') || '20', 10) : 20;
    
    const pagination = validatePagination({ page, pageSize });
    const result = await organizationRoleService.getOrganizationRoles(
      organizationId,
      pagination.page,
      pagination.pageSize
    );
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la récupération des rôles', 'organizationRoles', {
      error: error.message
    });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

/**
 * GET /organizations/:organizationId/roles/:roleId
 * Récupère un rôle spécifique d'une organisation
 */
router.get('/:organizationId/roles/:roleId', async (c) => {
  try {
    const organizationId = c.req.param('organizationId');
    const roleId = c.req.param('roleId');
    
    if (!organizationId || !roleId) {
      throw new AppError('Paramètres manquants', ErrorCode.MISSING_REQUIRED_FIELD);
    }
    
    structuredLogger.info('Récupération d\'un rôle spécifique', 'organizationRoles', {
      organizationId,
      roleId
    });
    
    const result = await organizationRoleService.getOrganizationRole(organizationId, roleId);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la récupération du rôle', 'organizationRoles', {
      error: error.message
    });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

/**
 * POST /organizations/:organizationId/roles
 * Crée un nouveau rôle d'organisation
 */
router.post('/:organizationId/roles', validateZod({ body: createOrganizationRoleSchema }), async (c) => {
  try {
    const organizationId = c.req.param('organizationId');
    if (!organizationId) {
      throw new AppError('ID d\'organisation manquant', ErrorCode.MISSING_REQUIRED_FIELD);
    }
    
    structuredLogger.info('Création d\'un rôle', 'organizationRoles', {
      organizationId
    });
    
    const data = c.get('validatedBody');
    // Ajouter l'ID de l'organisation si ce n'est pas déjà fait
    if (!data.organizationId) {
      data.organizationId = organizationId;
    }
    
    const result = await organizationRoleService.createOrganizationRole(data);
    
    return c.json(result, 201);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la création du rôle', 'organizationRoles', {
      error: error.message
    });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

/**
 * PATCH /organizations/:organizationId/roles/:roleId
 * Met à jour un rôle d'organisation
 */
router.patch('/:organizationId/roles/:roleId', validateZod({ body: updateOrganizationRoleSchema }), async (c) => {
  try {
    const organizationId = c.req.param('organizationId');
    const roleId = c.req.param('roleId');
    
    if (!organizationId || !roleId) {
      throw new AppError('Paramètres manquants', ErrorCode.MISSING_REQUIRED_FIELD);
    }
    
    structuredLogger.info('Mise à jour d\'un rôle', 'organizationRoles', {
      organizationId,
      roleId
    });
    
    const data = c.get('validatedBody');
    
    const result = await organizationRoleService.updateOrganizationRole(organizationId, roleId, data);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la mise à jour du rôle', 'organizationRoles', {
      error: error.message
    });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

/**
 * DELETE /organizations/:organizationId/roles/:roleId
 * Supprime un rôle d'organisation
 */
router.delete('/:organizationId/roles/:roleId', async (c) => {
  try {
    const organizationId = c.req.param('organizationId');
    const roleId = c.req.param('roleId');
    
    if (!organizationId || !roleId) {
      throw new AppError('Paramètres manquants', ErrorCode.MISSING_REQUIRED_FIELD);
    }
    
    structuredLogger.info('Suppression d\'un rôle', 'organizationRoles', {
      organizationId,
      roleId
    });
    
    const result = await organizationRoleService.deleteOrganizationRole(organizationId, roleId);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la suppression du rôle', 'organizationRoles', {
      error: error.message
    });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

/**
 * GET /organizations/:organizationId/roles/:roleId/scopes
 * Récupère les scopes d'un rôle d'organisation
 */
router.get('/:organizationId/roles/:roleId/scopes', async (c) => {
  try {
    const organizationId = c.req.param('organizationId');
    const roleId = c.req.param('roleId');
    
    if (!organizationId || !roleId) {
      throw new AppError('Paramètres manquants', ErrorCode.MISSING_REQUIRED_FIELD);
    }
    
    structuredLogger.info('Récupération des scopes d\'un rôle', 'organizationRoles', {
      organizationId,
      roleId
    });
    
    const result = await organizationRoleService.getOrganizationRoleScopes(organizationId, roleId);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la récupération des scopes du rôle', 'organizationRoles', {
      error: error.message
    });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

/**
 * PUT /organizations/:organizationId/roles/:roleId/scopes
 * Remplace les scopes d'un rôle d'organisation
 */
router.put('/:organizationId/roles/:roleId/scopes', validateZod({ body: assignOrganizationScopesSchema }), async (c) => {
  try {
    const organizationId = c.req.param('organizationId');
    const roleId = c.req.param('roleId');
    
    if (!organizationId || !roleId) {
      throw new AppError('Paramètres manquants', ErrorCode.MISSING_REQUIRED_FIELD);
    }
    
    structuredLogger.info('Remplacement des scopes d\'un rôle', 'organizationRoles', {
      organizationId,
      roleId
    });
    
    const data = c.get('validatedBody');
    
    const result = await organizationRoleService.assignOrganizationRoleScopes(organizationId, roleId, data);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors du remplacement des scopes du rôle', 'organizationRoles', {
      error: error.message
    });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

/**
 * POST /organizations/:organizationId/roles/:roleId/scopes
 * Ajoute des scopes à un rôle d'organisation
 */
router.post('/:organizationId/roles/:roleId/scopes', validateZod({ body: assignOrganizationScopesSchema }), async (c) => {
  try {
    const organizationId = c.req.param('organizationId');
    const roleId = c.req.param('roleId');
    
    if (!organizationId || !roleId) {
      throw new AppError('Paramètres manquants', ErrorCode.MISSING_REQUIRED_FIELD);
    }
    
    structuredLogger.info('Ajout de scopes à un rôle', 'organizationRoles', {
      organizationId,
      roleId
    });
    
    const data = c.get('validatedBody');
    
    const result = await organizationRoleService.assignOrganizationRoleScopes(organizationId, roleId, data);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de l\'ajout de scopes au rôle', 'organizationRoles', {
      error: error.message
    });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

/**
 * DELETE /organizations/:organizationId/roles/:roleId/scopes/:scopeId
 * Supprime un scope d'un rôle d'organisation
 */
router.delete('/:organizationId/roles/:roleId/scopes/:scopeId', async (c) => {
  try {
    const organizationId = c.req.param('organizationId');
    const roleId = c.req.param('roleId');
    const scopeId = c.req.param('scopeId');
    
    if (!organizationId || !roleId || !scopeId) {
      throw new AppError('Paramètres manquants', ErrorCode.MISSING_REQUIRED_FIELD);
    }
    
    structuredLogger.info('Suppression d\'un scope d\'un rôle', 'organizationRoles', {
      organizationId,
      roleId,
      scopeId
    });
    
    const result = await organizationRoleService.removeOrganizationRoleScope(organizationId, roleId, scopeId);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la suppression du scope du rôle', 'organizationRoles', {
      error: error.message
    });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

/**
 * GET /organizations/:organizationId/roles/:roleId/resource-scopes
 * Récupère les scopes de ressource d'un rôle d'organisation
 */
router.get('/:organizationId/roles/:roleId/resource-scopes', async (c) => {
  try {
    const organizationId = c.req.param('organizationId');
    const roleId = c.req.param('roleId');
    
    if (!organizationId || !roleId) {
      throw new AppError('Paramètres manquants', ErrorCode.MISSING_REQUIRED_FIELD);
    }
    
    structuredLogger.info('Récupération des scopes de ressource d\'un rôle', 'organizationRoles', {
      organizationId,
      roleId
    });
    
    const result = await organizationRoleService.getOrganizationRoleResourceScopes(organizationId, roleId);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la récupération des scopes de ressource du rôle', 'organizationRoles', {
      error: error.message
    });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

/**
 * PUT /organizations/:organizationId/roles/:roleId/resource-scopes
 * Remplace les scopes de ressource d'un rôle d'organisation
 */
router.put('/:organizationId/roles/:roleId/resource-scopes', validateZod({ body: assignResourceScopesSchema }), async (c) => {
  try {
    const organizationId = c.req.param('organizationId');
    const roleId = c.req.param('roleId');
    
    if (!organizationId || !roleId) {
      throw new AppError('Paramètres manquants', ErrorCode.MISSING_REQUIRED_FIELD);
    }
    
    structuredLogger.info('Remplacement des scopes de ressource d\'un rôle', 'organizationRoles', {
      organizationId,
      roleId
    });
    
    const data = c.get('validatedBody');
    
    const result = await organizationRoleService.assignOrganizationRoleResourceScopes(organizationId, roleId, data);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors du remplacement des scopes de ressource du rôle', 'organizationRoles', {
      error: error.message
    });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

/**
 * POST /organizations/:organizationId/roles/:roleId/resource-scopes
 * Ajoute des scopes de ressource à un rôle d'organisation
 */
router.post('/:organizationId/roles/:roleId/resource-scopes', validateZod({ body: assignResourceScopesSchema }), async (c) => {
  try {
    const organizationId = c.req.param('organizationId');
    const roleId = c.req.param('roleId');
    
    if (!organizationId || !roleId) {
      throw new AppError('Paramètres manquants', ErrorCode.MISSING_REQUIRED_FIELD);
    }
    
    structuredLogger.info('Ajout de scopes de ressource à un rôle', 'organizationRoles', {
      organizationId,
      roleId
    });
    
    const data = c.get('validatedBody');
    
    const result = await organizationRoleService.assignOrganizationRoleResourceScopes(organizationId, roleId, data);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de l\'ajout de scopes de ressource au rôle', 'organizationRoles', {
      error: error.message
    });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

/**
 * DELETE /organizations/:organizationId/roles/:roleId/resource-scopes/:resourceId/:scopeId
 * Supprime un scope de ressource d'un rôle d'organisation
 */
router.delete('/:organizationId/roles/:roleId/resource-scopes/:resourceId/:scopeId', async (c) => {
  try {
    const organizationId = c.req.param('organizationId');
    const roleId = c.req.param('roleId');
    const resourceId = c.req.param('resourceId');
    const scopeId = c.req.param('scopeId');
    
    if (!organizationId || !roleId || !resourceId || !scopeId) {
      throw new AppError('Paramètres manquants', ErrorCode.MISSING_REQUIRED_FIELD);
    }
    
    structuredLogger.info('Suppression d\'un scope de ressource d\'un rôle', 'organizationRoles', {
      organizationId,
      roleId,
      resourceId,
      scopeId
    });
    
    const result = await organizationRoleService.removeOrganizationRoleResourceScope(
      organizationId,
      roleId,
      resourceId,
      scopeId
    );
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la suppression du scope de ressource du rôle', 'organizationRoles', {
      error: error.message
    });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

export default router; 
