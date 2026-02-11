# Documentation des schémas de validation pour les Logs

Ce document décrit les schémas de validation Zod utilisés pour les routes liées aux logs dans l'API Gateway.

## getLogsQuerySchema

Ce schéma valide les paramètres de requête pour récupérer des logs généraux.

### Structure

```typescript
{
  page?: number,              // Numéro de page (défaut: 1)
  page_size?: number,         // Taille de page (défaut: 100, max: 1000)
  application_id?: string,    // ID de l'application
  application_name?: string,  // Nom de l'application
  user_id?: string,           // ID de l'utilisateur
  username?: string,          // Nom d'utilisateur
  event?: string,             // Type d'événement
  type?: string,              // Type de log
  ip_address?: string,        // Adresse IP
  range?: string              // Plage de temps (format: "date_debut,date_fin")
}
```

### Type inféré

```typescript
type GetLogsQueryData = z.infer<typeof getLogsQuerySchema>;
```

## getApplicationLogsQuerySchema

Ce schéma valide les paramètres de requête pour récupérer des logs spécifiques à une application.

### Structure

Hérite de `getLogsQuerySchema` en omettant `application_id` et `application_name`, et en ajoutant:

```typescript
{
  resource_id?: string,      // ID de la ressource
  resource_type?: string,    // Type de ressource
  // ... autres champs hérités
}
```

### Type inféré

```typescript
type GetApplicationLogsQueryData = z.infer<typeof getApplicationLogsQuerySchema>;
```

## getUserLogsQuerySchema

Ce schéma valide les paramètres de requête pour récupérer des logs spécifiques à un utilisateur.

### Structure

Hérite de `getLogsQuerySchema` en omettant `user_id` et `username`, et en ajoutant:

```typescript
{
  detail_level?: "basic" | "detailed" | "full",  // Niveau de détail (défaut: "basic")
  // ... autres champs hérités
}
```

### Type inféré

```typescript
type GetUserLogsQueryData = z.infer<typeof getUserLogsQuerySchema>;
```

## Utilisation avec le middleware validateZod

```typescript
import { validateZod } from '../../validators/validateZod';
import { getLogsQuerySchema } from '../../validators/schemas/logSchemas';

// Dans une route Hono
router.get('/', validateZod({ query: getLogsQuerySchema }), async (c) => {
  try {
    // Les données validées sont disponibles via c.get('validatedQuery')
    const queryParams = c.get('validatedQuery');
    
    // Utilisation des paramètres validés
    const result = await logService.getLogs(queryParams);
    
    return c.json({ data: result, success: true });
  } catch (error) {
    // Gestion des erreurs
    return c.json({ error: error.message, success: false }, 500);
  }
});
```

## Utilisation avec les fonctions de validation

```typescript
import { validateGetLogsQuery } from '../../validators/logValidation';

// Dans une fonction
try {
  const queryParams = {
    page: 1,
    page_size: 50,
    event: 'login'
  };
  
  const validatedParams = validateGetLogsQuery(queryParams);
  
  // Utilisation des paramètres validés
  const result = await logService.getLogs(validatedParams);
  
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
4. Valider les plages de dates et les formats de données spécifiques
5. Limiter la taille des pages pour éviter de surcharger le serveur