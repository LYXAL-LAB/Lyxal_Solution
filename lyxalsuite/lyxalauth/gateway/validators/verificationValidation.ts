import { validateZod } from './validateZod';
import {
  createVerificationByPasswordSchema,
  createVerificationByCodeSchema,
  verifyCodeSchema,
  createSocialVerificationSchema,
  verifySocialVerificationSchema,
  requestVerificationCodeSchema,
  verifyVerificationCodeSchema
} from './schemas/verificationSchemas';

/**
 * Validation des données pour la création d'une vérification par mot de passe
 */
export function validateCreateVerificationByPassword() {
  return validateZod({
    body: createVerificationByPasswordSchema
  });
}

/**
 * Validation des données pour la création d'une vérification par code
 */
export function validateCreateVerificationByCode() {
  return validateZod({
    body: createVerificationByCodeSchema
  });
}

/**
 * Validation des données pour la vérification d'un code
 */
export function validateVerifyCode() {
  return validateZod({
    body: verifyCodeSchema
  });
}

/**
 * Validation des données pour la création d'une vérification sociale
 */
export function validateCreateSocialVerification() {
  return validateZod({
    body: createSocialVerificationSchema
  });
}

/**
 * Validation des données pour la vérification d'une vérification sociale
 */
export function validateVerifySocialVerification() {
  return validateZod({
    body: verifySocialVerificationSchema
  });
}

/**
 * Validation des données pour la demande d'un code de vérification
 */
export function validateRequestVerificationCode() {
  return validateZod({
    body: requestVerificationCodeSchema
  });
}

/**
 * Validation des données pour la vérification d'un code de vérification
 */
export function validateVerifyVerificationCode() {
  return validateZod({
    body: verifyVerificationCodeSchema
  });
} 