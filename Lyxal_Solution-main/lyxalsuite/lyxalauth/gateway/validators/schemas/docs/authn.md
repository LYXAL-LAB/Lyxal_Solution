# Documentation des schémas de validation pour l'authentification externe

Ce document décrit les schémas de validation Zod utilisés pour les routes liées à l'authentification externe (Hasura, SAML) dans l'API Gateway.

## hasuraAuthQuerySchema

Ce schéma valide les paramètres de requête pour l'authentification Hasura.

### Structure

```typescript
{
  role?: string // Optionnel
}
```

### Règles de validation

- `role` est un paramètre optionnel qui spécifie le rôle demandé pour l'authentification

### Type inféré

```typescript
type HasuraAuthQuery = z.infer<typeof hasuraAuthQuerySchema>;
```

## samlAcsBodySchema

Ce schéma valide les données de réponse SAML envoyées par un fournisseur d'identité.

### Structure

```typescript
{
  RelayState?: string, // Optionnel
  SAMLResponse: string // Requis, non vide
}
```

### Règles de validation

- `RelayState` est un paramètre optionnel qui contient l'état de relais SAML
- `SAMLResponse` est obligatoire et ne peut pas être vide

### Type inféré

```typescript
type SamlAcsBody = z.infer<typeof samlAcsBodySchema>;
```

## Utilisation avec le middleware validateZod

```typescript
import { validateZod } from '../../validators/validateZod';
import { hasuraAuthQuerySchema } from '../../validators/schemas/authnSchemas';

// Dans une route Hono
router.get('/hasura', validateZod({ query: hasuraAuthQuerySchema }), async (c) => {
  try {
    // Les paramètres validés sont disponibles via c.get('validatedQuery')
    const validatedParams = c.get('validatedQuery');
    
    // Utilisation des paramètres validés
    const result = await authService.processRequest(validatedParams);
    
    return c.json(result, 200);
  } catch (error) {
    // Gestion des erreurs
    return c.json({ error: error.message }, 500);
  }
});
```

## Validation des données de formulaire

Pour les données SAML qui sont généralement envoyées sous forme de formulaire, il est possible de les valider manuellement :

```typescript
// Récupération des données du formulaire
const formData = await c.req.formData();
const samlData = {
  RelayState: formData.get('RelayState')?.toString(),
  SAMLResponse: formData.get('SAMLResponse')?.toString() || ''
};

// Validation manuelle des données SAML
const validatedData = validateZod({ body: samlAcsBodySchema })(
  { ...c, req: { json: () => Promise.resolve(samlData) } } as any,
  async () => {}
);

// Traitement des données validées
const result = await samlService.processResponse(samlData);
```

## Utilisation avec les fonctions de validation

```typescript
import { validateHasuraAuthQuery, validateSamlAcsBody } from '../../validators/authnValidation';

// Dans une fonction
try {
  const params = { role: 'admin' };
  const validatedParams = validateHasuraAuthQuery(params);
  
  // Utilisation des paramètres validés
  const response = await authService.processRequest(validatedParams);
  
  return { success: true, data: response };
} catch (error) {
  // Gestion des erreurs de validation
  return { success: false, error: error.message };
}
```

## Bonnes pratiques

1. Toujours utiliser le middleware `validateZod` pour les validations dans les routes
2. Utiliser les types inférés pour typer les données validées
3. Gérer correctement les erreurs de validation et retourner des messages d'erreur clairs
4. Utiliser le logger structuré pour tracer les erreurs de validation 