# Documentation des schémas de validation pour Domaines

Ce document décrit les schémas de validation Zod utilisés pour les routes liées à la gestion des domaines dans l'API Gateway.

## createDomainSchema

Ce schéma valide les données pour la création d'un domaine.

### Structure

```typescript
{
  domain: string,            // Le nom de domaine (format: example.com)
  type: 'Primary'|'Secondary', // Le type de domaine
  organizationId?: string    // L'ID de l'organisation associée (optionnel)
}
```

### Règles de validation

- `domain` est obligatoire et doit être une chaîne non vide
- `domain` doit respecter le format de domaine valide (ex: example.com, sub.domain.org)
- `type` est obligatoire et doit être soit 'Primary' soit 'Secondary'
- `organizationId` est optionnel et doit être une chaîne

### Type inféré

```typescript
type CreateDomainData = z.infer<typeof createDomainSchema>;
```

## Utilisation avec le middleware validateZod

```typescript
import { validateZod } from '../../validators/validateZod';
import { createDomainSchema } from '../../validators/schemas/domainSchemas';

// Dans une route Hono
router.post('/', validateZod({ body: createDomainSchema }), async (c) => {
  try {
    // Les données validées sont disponibles via c.get('validatedBody')
    const data = c.get('validatedBody');
    
    // Utilisation des données validées
    const result = await domainService.createDomain(data);
    
    return c.json(result, 201);
  } catch (error) {
    // Gestion des erreurs
    return c.json({ error: error.message }, 500);
  }
});
```

## Utilisation avec les fonctions de validation

```typescript
import { validateCreateDomain } from '../../validators/domainValidation';

// Dans une fonction
try {
  const data = {
    domain: 'example.com',
    type: 'Primary'
  };
  
  const validatedData = validateCreateDomain(data);
  
  // Utilisation des données validées
  const result = await domainService.createDomain(validatedData);
  
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
4. Vérifier que le format des domaines est valide avant de les enregistrer
5. Utiliser le logger structuré pour tracer les erreurs de validation 