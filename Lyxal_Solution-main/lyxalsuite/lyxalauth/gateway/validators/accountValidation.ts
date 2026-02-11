/**
 * @file accountValidation.ts
 * @description Fonctions de validation centralisées pour les routes du compte
 */

import { 
  updateAccountCenterSettingsSchema,
  UpdateAccountCenterSettings 
} from './schemas/accountSchemas';
import { structuredLogger as logger } from '../core/logger/structuredLogger';

/**
 * Valide les données de mise à jour des paramètres du centre de compte
 * @param input Données à valider
 * @returns Données validées avec le type approprié
 * @throws {Error} Si les données ne sont pas valides
 */
export function validateUpdateAccountCenterSettings(input: unknown): UpdateAccountCenterSettings {
  try {
    return updateAccountCenterSettingsSchema.parse(input);
  } catch (error) {
    logger.error(`Erreur de validation des paramètres du centre de compte: ${error}`, 'account-validation');
    throw error;
  }
} 