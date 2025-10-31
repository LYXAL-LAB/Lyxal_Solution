 # Schémas de validation Zod

Ce répertoire contient tous les schémas de validation [Zod](https://github.com/colinhacks/zod) utilisés dans l'API Gateway.

## Structure

Les schémas sont organisés par domaine fonctionnel, avec un fichier par entité principale :

- `accountSchemas.ts` - Schémas pour les comptes utilisateurs
- `applicationSchemas.ts` - Schémas pour les applications OAuth/OIDC
- etc.

## Utilisation

### Dans les validateurs

```typescript
import { createApplicationSchema } from './schemas/applicationSchemas';

export const validateCreateApplication = async (c: Context) => {
  try {
    const body = await c.req.json();
    const validatedData = createApplicationSchema.parse(body);
    c.set('validatedData', validatedData);
  } catch (error) {
    throw new AppError('Données de création d\'application invalides', 400, error);
  }
};
```

### Pour le typage

```typescript
import { z } from 'zod';
import { createApplicationSchema } from './schemas/applicationSchemas';

// Utilisation du type inféré du schéma
type CreateApplicationData = z.infer<typeof createApplicationSchema>;

// Fonction utilisant le type
function processApplication(data: CreateApplicationData) {
  // ...
}
```

## Standards

Pour chaque schéma, respecter les règles suivantes :

1. **Nommage** : Utiliser le format `{action}{Entity}Schema` (ex: `createApplicationSchema`)
2. **Documentation** : Ajouter un bloc JSDoc pour chaque schéma exporté
3. **Messages d'erreur** : Définir des messages d'erreurs explicites pour chaque champ
4. **Typage** : Utiliser `z.infer<>` pour l'extraction des types
5. **Constance** : Maintenir une structure cohérente entre les schémas d'une même entité

## Exemple complet : Application

```typescript
/**
 * Schéma pour la création d'une nouvelle application
 * @typedef {z.infer<typeof createApplicationSchema>} CreateApplicationData
 */
export const createApplicationSchema = z.object({
  name: z.string().min(1, { message: "Le nom de l'application est requis" }),
  description: z.string().optional(),
  type: z.enum(['web', 'native', 'machine'], { 
    errorMap: () => ({ message: "Le type d'application doit être 'web', 'native' ou 'machine'" }) 
  }),
  redirectUris: z.array(z.string().url({ message: "L'URI de redirection doit être une URL valide" }))
    .optional(),
  // ... autres champs
});

// Usage avec typage
type CreateApplicationData = z.infer<typeof createApplicationSchema>;
```