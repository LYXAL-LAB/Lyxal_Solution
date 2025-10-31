import { updateSignInExperienceSchema, getSignInExperienceSchema, checkPasswordPolicySchema } from './schemas/signInExperienceSchemas';
import { validateZod, ValidationOptions } from './validateZod';

/**
 * Validation des données pour la mise à jour de l'expérience de connexion
 */
export function validateUpdateSignInExperience() {
  return validateZod({
    body: updateSignInExperienceSchema
  });
}

/**
 * Validation des données pour la récupération de l'expérience de connexion
 */
export function validateGetSignInExperience() {
  return validateZod({
    query: getSignInExperienceSchema
  });
}

/**
 * Validation des données pour la vérification de politique de mot de passe
 */
export function validateCheckPasswordPolicy() {
  return validateZod({
    body: checkPasswordPolicySchema
  });
} 