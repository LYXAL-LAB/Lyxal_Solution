# Documentation des schémas de validation pour les Jetons à Usage Unique

Ce document décrit les schémas de validation Zod utilisés pour les routes liées aux jetons à usage unique dans l'API Gateway.

## createOneTimeTokenSchema

Ce schéma valide les données pour la création d'un jeton à usage unique.

### Structure

```typescript
{
  type: string,                // Type de jeton (obligatoire, non vide)
  code?: string,               // Code du jeton (optionnel)
  pattern?: string,            // Pattern du jeton (optionnel)
  userId?: string,             // ID de l'utilisateur (optionnel)
  action?: string,             // Action associée (optionnel)
  payload?: Record<string, unknown>, // Données supplémentaires (optionnel)
  resource?: string,           // Ressource associée (optionnel)
  expiresInSeconds?: number    // Durée de validité en secondes (optionnel, doit être positif)
}
```

### Type inféré

```typescript
type CreateOneTimeTokenData = z.infer<typeof createOneTimeTokenSchema>;
```

## verifyOneTimeTokenSchema

Ce schéma valide les données pour la vérification d'un jeton à usage unique.

### Structure

```typescript
{
  token: string,          // Token à vérifier (obligatoire, non vide)
  userId?: string,        // ID de l'utilisateur (optionnel)
  interactionId?: string, // ID de l'interaction (optionnel)
  action?: string,        // Action associée (optionnel)
  resource?: string       // Ressource associée (optionnel)
}
```

### Type inféré

```typescript
type VerifyOneTimeTokenData = z.infer<typeof verifyOneTimeTokenSchema>;
```

## updateOneTimeTokenStatusSchema

Ce schéma valide les données pour la mise à jour du statut d'un jeton à usage unique.

### Structure

```typescript
{
  status: 'consumed' | 'expired' | 'inactive' // Statut du jeton (obligatoire, valeurs limitées)
}
```

### Type inféré

```typescript
type UpdateOneTimeTokenStatusData = z.infer<typeof updateOneTimeTokenStatusSchema>;
```

## paginationSchema

Ce schéma valide les données pour la pagination.

### Structure

```typescript
{
  page: number,     // Numéro de page (optionnel, entier positif, par défaut: 1)
  pageSize: number  // Taille de la page (optionnel, entier positif, par défaut: 20)
}
```

### Type inféré

```typescript
type PaginationData = z.infer<typeof paginationSchema>;
```

## Utilisation avec le middleware validateZod

```typescript
import { validateZod } from '../../validators/validateZod';
import { createOneTimeTokenSchema } from '../../validators/schemas/oneTimeTokenSchemas';

// Dans une route Hono
router.post('/', validateZod({ body: createOneTimeTokenSchema }), async (c) => {
  try {
    // Les données validées sont disponibles via c.get('validatedBody')
    const data = c.get('validatedBody');
    
    // Utilisation des données validées
    const result = await oneTimeTokenService.createOneTimeToken(data);
    
    return c.json({ data: result, success: true }, 201);
  } catch (error) {
    // Gestion des erreurs
    return c.json({ error: error.message, success: false }, 500);
  }
});
```

## Utilisation avec les fonctions de validation

```typescript
import { validateCreateOneTimeToken } from '../../validators/oneTimeTokenValidation';

// Dans une fonction
try {
  const data = {
    type: 'passwordReset',
    userId: 'user123',
    expiresInSeconds: 3600
  };
  
  const validatedData = validateCreateOneTimeToken(data);
  
  // Utilisation des données validées
  const result = await oneTimeTokenService.createOneTimeToken(validatedData);
  
  return { success: true, data: result };
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
5. Vérifier que le type de jeton est toujours spécifié lors de la création 