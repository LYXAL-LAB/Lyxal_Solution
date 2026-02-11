import { Hono } from 'hono';
import { structuredLogger as logger } from '../core/logger/structuredLogger';
import * as usersService from '../logic/usersService';
import {
  validateCreateUser,
  validateUpdateUser,
  validateUpdatePassword,
  validateVerifyPassword,
  validateUpdateSuspension,
  validateAssignRoles,
  validateUpdateCustomData,
  validateLinkSocialIdentity,
  validateAddPersonalAccessToken,
  validateUpdatePersonalAccessToken,
  validatePagination,
  validateCreateMfaVerification
} from '../validators/usersValidation';

const router = new Hono();

/**
 * GET /users/:id
 * Récupère les informations d'un utilisateur par son ID
 */
router.get('/:id', async (c) => {
  try {
    const userId = c.req.param('id');
    logger.info(`Récupération des informations de l'utilisateur ${userId}`, 'users');
    
    const result = await usersService.getUserById(userId);
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération de l'utilisateur: ${error.message}`, 'users');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * DELETE /users/:id
 * Supprime un utilisateur par son ID
 */
router.delete('/:id', async (c) => {
  try {
    const userId = c.req.param('id');
    logger.info(`Suppression de l'utilisateur ${userId}`, 'users');
    
    const result = await usersService.deleteUser(userId);
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la suppression de l'utilisateur: ${error.message}`, 'users');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * PATCH /users/:id
 * Met à jour un utilisateur par son ID
 */
router.patch('/:id', validateUpdateUser(), async (c) => {
  try {
    const userId = c.req.param('id');
    const data = c.get('validatedBody');
    logger.info(`Mise à jour de l'utilisateur ${userId}`, 'users');
    
    const result = await usersService.updateUser(userId, data);
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la mise à jour de l'utilisateur: ${error.message}`, 'users');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * GET /users/:id/custom-data
 * Récupère les données personnalisées d'un utilisateur
 */
router.get('/:id/custom-data', async (c) => {
  try {
    const userId = c.req.param('id');
    logger.info(`Récupération des données personnalisées de l'utilisateur ${userId}`, 'users');
    
    const result = await usersService.getUserCustomData(userId);
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération des données personnalisées: ${error.message}`, 'users');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * PATCH /users/:id/custom-data
 * Met à jour les données personnalisées d'un utilisateur
 */
router.patch('/:id/custom-data', validateUpdateCustomData(), async (c) => {
  try {
    const userId = c.req.param('id');
    const data = c.get('validatedBody');
    logger.info(`Mise à jour des données personnalisées de l'utilisateur ${userId}`, 'users');
    
    const result = await usersService.updateUserCustomData(userId, data);
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la mise à jour des données personnalisées: ${error.message}`, 'users');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * PATCH /users/:id/profile
 * Met à jour le profil d'un utilisateur
 */
router.patch('/:id/profile', validateUpdateUser(), async (c) => {
  try {
    const userId = c.req.param('id');
    const data = c.get('validatedBody');
    logger.info(`Mise à jour du profil de l'utilisateur ${userId}`, 'users');
    
    const result = await usersService.updateUserProfile(userId, data);
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la mise à jour du profil: ${error.message}`, 'users');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * GET /users
 * Récupère tous les utilisateurs avec pagination
 */
router.get('/', validatePagination(), async (c) => {
  try {
    const { page, page_size } = c.get('validatedQuery');
    logger.info(`Récupération des utilisateurs (page ${page}, page_size ${page_size})`, 'users');
    
    const result = await usersService.getUsers(page, page_size);
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération des utilisateurs: ${error.message}`, 'users');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * POST /users
 * Crée un nouvel utilisateur
 */
router.post('/', validateCreateUser(), async (c) => {
  try {
    const data = c.get('validatedBody');
    logger.info(`Création d'un nouvel utilisateur`, 'users');
    
    const result = await usersService.createUser(data);
    return c.json(result, 201);
  } catch (error: any) {
    logger.error(`Erreur lors de la création de l'utilisateur: ${error.message}`, 'users');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * PATCH /users/:id/password
 * Met à jour le mot de passe d'un utilisateur
 */
router.patch('/:id/password', validateUpdatePassword(), async (c) => {
  try {
    const userId = c.req.param('id');
    const { password } = c.get('validatedBody');
    logger.info(`Mise à jour du mot de passe de l'utilisateur ${userId}`, 'users');
    
    const result = await usersService.updateUserPassword(userId, password);
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la mise à jour du mot de passe: ${error.message}`, 'users');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * POST /users/:id/password/verify
 * Vérifie le mot de passe d'un utilisateur
 */
router.post('/:id/password/verify', validateVerifyPassword(), async (c) => {
  try {
    const userId = c.req.param('id');
    const { password } = c.get('validatedBody');
    logger.info(`Vérification du mot de passe de l'utilisateur ${userId}`, 'users');
    
    const result = await usersService.verifyUserPassword(userId, password);
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la vérification du mot de passe: ${error.message}`, 'users');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * GET /users/:id/has-password
 * Vérifie si un utilisateur a un mot de passe
 */
router.get('/:id/has-password', async (c) => {
  try {
    const userId = c.req.param('id');
    logger.info(`Vérification si l'utilisateur ${userId} a un mot de passe`, 'users');
    
    const result = await usersService.checkUserHasPassword(userId);
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la vérification de l'existence du mot de passe: ${error.message}`, 'users');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * PATCH /users/:id/is-suspended
 * Met à jour le statut de suspension d'un utilisateur
 */
router.patch('/:id/is-suspended', validateUpdateSuspension(), async (c) => {
  try {
    const userId = c.req.param('id');
    const { isSuspended } = c.get('validatedBody');
    logger.info(`Mise à jour du statut de suspension de l'utilisateur ${userId} (${isSuspended ? 'suspendu' : 'actif'})`, 'users');
    
    const result = await usersService.updateUserSuspensionStatus(userId, isSuspended);
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la mise à jour du statut de suspension: ${error.message}`, 'users');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * GET /users/:id/roles
 * Récupère les rôles d'un utilisateur
 */
router.get('/:id/roles', async (c) => {
  try {
    const userId = c.req.param('id');
    logger.info(`Récupération des rôles de l'utilisateur ${userId}`, 'users');
    
    const result = await usersService.getUserRoles(userId);
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération des rôles: ${error.message}`, 'users');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * PATCH /users/:id/roles
 * Met à jour les rôles d'un utilisateur
 */
router.patch('/:id/roles', validateAssignRoles(), async (c) => {
  try {
    const userId = c.req.param('id');
    const { roleIds } = c.get('validatedBody');
    logger.info(`Mise à jour des rôles de l'utilisateur ${userId}`, 'users');
    
    const result = await usersService.updateUserRoles(userId, roleIds);
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la mise à jour des rôles: ${error.message}`, 'users');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * POST /users/:id/roles
 * Assigne des rôles à un utilisateur
 */
router.post('/:id/roles', validateAssignRoles(), async (c) => {
  try {
    const userId = c.req.param('id');
    const { roleIds } = c.get('validatedBody');
    logger.info(`Attribution de rôles à l'utilisateur ${userId}`, 'users');
    
    const result = await usersService.assignRolesToUser(userId, roleIds);
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de l'attribution des rôles: ${error.message}`, 'users');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * DELETE /users/:id/roles/:roleId
 * Supprime un rôle d'un utilisateur
 */
router.delete('/:id/roles/:roleId', async (c) => {
  try {
    const userId = c.req.param('id');
    const roleId = c.req.param('roleId');
    logger.info(`Suppression du rôle ${roleId} de l'utilisateur ${userId}`, 'users');
    
    const result = await usersService.removeRoleFromUser(userId, roleId);
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la suppression du rôle: ${error.message}`, 'users');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * PUT /users/:id/identities/:target
 * Met à jour l'identité sociale d'un utilisateur
 */
router.put('/:id/identities/:target', validateLinkSocialIdentity(), async (c) => {
  try {
    const userId = c.req.param('id');
    const target = c.req.param('target');
    const { provider, userId: socialUserId } = c.get('validatedBody');
    const result = await usersService.updateUserSocialIdentity(userId, target, provider, socialUserId);
    return c.json(result);
  } catch (error: any) {
    return c.json({ error: error.message }, 400);
  }
});

/**
 * DELETE /users/:id/identities/:target
 * Supprime l'identité sociale d'un utilisateur
 */
router.delete('/:id/identities/:target', async (c) => {
  try {
    const userId = c.req.param('id');
    const target = c.req.param('target');
    const result = await usersService.deleteSocialIdentityFromUser(userId, target);
    return c.json(result);
  } catch (error: any) {
    return c.json({ error: error.message }, 400);
  }
});

/**
 * POST /users/:id/identities
 * Lie une identité sociale à un utilisateur
 */
router.post('/:id/identities', validateLinkSocialIdentity(), async (c) => {
  try {
    const userId = c.req.param('id');
    const { provider, userId: socialUserId } = c.get('validatedBody');
    const result = await usersService.linkSocialIdentityToUser(userId, provider, socialUserId);
    return c.json(result);
  } catch (error: any) {
    return c.json({ error: error.message }, 400);
  }
});

/**
 * GET /users/:id/organizations
 * Récupère les organisations d'un utilisateur
 */
router.get('/:id/organizations', async (c) => {
  try {
    const userId = c.req.param('id');
    const result = await usersService.getUserOrganizations(userId);
    return c.json(result);
  } catch (error: any) {
    return c.json({ error: error.message }, 400);
  }
});

/**
 * GET /users/:id/mfa-verifications
 * Récupère les vérifications MFA d'un utilisateur
 */
router.get('/:id/mfa-verifications', async (c) => {
  try {
    const userId = c.req.param('id');
    const result = await usersService.getUserMfaVerifications(userId);
    return c.json(result);
  } catch (error: any) {
    return c.json({ error: error.message }, 400);
  }
});

/**
 * POST /users/:id/mfa-verifications
 * Crée une vérification MFA pour un utilisateur
 */
router.post('/:id/mfa-verifications', validateCreateMfaVerification(), async (c) => {
  try {
    const userId = c.req.param('id');
    const body = await c.req.json();
    const result = await usersService.createMfaVerificationForUser(userId, body);
    return c.json(result);
  } catch (error: any) {
    return c.json({ error: error.message }, 400);
  }
});

/**
 * DELETE /users/:id/mfa-verifications/:verificationId
 * Supprime une vérification MFA pour un utilisateur
 */
router.delete('/:id/mfa-verifications/:verificationId', async (c) => {
  try {
    const userId = c.req.param('id');
    const verificationId = c.req.param('verificationId');
    const result = await usersService.deleteMfaVerificationForUser(userId, verificationId);
    return c.json(result);
  } catch (error: any) {
    return c.json({ error: error.message }, 400);
  }
});

/**
 * GET /users/:id/personal-access-tokens
 * Récupère les tokens d'accès personnels d'un utilisateur
 */
router.get('/:id/personal-access-tokens', async (c) => {
  try {
    const userId = c.req.param('id');
    const result = await usersService.getPersonalAccessTokens(userId);
    return c.json(result);
  } catch (error: any) {
    return c.json({ error: error.message }, 400);
  }
});

/**
 * POST /users/:id/personal-access-tokens
 * Ajoute un token d'accès personnel à un utilisateur
 */
router.post('/:id/personal-access-tokens', validateAddPersonalAccessToken(), async (c) => {
  try {
    const userId = c.req.param('id');
    const data = c.get('validatedBody');
    const result = await usersService.addPersonalAccessToken(userId, data);
    return c.json(result);
  } catch (error: any) {
    return c.json({ error: error.message }, 400);
  }
});

/**
 * DELETE /users/:id/personal-access-tokens/:tokenId
 * Supprime un token d'accès personnel d'un utilisateur
 */
router.delete('/:id/personal-access-tokens/:tokenId', async (c) => {
  try {
    const userId = c.req.param('id');
    const tokenId = c.req.param('tokenId');
    const result = await usersService.deletePersonalAccessToken(userId, tokenId);
    return c.json(result);
  } catch (error: any) {
    return c.json({ error: error.message }, 400);
  }
});

/**
 * PATCH /users/:id/personal-access-tokens/:tokenId
 * Met à jour un token d'accès personnel
 */
router.patch('/:id/personal-access-tokens/:tokenId', validateUpdatePersonalAccessToken(), async (c) => {
  try {
    const userId = c.req.param('id');
    const tokenId = c.req.param('tokenId');
    const data = c.get('validatedBody');
    const result = await usersService.updatePersonalAccessToken(userId, tokenId, data);
    return c.json(result);
  } catch (error: any) {
    return c.json({ error: error.message }, 400);
  }
});

/**
 * PATCH /users/:id/social-identities/:target
 * Met à jour l'identité sociale d'un utilisateur
 */
router.patch('/:id/social-identities/:target', validateLinkSocialIdentity(), async (c) => {
  try {
    const userId = c.req.param('id');
    const target = c.req.param('target');
    const { provider, userId: socialUserId } = c.get('validatedBody');
    const result = await usersService.updateUserSocialIdentity(userId, target, provider, socialUserId);
    return c.json(result);
  } catch (error: any) {
    return c.json({ error: error.message }, 400);
  }
});

/**
 * POST /users/:id/social-identities
 * Lie une identité sociale à un utilisateur
 */
router.post('/:id/social-identities', validateLinkSocialIdentity(), async (c) => {
  try {
    const userId = c.req.param('id');
    const { provider, userId: socialUserId } = c.get('validatedBody');
    const result = await usersService.linkSocialIdentityToUser(userId, provider, socialUserId);
    return c.json(result);
  } catch (error: any) {
    return c.json({ error: error.message }, 400);
  }
});

export default router; 
