import { Hono } from 'hono';
import { structuredLogger } from '../core/logger/structuredLogger';
import * as roleService from '../logic/roleService';
import { validateZod } from '../validators/validateZod';
import {
  createRoleSchema,
  updateRoleSchema,
  assignRoleToUsersSchema,
  assignRoleToApplicationsSchema,
  linkScopesToRoleSchema,
  paginationSchema
} from '../validators/schemas/roleSchemas';

const router = new Hono();

/**
 * GET /roles
 * Récupère tous les rôles
 */
router.get('/', async (c) => {
  try {
    structuredLogger.info('Récupération des rôles', 'roles');
    
    // Extraction et validation des paramètres de requête
    const page = c.req.query('page') ? parseInt(c.req.query('page') || '1', 10) : 1;
    const pageSize = c.req.query('page_size') ? parseInt(c.req.query('page_size') || '20', 10) : 20;
    
    const pagination = paginationSchema.parse({ page, pageSize });
    const result = await roleService.getRoles(
      pagination.page,
      pagination.pageSize
    );
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la récupération des rôles', 'roles', {
      error: error.message
    });
    return c.json({ error: error.message }, 400 as 400);
  }
});

/**
 * POST /roles
 * Crée un nouveau rôle
 */
router.post('/', validateZod({ body: createRoleSchema }), async (c) => {
  try {
    structuredLogger.info('Création d\'un rôle', 'roles');
    
    const data = c.get('validatedBody');
    
    const result = await roleService.createRole(data);
    
    return c.json(result, 201);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la création du rôle', 'roles', {
      error: error.message
    });
    return c.json({ error: error.message }, 400 as 400);
  }
});

/**
 * GET /roles/:roleId
 * Récupère un rôle spécifique
 */
router.get('/:id', async (c) => {
  try {
    const roleId = c.req.param('id');
    structuredLogger.info(`Récupération du rôle ${roleId}`, 'roles', {
      roleId
    });
    
    const result = await roleService.getRole(roleId);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la récupération du rôle', 'roles', {
      error: error.message
    });
    return c.json({ error: error.message }, 400 as 400);
  }
});

/**
 * DELETE /roles/:roleId
 * Supprime un rôle
 */
router.delete('/:id', async (c) => {
  try {
    const roleId = c.req.param('id');
    structuredLogger.info(`Suppression du rôle ${roleId}`, 'roles', {
      roleId
    });
    
    const result = await roleService.deleteRole(roleId);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la suppression du rôle', 'roles', {
      error: error.message
    });
    return c.json({ error: error.message }, 400 as 400);
  }
});

/**
 * PATCH /roles/:roleId
 * Met à jour un rôle
 */
router.patch('/:id', validateZod({ body: updateRoleSchema }), async (c) => {
  try {
    const roleId = c.req.param('id');
    structuredLogger.info(`Mise à jour du rôle ${roleId}`, 'roles', {
      roleId
    });
    
    const data = c.get('validatedBody');
    
    const result = await roleService.updateRole(roleId, data);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la mise à jour du rôle', 'roles', {
      error: error.message
    });
    return c.json({ error: error.message }, 400 as 400);
  }
});

/**
 * GET /roles/:roleId/users
 * Récupère les utilisateurs ayant un rôle spécifique
 */
router.get('/:id/users', async (c) => {
  try {
    const roleId = c.req.param('id');
    structuredLogger.info(`Récupération des utilisateurs pour le rôle ${roleId}`, 'roles', {
      roleId
    });
    
    // Extraction et validation des paramètres de requête
    const page = c.req.query('page') ? parseInt(c.req.query('page') || '1', 10) : 1;
    const pageSize = c.req.query('page_size') ? parseInt(c.req.query('page_size') || '20', 10) : 20;
    
    const pagination = paginationSchema.parse({ page, pageSize });
    const result = await roleService.getRoleUsers(
      roleId,
      pagination.page,
      pagination.pageSize
    );
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la récupération des utilisateurs du rôle', 'roles', {
      error: error.message
    });
    return c.json({ error: error.message }, 400 as 400);
  }
});

/**
 * POST /roles/:roleId/users
 * Assigne un rôle à des utilisateurs
 */
router.post('/:id/users', validateZod({ body: assignRoleToUsersSchema }), async (c) => {
  try {
    const roleId = c.req.param('id');
    structuredLogger.info(`Assignation du rôle ${roleId} à des utilisateurs`, 'roles', {
      roleId
    });
    
    const data = c.get('validatedBody');
    
    const result = await roleService.assignRoleToUsers(roleId, data);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de l\'assignation du rôle aux utilisateurs', 'roles', {
      error: error.message
    });
    return c.json({ error: error.message }, 400 as 400);
  }
});

/**
 * DELETE /roles/:roleId/users/:userId
 * Supprime un rôle d'un utilisateur
 */
router.delete('/:id/users/:userId', async (c) => {
  try {
    const roleId = c.req.param('id');
    const userId = c.req.param('userId');
    structuredLogger.info(`Suppression du rôle ${roleId} de l'utilisateur ${userId}`, 'roles', {
      roleId,
      userId
    });
    
    const result = await roleService.removeRoleFromUser(roleId, userId);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la suppression du rôle de l\'utilisateur', 'roles', {
      error: error.message
    });
    return c.json({ error: error.message }, 400 as 400);
  }
});

/**
 * GET /roles/:roleId/applications
 * Récupère les applications ayant un rôle spécifique
 */
router.get('/:id/applications', async (c) => {
  try {
    const roleId = c.req.param('id');
    structuredLogger.info(`Récupération des applications pour le rôle ${roleId}`, 'roles', {
      roleId
    });
    
    // Extraction et validation des paramètres de requête
    const page = c.req.query('page') ? parseInt(c.req.query('page') || '1', 10) : 1;
    const pageSize = c.req.query('page_size') ? parseInt(c.req.query('page_size') || '20', 10) : 20;
    
    const pagination = paginationSchema.parse({ page, pageSize });
    const result = await roleService.getRoleApplications(
      roleId,
      pagination.page,
      pagination.pageSize
    );
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la récupération des applications du rôle', 'roles', {
      error: error.message
    });
    return c.json({ error: error.message }, 400 as 400);
  }
});

/**
 * POST /roles/:roleId/applications
 * Assigne un rôle à des applications
 */
router.post('/:id/applications', validateZod({ body: assignRoleToApplicationsSchema }), async (c) => {
  try {
    const roleId = c.req.param('id');
    structuredLogger.info(`Assignation du rôle ${roleId} à des applications`, 'roles', {
      roleId
    });
    
    const data = c.get('validatedBody');
    
    const result = await roleService.assignRoleToApplications(roleId, data);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de l\'assignation du rôle aux applications', 'roles', {
      error: error.message
    });
    return c.json({ error: error.message }, 400 as 400);
  }
});

/**
 * DELETE /roles/:roleId/applications/:applicationId
 * Supprime un rôle d'une application
 */
router.delete('/:id/applications/:applicationId', async (c) => {
  try {
    const roleId = c.req.param('id');
    const applicationId = c.req.param('applicationId');
    structuredLogger.info(`Suppression du rôle ${roleId} de l'application ${applicationId}`, 'roles', {
      roleId,
      applicationId
    });
    
    const result = await roleService.removeRoleFromApplication(roleId, applicationId);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la suppression du rôle de l\'application', 'roles', {
      error: error.message
    });
    return c.json({ error: error.message }, 400 as 400);
  }
});

/**
 * GET /roles/:roleId/scopes
 * Récupère les scopes liés à un rôle spécifique
 */
router.get('/:id/scopes', async (c) => {
  try {
    const roleId = c.req.param('id');
    structuredLogger.info(`Récupération des scopes pour le rôle ${roleId}`, 'roles', {
      roleId
    });
    
    const result = await roleService.getRoleScopes(roleId);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la récupération des scopes du rôle', 'roles', {
      error: error.message
    });
    return c.json({ error: error.message }, 400 as 400);
  }
});

/**
 * POST /roles/:roleId/scopes
 * Lie des scopes à un rôle
 */
router.post('/:id/scopes', validateZod({ body: linkScopesToRoleSchema }), async (c) => {
  try {
    const roleId = c.req.param('id');
    structuredLogger.info(`Liaison de scopes au rôle ${roleId}`, 'roles', {
      roleId
    });
    
    const data = c.get('validatedBody');
    
    const result = await roleService.linkScopesToRole(roleId, data);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la liaison de scopes au rôle', 'roles', {
      error: error.message
    });
    return c.json({ error: error.message }, 400 as 400);
  }
});

/**
 * DELETE /roles/:roleId/scopes/:scopeId
 * Supprime un scope d'un rôle
 */
router.delete('/:id/scopes/:scopeId', async (c) => {
  try {
    const roleId = c.req.param('id');
    const scopeId = c.req.param('scopeId');
    structuredLogger.info(`Suppression du scope ${scopeId} du rôle ${roleId}`, 'roles', {
      roleId,
      scopeId
    });
    
    const result = await roleService.unlinkScopeFromRole(roleId, scopeId);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la suppression du scope du rôle', 'roles', {
      error: error.message
    });
    return c.json({ error: error.message }, 400 as 400);
  }
});

export default router; 
