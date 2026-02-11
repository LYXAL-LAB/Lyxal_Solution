import { getSsoConnectorProvidersSchema } from './schemas/ssoConnectorProvidersSchemas';
import { validateZod } from './validateZod';

/**
 * Validation des données pour la récupération des fournisseurs de connecteurs SSO
 */
export function validateGetSsoConnectorProviders() {
  return validateZod({
    query: getSsoConnectorProvidersSchema
  });
} 