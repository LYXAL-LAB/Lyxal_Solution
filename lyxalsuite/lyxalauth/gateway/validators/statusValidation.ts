import { healthCheckSchema } from './schemas/statusSchemas';
import { validateZod } from './validateZod';

/**
 * Validation des données pour la vérification de l'état de santé
 */
export function validateHealthCheck() {
  return validateZod({
    query: healthCheckSchema
  });
} 