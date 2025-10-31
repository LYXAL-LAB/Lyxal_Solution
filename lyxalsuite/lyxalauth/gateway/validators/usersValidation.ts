import { validateZod } from './validateZod';
import {
  createUserSchema,
  updateUserSchema,
  updatePasswordSchema,
  verifyPasswordSchema,
  updateSuspensionSchema,
  assignRolesSchema,
  updateCustomDataSchema,
  linkSocialIdentitySchema,
  addPersonalAccessTokenSchema,
  updatePersonalAccessTokenSchema,
  paginationSchema,
  createMfaVerificationSchema
} from './schemas/userSchemas';

/**
 * Validation pour la création d'un utilisateur
 */
export function validateCreateUser() {
  return validateZod({
    body: createUserSchema
  });
}

/**
 * Validation pour la mise à jour d'un utilisateur
 */
export function validateUpdateUser() {
  return validateZod({
    body: updateUserSchema
  });
}

/**
 * Validation pour la mise à jour du mot de passe
 */
export function validateUpdatePassword() {
  return validateZod({
    body: updatePasswordSchema
  });
}

/**
 * Validation pour la vérification de mot de passe
 */
export function validateVerifyPassword() {
  return validateZod({
    body: verifyPasswordSchema
  });
}

/**
 * Validation pour la mise à jour du statut de suspension
 */
export function validateUpdateSuspension() {
  return validateZod({
    body: updateSuspensionSchema
  });
}

/**
 * Validation pour l'attribution de rôles
 */
export function validateAssignRoles() {
  return validateZod({
    body: assignRolesSchema
  });
}

/**
 * Validation pour la mise à jour des données personnalisées
 */
export function validateUpdateCustomData() {
  return validateZod({
    body: updateCustomDataSchema
  });
}

/**
 * Validation pour l'ajout d'un token d'accès personnel
 */
export function validateAddPersonalAccessToken() {
  return validateZod({
    body: addPersonalAccessTokenSchema
  });
}

/**
 * Validation pour la mise à jour d'un token d'accès personnel
 */
export function validateUpdatePersonalAccessToken() {
  return validateZod({
    body: updatePersonalAccessTokenSchema
  });
}

/**
 * Validation pour la liaison d'une identité sociale
 */
export function validateLinkSocialIdentity() {
  return validateZod({
    body: linkSocialIdentitySchema
  });
}

/**
 * Validation pour la pagination
 */
export function validatePagination() {
  return validateZod({
    query: paginationSchema
  });
}

/**
 * Validation pour la création de vérification MFA
 */
export function validateCreateMfaVerification() {
  return validateZod({
    body: createMfaVerificationSchema
  });
} 