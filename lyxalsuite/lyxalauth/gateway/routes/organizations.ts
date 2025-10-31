import { Hono } from 'hono';
import * as organizationService from '../logic/organizationService';
import { validateZod } from '../validators/validateZod';
import {
  createOrganizationSchema,
  updateOrganizationSchema,
  organizationUserMembersSchema,
  assignRolesToUserSchema,
  organizationApplicationsSchema,
  assignRolesToApplicationSchema,
  jitEmailDomainsSchema,
  jitDefaultRolesSchema,
  jitSsoConnectorsSchema,
  paginationSchema
} from '../validators/schemas/organizationSchemas';
import { authRequired } from '../middleware/authMiddleware';
import { rateLimiter } from '../middleware/rateLimiter';
import { AppError, ErrorCode } from '../core/errors/AppError';
import { structuredLogger } from '../core/logger/structuredLogger';

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
 * GET /organizations
 * Récupère toutes les organisations
 */
router.get('/', async (c) => {
  try {
    structuredLogger.info('Récupération des organisations', 'organizations');
    
    // Extraction des paramètres de requête
    const page = c.req.query('page') ? parseInt(c.req.query('page') || '1', 10) : 1;
    const pageSize = c.req.query('page_size') ? parseInt(c.req.query('page_size') || '20', 10) : 20;
    
    // Validation avec le schéma
    const pagination = paginationSchema.parse({ page, pageSize });
    
    const result = await organizationService.getOrganizations(
      pagination.page,
      pagination.pageSize
    );
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la récupération des organisations', 'organizations', {
      error: error.message
    });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

/**
 * POST /organizations
 * Crée une nouvelle organisation
 */
router.post('/', validateZod({ body: createOrganizationSchema }), async (c) => {
  try {
    structuredLogger.info('Création d\'une organisation', 'organizations');
    
    const data = c.get('validatedBody');
    
    const result = await organizationService.createOrganization(data);
    
    return c.json(result, 201);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la création de l\'organisation', 'organizations', {
      error: error.message
    });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

/**
 * GET /organizations/:organizationId
 * Récupère une organisation spécifique
 */
router.get('/:id', async (c) => {
  try {
    const organizationId = c.req.param('id');
    if (!organizationId) {
      throw new AppError('ID d\'organisation manquant', ErrorCode.MISSING_REQUIRED_FIELD);
    }
    
    structuredLogger.info('Récupération d\'une organisation', 'organizations', {
      organizationId
    });
    
    const result = await organizationService.getOrganization(organizationId);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la récupération de l\'organisation', 'organizations', {
      error: error.message
    });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

/**
 * PATCH /organizations/:organizationId
 * Met à jour une organisation
 */
router.patch('/:id', validateZod({ body: updateOrganizationSchema }), async (c) => {
  try {
    const organizationId = c.req.param('id');
    structuredLogger.info('Mise à jour de l\'organisation', 'organizations', {
      organizationId
    });
    
    const data = c.get('validatedBody');
    
    const result = await organizationService.updateOrganization(organizationId, data);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la mise à jour de l\'organisation', 'organizations', {
      error: error.message
    });
    return c.json({ error: error.message }, 400 as 400);
  }
});

/**
 * DELETE /organizations/:organizationId
 * Supprime une organisation
 */
router.delete('/:id', async (c) => {
  try {
    const organizationId = c.req.param('id');
    structuredLogger.info('Suppression de l\'organisation', 'organizations', {
      organizationId
    });
    
    const result = await organizationService.deleteOrganization(organizationId);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la suppression de l\'organisation', 'organizations', {
      error: error.message
    });
    return c.json({ error: error.message }, 400 as 400);
  }
});

// Gestion des membres utilisateurs

/**
 * GET /organizations/:organizationId/users
 * Récupère les membres utilisateurs d'une organisation
 */
router.get('/:id/users', async (c) => {
  try {
    const organizationId = c.req.param('id');
    structuredLogger.info('Récupération des membres utilisateurs pour l\'organisation', 'organizations', {
      organizationId
    });
    
    // Extraction et validation des paramètres de requête
    const page = c.req.query('page') ? parseInt(c.req.query('page') || '1', 10) : 1;
    const pageSize = c.req.query('page_size') ? parseInt(c.req.query('page_size') || '20', 10) : 20;
    
    // Validation avec le schéma
    const pagination = paginationSchema.parse({ page, pageSize });
    const result = await organizationService.getOrganizationUserMembers(
      organizationId,
      pagination.page,
      pagination.pageSize
    );
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la récupération des membres utilisateurs', 'organizations', {
      error: error.message
    });
    return c.json({ error: error.message }, 400 as 400);
  }
});

/**
 * PUT /organizations/:organizationId/users
 * Remplace les membres utilisateurs d'une organisation
 */
router.put('/:id/users', validateZod({ body: organizationUserMembersSchema }), async (c) => {
  try {
    const organizationId = c.req.param('id');
    structuredLogger.info('Remplacement des membres utilisateurs pour l\'organisation', 'organizations', {
      organizationId
    });
    
    const data = c.get('validatedBody');
    
    const result = await organizationService.replaceOrganizationUserMembers(organizationId, data);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors du remplacement des membres utilisateurs', 'organizations', {
      error: error.message
    });
    return c.json({ error: error.message }, 400 as 400);
  }
});

/**
 * POST /organizations/:organizationId/users
 * Ajoute des membres utilisateurs à une organisation
 */
router.post('/:id/users', validateZod({ body: organizationUserMembersSchema }), async (c) => {
  try {
    const organizationId = c.req.param('id');
    structuredLogger.info('Ajout de membres utilisateurs à l\'organisation', 'organizations', {
      organizationId
    });
    
    const data = c.get('validatedBody');
    
    const result = await organizationService.addOrganizationUserMembers(organizationId, data);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de l\'ajout de membres utilisateurs', 'organizations', {
      error: error.message
    });
    return c.json({ error: error.message }, 400 as 400);
  }
});

/**
 * DELETE /organizations/:organizationId/users/:userId
 * Supprime un membre utilisateur d'une organisation
 */
router.delete('/:id/users/:userId', async (c) => {
  try {
    const organizationId = c.req.param('id');
    const userId = c.req.param('userId');
    structuredLogger.info('Suppression du membre utilisateur', 'organizations', {
      organizationId,
      userId
    });
    
    const result = await organizationService.removeOrganizationUserMember(organizationId, userId);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la suppression du membre utilisateur', 'organizations', {
      error: error.message
    });
    return c.json({ error: error.message }, 400 as 400);
  }
});

/**
 * GET /organizations/:organizationId/users/:userId/roles
 * Récupère les rôles d'un utilisateur dans une organisation
 */
router.get('/:id/users/:userId/roles', async (c) => {
  try {
    const organizationId = c.req.param('id');
    const userId = c.req.param('userId');
    structuredLogger.info('Récupération des rôles pour l\'utilisateur', 'organizations', {
      organizationId,
      userId
    });
    
    const result = await organizationService.getUserRolesInOrganization(organizationId, userId);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la récupération des rôles de l\'utilisateur', 'organizations', {
      error: error.message
    });
    return c.json({ error: error.message }, 400 as 400);
  }
});

/**
 * PUT /organizations/:organizationId/users/:userId/roles
 * Met à jour les rôles d'un utilisateur dans une organisation
 */
router.put('/:id/users/:userId/roles', validateZod({ body: assignRolesToUserSchema }), async (c) => {
  try {
    const organizationId = c.req.param('id');
    const userId = c.req.param('userId');
    structuredLogger.info('Mise à jour des rôles pour l\'utilisateur', 'organizations', {
      organizationId,
      userId
    });
    
    const data = c.get('validatedBody');
    
    const result = await organizationService.updateUserRolesInOrganization(organizationId, userId, data);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la mise à jour des rôles de l\'utilisateur', 'organizations', {
      error: error.message
    });
    return c.json({ error: error.message }, 400 as 400);
  }
});

/**
 * POST /organizations/:organizationId/users/:userId/roles
 * Attribue des rôles à un utilisateur dans une organisation
 */
router.post('/:id/users/:userId/roles', validateZod({ body: assignRolesToUserSchema }), async (c) => {
  try {
    const organizationId = c.req.param('id');
    const userId = c.req.param('userId');
    structuredLogger.info('Attribution de rôles à l\'utilisateur', 'organizations', {
      organizationId,
      userId
    });
    
    const data = c.get('validatedBody');
    
    const result = await organizationService.assignRolesToUser(organizationId, userId, data);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de l\'attribution de rôles à l\'utilisateur', 'organizations', {
      error: error.message
    });
    return c.json({ error: error.message }, 400 as 400);
  }
});

/**
 * DELETE /organizations/:organizationId/users/:userId/roles/:roleId
 * Supprime un rôle d'un utilisateur dans une organisation
 */
router.delete('/:id/users/:userId/roles/:roleId', async (c) => {
  try {
    const organizationId = c.req.param('id');
    const userId = c.req.param('userId');
    const roleId = c.req.param('roleId');
    structuredLogger.info('Suppression du rôle', 'organizations', {
      organizationId,
      userId,
      roleId
    });
    
    const result = await organizationService.removeRoleFromUser(organizationId, userId, roleId);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la suppression du rôle de l\'utilisateur', 'organizations', {
      error: error.message
    });
    return c.json({ error: error.message }, 400 as 400);
  }
});

/**
 * GET /organizations/:organizationId/users/:userId/scopes
 * Récupère les scopes pour un utilisateur dans une organisation
 */
router.get('/:id/users/:userId/scopes', async (c) => {
  try {
    const organizationId = c.req.param('id');
    const userId = c.req.param('userId');
    structuredLogger.info('Récupération des scopes pour l\'utilisateur', 'organizations', {
      organizationId,
      userId
    });
    
    const result = await organizationService.getUserScopesInOrganization(organizationId, userId);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la récupération des scopes de l\'utilisateur', 'organizations', {
      error: error.message
    });
    return c.json({ error: error.message }, 400 as 400);
  }
});

// Gestion des applications

/**
 * GET /organizations/:organizationId/applications
 * Récupère les applications d'une organisation
 */
router.get('/:id/applications', async (c) => {
  try {
    const organizationId = c.req.param('id');
    structuredLogger.info('Récupération des applications pour l\'organisation', 'organizations', {
      organizationId
    });
    
    // Extraction et validation des paramètres de requête
    const page = c.req.query('page') ? parseInt(c.req.query('page') || '1', 10) : 1;
    const pageSize = c.req.query('page_size') ? parseInt(c.req.query('page_size') || '20', 10) : 20;
    
    // Validation avec le schéma
    const pagination = paginationSchema.parse({ page, pageSize });
    const result = await organizationService.getOrganizationApplications(
      organizationId,
      pagination.page,
      pagination.pageSize
    );
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la récupération des applications', 'organizations', {
      error: error.message
    });
    return c.json({ error: error.message }, 400 as 400);
  }
});

/**
 * PUT /organizations/:organizationId/applications
 * Remplace les applications d'une organisation
 */
router.put('/:id/applications', validateZod({ body: organizationApplicationsSchema }), async (c) => {
  try {
    const organizationId = c.req.param('id');
    structuredLogger.info('Remplacement des applications pour l\'organisation', 'organizations', {
      organizationId
    });
    
    const data = c.get('validatedBody');
    
    const result = await organizationService.replaceOrganizationApplications(organizationId, data);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors du remplacement des applications', 'organizations', {
      error: error.message
    });
    return c.json({ error: error.message }, 400 as 400);
  }
});

/**
 * POST /organizations/:organizationId/applications
 * Ajoute des applications à une organisation
 */
router.post('/:id/applications', validateZod({ body: organizationApplicationsSchema }), async (c) => {
  try {
    const organizationId = c.req.param('id');
    structuredLogger.info('Ajout d\'applications à l\'organisation', 'organizations', {
      organizationId
    });
    
    const data = c.get('validatedBody');
    
    const result = await organizationService.addOrganizationApplication(organizationId, data);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de l\'ajout d\'applications', 'organizations', {
      error: error.message
    });
    return c.json({ error: error.message }, 400 as 400);
  }
});

/**
 * DELETE /organizations/:organizationId/applications/:applicationId
 * Supprime une application d'une organisation
 */
router.delete('/:id/applications/:applicationId', async (c) => {
  try {
    const organizationId = c.req.param('id');
    const applicationId = c.req.param('applicationId');
    structuredLogger.info('Suppression de l\'application', 'organizations', {
      organizationId,
      applicationId
    });
    
    const result = await organizationService.removeOrganizationApplication(organizationId, applicationId);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la suppression de l\'application', 'organizations', {
      error: error.message
    });
    return c.json({ error: error.message }, 400 as 400);
  }
});

/**
 * GET /organizations/:organizationId/applications/:applicationId/roles
 * Récupère les rôles d'une application dans une organisation
 */
router.get('/:id/applications/:applicationId/roles', async (c) => {
  try {
    const organizationId = c.req.param('id');
    const applicationId = c.req.param('applicationId');
    structuredLogger.info('Récupération des rôles pour l\'application', 'organizations', {
      organizationId,
      applicationId
    });
    
    const result = await organizationService.getOrganizationApplicationRoles(organizationId, applicationId);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la récupération des rôles de l\'application', 'organizations', {
      error: error.message
    });
    return c.json({ error: error.message }, 400 as 400);
  }
});

/**
 * PUT /organizations/:organizationId/applications/:applicationId/roles
 * Remplace les rôles d'une application dans une organisation
 */
router.put('/:id/applications/:applicationId/roles', validateZod({ body: assignRolesToApplicationSchema }), async (c) => {
  try {
    const organizationId = c.req.param('id');
    const applicationId = c.req.param('applicationId');
    structuredLogger.info('Remplacement des rôles pour l\'application', 'organizations', {
      organizationId,
      applicationId
    });
    
    const data = c.get('validatedBody');
    
    const result = await organizationService.replaceOrganizationApplicationRoles(organizationId, applicationId, data);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors du remplacement des rôles de l\'application', 'organizations', {
      error: error.message
    });
    return c.json({ error: error.message }, 400 as 400);
  }
});

/**
 * POST /organizations/:organizationId/applications/:applicationId/roles
 * Attribue des rôles à une application dans une organisation
 */
router.post('/:id/applications/:applicationId/roles', validateZod({ body: assignRolesToApplicationSchema }), async (c) => {
  try {
    const organizationId = c.req.param('id');
    const applicationId = c.req.param('applicationId');
    structuredLogger.info('Attribution de rôles à l\'application', 'organizations', {
      organizationId,
      applicationId
    });
    
    const data = c.get('validatedBody');
    
    const result = await organizationService.assignRolesToApplication(organizationId, applicationId, data);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de l\'attribution de rôles à l\'application', 'organizations', {
      error: error.message
    });
    return c.json({ error: error.message }, 400 as 400);
  }
});

/**
 * DELETE /organizations/:organizationId/applications/:applicationId/roles/:roleId
 * Supprime un rôle d'une application dans une organisation
 */
router.delete('/:id/applications/:applicationId/roles/:roleId', async (c) => {
  try {
    const organizationId = c.req.param('id');
    const applicationId = c.req.param('applicationId');
    const roleId = c.req.param('roleId');
    structuredLogger.info('Suppression du rôle', 'organizations', {
      organizationId,
      applicationId,
      roleId
    });
    
    const result = await organizationService.removeOrganizationApplicationRole(organizationId, applicationId, roleId);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la suppression du rôle de l\'application', 'organizations', {
      error: error.message
    });
    return c.json({ error: error.message }, 400 as 400);
  }
});

/**
 * Gestion des domaines email JIT (Just-In-Time)
 */

/**
 * GET /organizations/:organizationId/jit/email-domains
 * Récupère les domaines email JIT d'une organisation
 */
router.get('/:id/jit/email-domains', async (c) => {
  try {
    const organizationId = c.req.param('id');
    structuredLogger.info('Récupération des domaines email JIT pour l\'organisation', 'organizations', {
      organizationId
    });
    
    const result = await organizationService.getOrganizationJitEmailDomains(organizationId);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la récupération des domaines email JIT', 'organizations', {
      error: error.message
    });
    return c.json({ error: error.message }, 400 as 400);
  }
});

/**
 * PUT /organizations/:organizationId/jit/email-domains
 * Remplace les domaines email JIT d'une organisation
 */
router.put('/:id/jit/email-domains', validateZod({ body: jitEmailDomainsSchema }), async (c) => {
  try {
    const organizationId = c.req.param('id');
    structuredLogger.info('Remplacement des domaines email JIT pour l\'organisation', 'organizations', {
      organizationId
    });
    
    const data = c.get('validatedBody');
    
    const result = await organizationService.replaceOrganizationJitEmailDomains(organizationId, data);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors du remplacement des domaines email JIT', 'organizations', {
      error: error.message
    });
    return c.json({ error: error.message }, 400 as 400);
  }
});

/**
 * POST /organizations/:organizationId/jit/email-domains
 * Ajoute des domaines email JIT à une organisation
 */
router.post('/:id/jit/email-domains', validateZod({ body: jitEmailDomainsSchema }), async (c) => {
  try {
    const organizationId = c.req.param('id');
    structuredLogger.info('Ajout de domaines email JIT à l\'organisation', 'organizations', {
      organizationId
    });
    
    const data = c.get('validatedBody');
    
    const result = await organizationService.addOrganizationJitEmailDomain(organizationId, data);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de l\'ajout de domaines email JIT', 'organizations', {
      error: error.message
    });
    return c.json({ error: error.message }, 400 as 400);
  }
});

/**
 * DELETE /organizations/:organizationId/jit/email-domains/:domain
 * Supprime un domaine email JIT d'une organisation
 */
router.delete('/:id/jit/email-domains/:domain', async (c) => {
  try {
    const organizationId = c.req.param('id');
    const domain = c.req.param('domain');
    structuredLogger.info('Suppression du domaine email JIT', 'organizations', {
      organizationId,
      domain
    });
    
    const result = await organizationService.removeOrganizationJitEmailDomain(organizationId, domain);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la suppression du domaine email JIT', 'organizations', {
      error: error.message
    });
    return c.json({ error: error.message }, 400 as 400);
  }
});

/**
 * Gestion des rôles par défaut JIT (Just-In-Time)
 */

/**
 * GET /organizations/:organizationId/jit/default-roles
 * Récupère les rôles par défaut JIT d'une organisation
 */
router.get('/:id/jit/default-roles', async (c) => {
  try {
    const organizationId = c.req.param('id');
    structuredLogger.info('Récupération des rôles par défaut JIT pour l\'organisation', 'organizations', {
      organizationId
    });
    
    const result = await organizationService.getOrganizationJitDefaultRoles(organizationId);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la récupération des rôles par défaut JIT', 'organizations', {
      error: error.message
    });
    return c.json({ error: error.message }, 400 as 400);
  }
});

/**
 * PUT /organizations/:organizationId/jit/default-roles
 * Remplace les rôles par défaut JIT d'une organisation
 */
router.put('/:id/jit/default-roles', validateZod({ body: jitDefaultRolesSchema }), async (c) => {
  try {
    const organizationId = c.req.param('id');
    structuredLogger.info('Remplacement des rôles par défaut JIT pour l\'organisation', 'organizations', {
      organizationId
    });
    
    const data = c.get('validatedBody');
    
    const result = await organizationService.replaceOrganizationJitDefaultRoles(organizationId, data);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors du remplacement des rôles par défaut JIT', 'organizations', {
      error: error.message
    });
    return c.json({ error: error.message }, 400 as 400);
  }
});

/**
 * POST /organizations/:organizationId/jit/default-roles
 * Ajoute des rôles par défaut JIT à une organisation
 */
router.post('/:id/jit/default-roles', validateZod({ body: jitDefaultRolesSchema }), async (c) => {
  try {
    const organizationId = c.req.param('id');
    structuredLogger.info('Ajout de rôles par défaut JIT à l\'organisation', 'organizations', {
      organizationId
    });
    
    const data = c.get('validatedBody');
    
    const result = await organizationService.addOrganizationJitDefaultRoles(organizationId, data);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de l\'ajout de rôles par défaut JIT', 'organizations', {
      error: error.message
    });
    return c.json({ error: error.message }, 400 as 400);
  }
});

/**
 * DELETE /organizations/:organizationId/jit/default-roles/:roleId
 * Supprime un rôle par défaut JIT d'une organisation
 */
router.delete('/:id/jit/default-roles/:roleId', async (c) => {
  try {
    const organizationId = c.req.param('id');
    const roleId = c.req.param('roleId');
    structuredLogger.info('Suppression du rôle par défaut JIT', 'organizations', {
      organizationId,
      roleId
    });
    
    const result = await organizationService.removeOrganizationJitDefaultRole(organizationId, roleId);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la suppression du rôle par défaut JIT', 'organizations', {
      error: error.message
    });
    return c.json({ error: error.message }, 400 as 400);
  }
});

/**
 * Gestion des connecteurs SSO JIT (Just-In-Time)
 */

/**
 * GET /organizations/:organizationId/jit/sso-connectors
 * Récupère les connecteurs SSO JIT d'une organisation
 */
router.get('/:id/jit/sso-connectors', async (c) => {
  try {
    const organizationId = c.req.param('id');
    structuredLogger.info('Récupération des connecteurs SSO JIT pour l\'organisation', 'organizations', {
      organizationId
    });
    
    const result = await organizationService.getOrganizationJitSsoConnectors(organizationId);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la récupération des connecteurs SSO JIT', 'organizations', {
      error: error.message
    });
    return c.json({ error: error.message }, 400 as 400);
  }
});

/**
 * PUT /organizations/:organizationId/jit/sso-connectors
 * Remplace les connecteurs SSO JIT d'une organisation
 */
router.put('/:id/jit/sso-connectors', validateZod({ body: jitSsoConnectorsSchema }), async (c) => {
  try {
    const organizationId = c.req.param('id');
    structuredLogger.info('Remplacement des connecteurs SSO JIT pour l\'organisation', 'organizations', {
      organizationId
    });
    
    const data = c.get('validatedBody');
    
    const result = await organizationService.replaceOrganizationJitSsoConnectors(organizationId, data);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors du remplacement des connecteurs SSO JIT', 'organizations', {
      error: error.message
    });
    return c.json({ error: error.message }, 400 as 400);
  }
});

/**
 * POST /organizations/:organizationId/jit/sso-connectors
 * Ajoute des connecteurs SSO JIT à une organisation
 */
router.post('/:id/jit/sso-connectors', validateZod({ body: jitSsoConnectorsSchema }), async (c) => {
  try {
    const organizationId = c.req.param('id');
    structuredLogger.info('Ajout de connecteurs SSO JIT à l\'organisation', 'organizations', {
      organizationId
    });
    
    const data = c.get('validatedBody');
    
    const result = await organizationService.addOrganizationJitSsoConnectors(organizationId, data);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de l\'ajout de connecteurs SSO JIT', 'organizations', {
      error: error.message
    });
    return c.json({ error: error.message }, 400 as 400);
  }
});

/**
 * DELETE /organizations/:organizationId/jit/sso-connectors/:connectorId
 * Supprime un connecteur SSO JIT d'une organisation
 */
router.delete('/:id/jit/sso-connectors/:connectorId', async (c) => {
  try {
    const organizationId = c.req.param('id');
    const connectorId = c.req.param('connectorId');
    structuredLogger.info('Suppression du connecteur SSO JIT', 'organizations', {
      organizationId,
      connectorId
    });
    
    const result = await organizationService.removeOrganizationJitSsoConnector(organizationId, connectorId);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la suppression du connecteur SSO JIT', 'organizations', {
      error: error.message
    });
    return c.json({ error: error.message }, 400 as 400);
  }
});

export default router;
