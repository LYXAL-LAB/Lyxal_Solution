# Documentation des schémas de validation pour les Webhooks

Ce document décrit les schémas de validation Zod utilisés pour les routes liées aux webhooks dans l'API Gateway.

## webhookConfigSchema

Ce schéma valide les données pour la configuration d'un webhook.

### Structure

```typescript
{
  url: string,    // URL du webhook (obligatoire, doit être une URL valide)
  headers?: Record<string, string> // En-têtes HTTP personnalisés (optionnel)
}
```

### Type inféré

```typescript
type WebhookConfigData = z.infer<typeof webhookConfigSchema>;
```

## createHookSchema

Ce schéma valide les données pour la création d'un webhook.

### Structure

```typescript
{
  name: string,           // Nom du webhook (obligatoire, 1-256 caractères)
  events: string[],       // Liste des événements (obligatoire, au moins un événement)
  config: WebhookConfigData, // Configuration du webhook (obligatoire)
  enabled?: boolean       // Activation du webhook (optionnel, par défaut: true)
}
```

### Type inféré

```typescript
type CreateHookData = z.infer<typeof createHookSchema>;
```

## updateHookSchema

Ce schéma valide les données pour la mise à jour d'un webhook.

### Structure

```typescript
{
  name?: string,            // Nom du webhook (optionnel, 1-256 caractères)
  events?: string[],        // Liste des événements (optionnel, au moins un événement)
  config?: WebhookConfigData,  // Configuration du webhook (optionnel)
  enabled?: boolean         // Activation du webhook (optionnel)
}
```

### Type inféré

```typescript
type UpdateHookData = z.infer<typeof updateHookSchema>;
```

## updateSigningKeySchema

Ce schéma valide les données pour la mise à jour de la clé de signature d'un webhook.

### Structure

```typescript
{
  signingKey?: string // Clé de signature (optionnel, max 64 caractères)
}
```

### Type inféré

```typescript
type UpdateSigningKeyData = z.infer<typeof updateSigningKeySchema>;
```

## Utilisation avec le middleware validateZod

```typescript
import { validateZod } from '../../validators/validateZod';
import { createHookSchema } from '../../validators/schemas/hookSchemas';

// Dans une route Hono
router.post('/', validateZod({ body: createHookSchema }), async (c) => {
  try {
    // Les données validées sont disponibles via c.get('validatedBody')
    const data = c.get('validatedBody');
    
    // Utilisation des données validées
    const result = await hookService.createHook(data);
    
    return c.json({ data: result, success: true }, 201);
  } catch (error) {
    // Gestion des erreurs
    return c.json({ error: error.message, success: false }, 500);
  }
});
```

## Utilisation avec les fonctions de validation

```typescript
import { validateCreateHook } from '../../validators/hookValidation';

// Dans une fonction
try {
  const data = {
    name: 'Mon webhook',
    events: ['user.created', 'user.updated'],
    config: {
      url: 'https://example.com/webhook',
      headers: {
        'Authorization': 'Bearer token123'
      }
    },
    enabled: true
  };
  
  const validatedData = validateCreateHook(data);
  
  // Utilisation des données validées
  const result = await hookService.createHook(validatedData);
  
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
5. Vérifier que les URL fournies sont bien des URL valides