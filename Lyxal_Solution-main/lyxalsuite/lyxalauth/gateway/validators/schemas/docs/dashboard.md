# Documentation des schémas de validation pour Tableau de Bord

Ce document décrit les schémas de validation Zod utilisés pour les routes liées au tableau de bord dans l'API Gateway.

## userStatsQuerySchema

Ce schéma valide les paramètres de requête pour les routes de statistiques d'utilisateurs, permettant de filtrer les données par période.

### Structure

```typescript
{
  startTimeExclusive?: number, // Timestamp de début (exclusif, optionnel)
  endTimeInclusive?: number    // Timestamp de fin (inclusif, optionnel)
}
```

### Règles de validation

- `startTimeExclusive` est optionnel et doit être un nombre (ou convertible en nombre)
- `endTimeInclusive` est optionnel et doit être un nombre (ou convertible en nombre)
- La validation utilise `z.coerce.number()` pour convertir les chaînes de caractères en nombres

### Type inféré

```typescript
type UserStatsQuery = z.infer<typeof userStatsQuerySchema>;
```

## Utilisation avec le middleware validateZod

```typescript
import { validateZod } from '../../validators/validateZod';
import { userStatsQuerySchema } from '../../validators/schemas/dashboardSchemas';

// Dans une route Hono
router.get('/users/active', validateZod({ query: userStatsQuerySchema }), async (c) => {
  try {
    // Les données validées sont disponibles via c.get('validatedQuery')
    const { startTimeExclusive, endTimeInclusive } = c.get('validatedQuery');
    
    // Utilisation des données validées
    const result = await dashboardService.getActiveUserData({
      startTimeExclusive,
      endTimeInclusive
    });
    
    return c.json(result);
  } catch (error) {
    // Gestion des erreurs
    return c.json({ error: error.message }, 500);
  }
});
```

## Utilisation avec les fonctions de validation

```typescript
import { validateUserStatsQuery } from '../../validators/dashboardValidation';

// Dans une fonction
try {
  const data = {
    startTimeExclusive: 1620000000000,
    endTimeInclusive: 1630000000000
  };
  
  const validatedData = validateUserStatsQuery(data);
  
  // Utilisation des données validées
  const result = await dashboardService.getActiveUserData(validatedData);
  
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
4. Pour les requêtes contenant des timestamps, vérifier que les plages temporelles sont cohérentes
5. Utiliser le logger structuré pour tracer les erreurs de validation 