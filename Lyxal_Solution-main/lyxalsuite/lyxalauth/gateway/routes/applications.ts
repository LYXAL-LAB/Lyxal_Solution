import { Hono } from 'hono';
import { structuredLogger as logger } from '../core/logger/structuredLogger';
import * as applicationService from '../logic/applicationService';
import {
  createApplicationMiddleware,
  updateApplicationMiddleware,
  updateAppCustomDataMiddleware,
  assignApiResourceRolesMiddleware,
  addCustomDomainMiddleware,
  addApplicationSecretMiddleware,
  updateApplicationSecretMiddleware,
  assignUserConsentScopesMiddleware,
  updateAppSignInExperienceMiddleware,
  grantOrganizationAccessMiddleware
} from '../middleware/applicationMiddleware';
import {
  validateCreateApplication,
  validateUpdateApplication,
  validateUpdateAppCustomData,
  validateAssignApiResourceRoles,
  validateAddCustomDomain,
  validateAddApplicationSecret,
  validateUpdateApplicationSecret,
  validateAssignUserConsentScopes,
  validateUpdateAppSignInExperience,
  validateGrantOrganizationAccess
} from '../validators/applicationValidation';
import {
  createApplicationSchema,
  updateApplicationSchema,
  updateAppCustomDataSchema,
  assignApiResourceRolesSchema,
  addCustomDomainSchema,
  addApplicationSecretSchema,
  updateApplicationSecretSchema,
  assignUserConsentScopesSchema,
  updateAppSignInExperienceSchema,
  grantOrganizationAccessSchema
} from '../validators/schemas';
import {
  CreateApplicationData,
  UpdateApplicationData,
  UpdateAppCustomDataData,
  AssignApiResourceRolesData,
  AddCustomDomainData,
  AddApplicationSecretData,
  UpdateApplicationSecretData,
  AssignUserConsentScopesData,
  UpdateAppSignInExperienceData,
  GrantOrganizationAccessData
} from '../validators/schemas/applicationSchemas';

// Déclaration d'augmentation pour ContextVariableMap
declare module 'hono' {
  interface ContextVariableMap {
    validatedData: any;
  }
}

const router = new Hono();

/**
 * GET /applications
 * Récupère toutes les applications
 */
router.get('/', async (c) => {
  try {
    logger.info('Récupération de toutes les applications', 'applications');
    const result = await applicationService.getApplications();
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération des applications: ${error.message}`, 'applications');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * POST /applications
 * Crée une nouvelle application
 */
router.post('/', createApplicationMiddleware, async (c) => {
  try {
    logger.info('Création d\'une nouvelle application', 'applications');
    const data = c.get('validatedData') as CreateApplicationData;
    const result = await applicationService.createApplication(data);
    return c.json(result, 201);
  } catch (error: any) {
    logger.error(`Erreur lors de la création d'une application: ${error.message}`, 'applications');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * GET /applications/:id
 * Récupère une application par son ID
 */
router.get('/:id', async (c) => {
  try {
    const appId = c.req.param('id');
    logger.info(`Récupération de l'application ${appId}`, 'applications');
    const result = await applicationService.getApplicationById(appId);
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération de l'application: ${error.message}`, 'applications');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * DELETE /applications/:id
 * Supprime une application
 */
router.delete('/:id', async (c) => {
  try {
    const appId = c.req.param('id');
    logger.info(`Suppression de l'application ${appId}`, 'applications');
    const result = await applicationService.deleteApplication(appId);
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la suppression de l'application: ${error.message}`, 'applications');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * PATCH /applications/:id
 * Met à jour une application
 */
router.patch('/:id', updateApplicationMiddleware, async (c) => {
  try {
    const appId = c.req.param('id');
    logger.info(`Mise à jour de l'application ${appId}`, 'applications');
    const data = c.get('validatedData') as UpdateApplicationData;
    const result = await applicationService.updateApplication(appId, data);
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la mise à jour de l'application: ${error.message}`, 'applications');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * PATCH /applications/:id/custom-data
 * Met à jour les données personnalisées d'une application
 */
router.patch('/:id/custom-data', updateAppCustomDataMiddleware, async (c) => {
  try {
    const appId = c.req.param('id');
    logger.info(`Mise à jour des données personnalisées de l'application ${appId}`, 'applications');
    const data = c.get('validatedData') as UpdateAppCustomDataData;
    const result = await applicationService.updateApplicationCustomData(appId, data.customData);
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la mise à jour des données personnalisées: ${error.message}`, 'applications');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * GET /applications/:id/api-resources/roles
 * Récupère les rôles de ressources API d'une application
 */
router.get('/:id/api-resources/roles', async (c) => {
  try {
    const appId = c.req.param('id');
    logger.info(`Récupération des rôles de ressources API pour l'application ${appId}`, 'applications');
    const result = await applicationService.getApplicationApiResourceRoles(appId);
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération des rôles de ressources API: ${error.message}`, 'applications');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * PUT /applications/:id/api-resources/roles
 * Met à jour les rôles de ressources API pour une application
 */
router.put('/:id/api-resources/roles', assignApiResourceRolesMiddleware, async (c) => {
  try {
    const appId = c.req.param('id');
    logger.info(`Mise à jour des rôles de ressources API pour l'application ${appId}`, 'applications');
    const data = c.get('validatedData') as AssignApiResourceRolesData;
    // Convertir au format attendu par le service
    const resources = data.resourceIds.map((resourceId: string) => ({
      id: resourceId,
      roles: data.roleIds
    }));
    const result = await applicationService.updateApiResourceRoles(appId, resources);
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la mise à jour des rôles de ressources API: ${error.message}`, 'applications');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * POST /applications/:id/api-resources/roles
 * Attribue des rôles de ressources API à une application
 */
router.post('/:id/api-resources/roles', assignApiResourceRolesMiddleware, async (c) => {
  try {
    const appId = c.req.param('id');
    logger.info(`Attribution de rôles de ressources API à l'application ${appId}`, 'applications');
    const data = c.get('validatedData') as AssignApiResourceRolesData;
    // Convertir au format attendu par le service
    const resources = data.resourceIds.map((resourceId: string) => ({
      id: resourceId,
      roles: data.roleIds
    }));
    const result = await applicationService.assignApiResourceRoles(appId, resources);
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de l'attribution des rôles de ressources API: ${error.message}`, 'applications');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * DELETE /applications/:id/api-resources/:resourceId/roles/:roleId
 * Supprime un rôle de ressource API d'une application
 */
router.delete('/:id/api-resources/:resourceId/roles/:roleId', async (c) => {
  try {
    const appId = c.req.param('id');
    const resourceId = c.req.param('resourceId');
    const roleId = c.req.param('roleId');
    logger.info(`Suppression du rôle ${roleId} de la ressource ${resourceId} pour l'application ${appId}`, 'applications');
    const result = await applicationService.removeApiResourceRole(appId, resourceId, roleId);
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la suppression du rôle de ressource API: ${error.message}`, 'applications');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * GET /applications/:id/custom-domains
 * Récupère les domaines personnalisés d'une application
 */
router.get('/:id/custom-domains', async (c) => {
  try {
    const appId = c.req.param('id');
    logger.info(`Récupération des domaines personnalisés pour l'application ${appId}`, 'applications');
    const result = await applicationService.getApplicationCustomDomains(appId);
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération des domaines personnalisés: ${error.message}`, 'applications');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * POST /applications/:id/custom-domains
 * Ajoute un domaine personnalisé à une application
 */
router.post('/:id/custom-domains', addCustomDomainMiddleware, async (c) => {
  try {
    const appId = c.req.param('id');
    logger.info(`Ajout d'un domaine personnalisé à l'application ${appId}`, 'applications');
    const data = c.get('validatedData') as AddCustomDomainData;
    const result = await applicationService.addCustomDomain(appId, data.domain);
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de l'ajout d'un domaine personnalisé: ${error.message}`, 'applications');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * DELETE /applications/:id/custom-domains/:domain
 * Supprime un domaine personnalisé d'une application
 */
router.delete('/:id/custom-domains/:domain', async (c) => {
  try {
    const appId = c.req.param('id');
    const domain = c.req.param('domain');
    logger.info(`Suppression du domaine personnalisé ${domain} de l'application ${appId}`, 'applications');
    const result = await applicationService.removeCustomDomain(appId, domain);
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la suppression du domaine personnalisé: ${error.message}`, 'applications');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * GET /applications/:id/organizations
 * Récupère les organisations d'une application
 */
router.get('/:id/organizations', async (c) => {
  try {
    const appId = c.req.param('id');
    logger.info(`Récupération des organisations pour l'application ${appId}`, 'applications');
    const result = await applicationService.getApplicationOrganizations(appId);
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération des organisations: ${error.message}`, 'applications');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * DELETE /applications/:id/secrets/legacy
 * Supprime un secret legacy d'une application
 */
router.delete('/:id/secrets/legacy', async (c) => {
  try {
    const appId = c.req.param('id');
    logger.info(`Suppression du secret legacy de l'application ${appId}`, 'applications');
    const result = await applicationService.deleteLegacySecret(appId);
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la suppression du secret legacy: ${error.message}`, 'applications');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * GET /applications/:id/secrets
 * Récupère les secrets d'une application
 */
router.get('/:id/secrets', async (c) => {
  try {
    const appId = c.req.param('id');
    logger.info(`Récupération des secrets pour l'application ${appId}`, 'applications');
    const result = await applicationService.getApplicationSecrets(appId);
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération des secrets: ${error.message}`, 'applications');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * POST /applications/:id/secrets
 * Ajoute un secret à une application
 */
router.post('/:id/secrets', addApplicationSecretMiddleware, async (c) => {
  try {
    const appId = c.req.param('id');
    logger.info(`Ajout d'un secret à l'application ${appId}`, 'applications');
    const data = c.get('validatedData') as AddApplicationSecretData;
    
    // Convertir expiresAt de string en number si présent
    const secretData = {
      name: data.name,
      expiresAt: data.expiresAt ? new Date(data.expiresAt).getTime() : undefined
    };
    
    const result = await applicationService.addApplicationSecret(appId, secretData);
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de l'ajout d'un secret: ${error.message}`, 'applications');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * DELETE /applications/:id/secrets/:secretId
 * Supprime un secret d'une application
 */
router.delete('/:id/secrets/:secretId', async (c) => {
  try {
    const appId = c.req.param('id');
    const secretId = c.req.param('secretId');
    logger.info(`Suppression du secret ${secretId} de l'application ${appId}`, 'applications');
    const result = await applicationService.deleteApplicationSecret(appId, secretId);
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la suppression du secret: ${error.message}`, 'applications');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * PATCH /applications/:id/secrets/:secretId
 * Met à jour un secret d'application
 */
router.patch('/:id/secrets/:secretId', updateApplicationSecretMiddleware, async (c) => {
  try {
    const appId = c.req.param('id');
    const secretId = c.req.param('secretId');
    logger.info(`Mise à jour du secret ${secretId} de l'application ${appId}`, 'applications');
    const data = c.get('validatedData') as UpdateApplicationSecretData;
    
    // Préparer les données pour l'API
    const secretData = {
      name: data.name || '',
      ...(data.isActive !== undefined && { isActive: data.isActive }),
      ...(data.expiresAt !== undefined && { expiresAt: new Date(data.expiresAt).getTime() })
    };
    
    const result = await applicationService.updateApplicationSecret(appId, secretId, secretData);
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la mise à jour du secret: ${error.message}`, 'applications');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * GET /applications/:id/user-consent-scopes
 * Liste tous les scopes de consentement utilisateur d'une application
 */
router.get('/:id/user-consent-scopes', async (c) => {
  try {
    const appId = c.req.param('id');
    logger.info(`Récupération des scopes de consentement utilisateur pour l'application ${appId}`, 'applications');
    const result = await applicationService.getUserConsentScopes(appId);
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération des scopes de consentement utilisateur: ${error.message}`, 'applications');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * POST /applications/:id/user-consent-scopes
 * Attribue des scopes de consentement utilisateur à une application
 */
router.post('/:id/user-consent-scopes', assignUserConsentScopesMiddleware, async (c) => {
  try {
    const appId = c.req.param('id');
    logger.info(`Attribution de scopes de consentement utilisateur à l'application ${appId}`, 'applications');
    const data = c.get('validatedData') as AssignUserConsentScopesData;
    const result = await applicationService.assignUserConsentScopes(appId, data.scopes);
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de l'attribution des scopes de consentement: ${error.message}`, 'applications');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * DELETE /applications/:id/user-consent-scopes/:scopeId
 * Supprime un scope de consentement utilisateur d'une application
 */
router.delete('/:id/user-consent-scopes/:scopeId', async (c) => {
  try {
    const appId = c.req.param('id');
    const scopeId = c.req.param('scopeId');
    logger.info(`Suppression du scope de consentement utilisateur ${scopeId} de l'application ${appId}`, 'applications');
    const result = await applicationService.removeUserConsentScope(appId, scopeId);
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la suppression du scope de consentement utilisateur: ${error.message}`, 'applications');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * GET /applications/:id/sign-in-experience
 * Récupère l'expérience de connexion au niveau de l'application
 */
router.get('/:id/sign-in-experience', async (c) => {
  try {
    const appId = c.req.param('id');
    logger.info(`Récupération de l'expérience de connexion pour l'application ${appId}`, 'applications');
    const result = await applicationService.getAppSignInExperience(appId);
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération de l'expérience de connexion: ${error.message}`, 'applications');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * PATCH /applications/:id/sign-in-experience
 * Met à jour l'expérience de connexion d'une application
 */
router.patch('/:id/sign-in-experience', updateAppSignInExperienceMiddleware, async (c) => {
  try {
    const appId = c.req.param('id');
    logger.info(`Mise à jour de l'expérience de connexion pour l'application ${appId}`, 'applications');
    const data = c.get('validatedData') as UpdateAppSignInExperienceData;
    const result = await applicationService.updateAppSignInExperience(appId, data);
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la mise à jour de l'expérience de connexion: ${error.message}`, 'applications');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * GET /applications/:id/user-consented-organizations/:userId
 * Liste toutes les organisations consenties par un utilisateur pour une application
 */
router.get('/:id/user-consented-organizations/:userId', async (c) => {
  try {
    const appId = c.req.param('id');
    const userId = c.req.param('userId');
    logger.info(`Récupération des organisations consenties par l'utilisateur ${userId} pour l'application ${appId}`, 'applications');
    const result = await applicationService.getUserConsentedOrganizations(appId, userId);
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération des organisations consenties: ${error.message}`, 'applications');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * PUT /applications/:id/users/:userId/organization-access
 * Met à jour les organisations consenties par un utilisateur pour une application
 */
router.put('/:id/users/:userId/organization-access', grantOrganizationAccessMiddleware, async (c) => {
  try {
    const appId = c.req.param('id');
    const userId = c.req.param('userId');
    logger.info(`Mise à jour des organisations consenties par l'utilisateur ${userId} pour l'application ${appId}`, 'applications');
    const data = c.get('validatedData') as GrantOrganizationAccessData;
    const result = await applicationService.putUserOrganizationAccess(appId, userId, data.organizationIds);
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la mise à jour des accès aux organisations: ${error.message}`, 'applications');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * POST /applications/:id/users/:userId/organization-access
 * Ajoute des organisations consenties par un utilisateur pour une application
 */
router.post('/:id/users/:userId/organization-access', grantOrganizationAccessMiddleware, async (c) => {
  try {
    const appId = c.req.param('id');
    const userId = c.req.param('userId');
    logger.info(`Ajout d'organisations consenties par l'utilisateur ${userId} pour l'application ${appId}`, 'applications');
    const data = c.get('validatedData') as GrantOrganizationAccessData;
    const result = await applicationService.postUserOrganizationAccess(appId, userId, data.organizationIds);
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de l'ajout d'accès aux organisations: ${error.message}`, 'applications');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * DELETE /applications/:id/user-consented-organizations/:userId/:organizationId
 * Révoque l'accès d'un utilisateur à une organisation pour une application
 */
router.delete('/:id/user-consented-organizations/:userId/:organizationId', async (c) => {
  try {
    const appId = c.req.param('id');
    const userId = c.req.param('userId');
    const organizationId = c.req.param('organizationId');
    logger.info(`Révocation de l'accès de l'utilisateur ${userId} à l'organisation ${organizationId} pour l'application ${appId}`, 'applications');
    const result = await applicationService.revokeUserOrganizationAccess(appId, userId, organizationId);
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la révocation de l'accès à l'organisation: ${error.message}`, 'applications');
    return c.json({ error: error.message }, 400);
  }
});

export default router; 
