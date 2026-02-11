import { z } from 'zod';
import { 
  getFullSignInExperienceSchema,
  getWellKnownLocalizedPhrasesSchema
} from './schemas/wellKnownSchemas';

/**
 * Fonction de validation pour la récupération de l'expérience de connexion complète
 * @param input Données d'entrée à valider
 * @returns Données validées et typées
 * @throws Error si la validation échoue
 */
export function validateGetFullSignInExperience(input: unknown) {
  try {
    return getFullSignInExperienceSchema.parse(input);
  } catch (error) {
    if (error instanceof z.ZodError) {
      throw new Error(`Validation des paramètres d'expérience de connexion échouée: ${error.errors.map(e => e.message).join(', ')}`);
    }
    throw error;
  }
}

/**
 * Fonction de validation pour la récupération des phrases localisées
 * @param input Données d'entrée à valider
 * @returns Données validées et typées
 * @throws Error si la validation échoue
 */
export function validateGetWellKnownLocalizedPhrases(input: unknown) {
  try {
    return getWellKnownLocalizedPhrasesSchema.parse(input);
  } catch (error) {
    if (error instanceof z.ZodError) {
      throw new Error(`Validation des paramètres de phrases localisées échouée: ${error.errors.map(e => e.message).join(', ')}`);
    }
    throw error;
  }
} 