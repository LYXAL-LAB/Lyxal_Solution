# Documentation des schémas de validation pour SsoConnectorProviders

Ce document décrit les schémas de validation utilisés pour les fournisseurs de connecteurs SSO dans l'API Gateway.

## Schémas disponibles

### GetSsoConnectorProvidersSchema

Ce schéma permet de valider les paramètres de requête pour la récupération des fournisseurs de connecteurs SSO.

```typescript
export const getSsoConnectorProvidersSchema = z.object({
  filters: z.string().optional(),
  limit: z.number().int().min(1).optional(),
  offset: z.number().int().min(0).optional()
}).optional();
```

#### Exemple d'utilisation

```typescript
// Exemple de paramètres valides pour la récupération des fournisseurs de connecteurs SSO
const validParams = {
  filters: "type=saml",
  limit: 10,
  offset: 0
};

// Validation
const result = validateGetSsoConnectorProviders(validParams);
```

## Intégration avec les routes

Ces schémas sont utilisés dans les middlewares de validation pour les routes liées aux fournisseurs de connecteurs SSO :

```typescript
import { validateGetSsoConnectorProviders } from '../validators/ssoConnectorProvidersValidation';

// Route pour la récupération des fournisseurs de connecteurs SSO
app.get('/api/sso-connector-providers', validateGetSsoConnectorProviders());
``` 