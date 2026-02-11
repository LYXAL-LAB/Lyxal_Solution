/**
 * @file applicationMiddleware.ts
 * @description Middlewares pour les routes d'applications
 */

import { Context } from 'hono';
import { AppError, ErrorCode } from '../core/errors/AppError';
import { structuredLogger } from '../core/logger/structuredLogger';
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

const logger = structuredLogger;

/**
 * Middleware pour valider la création d'une application
 */
export async function createApplicationMiddleware(c: Context, next: () => Promise<void>) {
  try {
    const body = await c.req.json();
    const validatedData = validateCreateApplication(body);
    c.set('validatedData', validatedData);
    logger.info('Données de création d\'application validées', 'application-middleware', { applicationName: validatedData.name });
    await next();
  } catch (error) {
    logger.error('Validation échouée pour la création d\'application', 'application-middleware', { error });
    throw new AppError('Données de création d\'application invalides', ErrorCode.BAD_REQUEST, { error });
  }
}

/**
 * Middleware pour valider la mise à jour d'une application
 */
export async function updateApplicationMiddleware(c: Context, next: () => Promise<void>) {
  try {
    const body = await c.req.json();
    const validatedData = validateUpdateApplication(body);
    c.set('validatedData', validatedData);
    logger.info('Données de mise à jour d\'application validées', 'application-middleware', { applicationId: c.req.param('id') });
    await next();
  } catch (error) {
    logger.error('Validation échouée pour la mise à jour d\'application', 'application-middleware', { error });
    throw new AppError('Données de mise à jour d\'application invalides', ErrorCode.BAD_REQUEST, { error });
  }
}

/**
 * Middleware pour valider les données personnalisées d'une application
 */
export async function updateAppCustomDataMiddleware(c: Context, next: () => Promise<void>) {
  try {
    const body = await c.req.json();
    const validatedData = validateUpdateAppCustomData(body);
    c.set('validatedData', validatedData);
    logger.info('Données personnalisées d\'application validées', 'application-middleware', { applicationId: c.req.param('id') });
    await next();
  } catch (error) {
    logger.error('Validation échouée pour les données personnalisées', 'application-middleware', { error });
    throw new AppError('Données personnalisées invalides', ErrorCode.BAD_REQUEST, { error });
  }
}

/**
 * Middleware pour valider l'attribution de rôles de ressources API
 */
export async function assignApiResourceRolesMiddleware(c: Context, next: () => Promise<void>) {
  try {
    const body = await c.req.json();
    const validatedData = validateAssignApiResourceRoles(body);
    c.set('validatedData', validatedData);
    logger.info('Attribution de rôles de ressources validée', 'application-middleware', { applicationId: c.req.param('id') });
    await next();
  } catch (error) {
    logger.error('Validation échouée pour l\'attribution de rôles', 'application-middleware', { error });
    throw new AppError('Données d\'attribution de rôles invalides', ErrorCode.BAD_REQUEST, { error });
  }
}

/**
 * Middleware pour valider l'ajout d'un domaine personnalisé
 */
export async function addCustomDomainMiddleware(c: Context, next: () => Promise<void>) {
  try {
    const body = await c.req.json();
    const validatedData = validateAddCustomDomain(body);
    c.set('validatedData', validatedData);
    logger.info('Domaine personnalisé validé', 'application-middleware', { domain: validatedData.domain, applicationId: c.req.param('id') });
    await next();
  } catch (error) {
    logger.error('Validation échouée pour le domaine personnalisé', 'application-middleware', { error });
    throw new AppError('Données de domaine personnalisé invalides', ErrorCode.BAD_REQUEST, { error });
  }
}

/**
 * Middleware pour valider l'ajout d'un secret d'application
 */
export async function addApplicationSecretMiddleware(c: Context, next: () => Promise<void>) {
  try {
    const body = await c.req.json();
    const validatedData = validateAddApplicationSecret(body);
    c.set('validatedData', validatedData);
    logger.info('Secret d\'application validé', 'application-middleware', { secretName: validatedData.name, applicationId: c.req.param('id') });
    await next();
  } catch (error) {
    logger.error('Validation échouée pour le secret d\'application', 'application-middleware', { error });
    throw new AppError('Données de secret d\'application invalides', ErrorCode.BAD_REQUEST, { error });
  }
}

/**
 * Middleware pour valider la mise à jour d'un secret d'application
 */
export async function updateApplicationSecretMiddleware(c: Context, next: () => Promise<void>) {
  try {
    const body = await c.req.json();
    const validatedData = validateUpdateApplicationSecret(body);
    c.set('validatedData', validatedData);
    logger.info('Mise à jour de secret d\'application validée', 'application-middleware', { secretId: c.req.param('secretId'), applicationId: c.req.param('id') });
    await next();
  } catch (error) {
    logger.error('Validation échouée pour la mise à jour de secret', 'application-middleware', { error });
    throw new AppError('Données de mise à jour de secret invalides', ErrorCode.BAD_REQUEST, { error });
  }
}

/**
 * Middleware pour valider l'attribution de scopes de consentement utilisateur
 */
export async function assignUserConsentScopesMiddleware(c: Context, next: () => Promise<void>) {
  try {
    const body = await c.req.json();
    const validatedData = validateAssignUserConsentScopes(body);
    c.set('validatedData', validatedData);
    logger.info('Attribution de scopes de consentement validée', 'application-middleware', { applicationId: c.req.param('id') });
    await next();
  } catch (error) {
    logger.error('Validation échouée pour l\'attribution de scopes', 'application-middleware', { error });
    throw new AppError('Données d\'attribution de scopes invalides', ErrorCode.BAD_REQUEST, { error });
  }
}

/**
 * Middleware pour valider la mise à jour de l'expérience de connexion d'une application
 */
export async function updateAppSignInExperienceMiddleware(c: Context, next: () => Promise<void>) {
  try {
    const body = await c.req.json();
    const validatedData = validateUpdateAppSignInExperience(body);
    c.set('validatedData', validatedData);
    logger.info('Expérience de connexion d\'application validée', 'application-middleware', { applicationId: c.req.param('id') });
    await next();
  } catch (error) {
    logger.error('Validation échouée pour l\'expérience de connexion', 'application-middleware', { error });
    throw new AppError('Données d\'expérience de connexion invalides', ErrorCode.BAD_REQUEST, { error });
  }
}

/**
 * Middleware pour valider l'attribution d'accès à une organisation
 */
export async function grantOrganizationAccessMiddleware(c: Context, next: () => Promise<void>) {
  try {
    const body = await c.req.json();
    const validatedData = validateGrantOrganizationAccess(body);
    c.set('validatedData', validatedData);
    logger.info('Attribution d\'accès organisationnel validée', 'application-middleware', { applicationId: c.req.param('id') });
    await next();
  } catch (error) {
    logger.error('Validation échouée pour l\'attribution d\'accès organisationnel', 'application-middleware', { error });
    throw new AppError('Données d\'attribution d\'accès organisationnel invalides', ErrorCode.BAD_REQUEST, { error });
  }
} 