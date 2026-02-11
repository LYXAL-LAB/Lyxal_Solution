# Schémas de validation Zod pour Gateway

Ce dossier contient tous les schémas de validation Zod utilisés dans la Gateway de LyxalAuth.

## Structure

Les schémas sont organisés par fonctionnalité/route dans des fichiers séparés :

- `accountSchemas.ts` - Schémas pour les routes de compte
- `authSchemas.ts` - Schémas pour les routes d'authentification
- ...etc.

## Utilisation

### Dans les routes

Pour utiliser les schémas dans les routes, utilisez le middleware `validateZod` :

```typescript
import { validateZod } from '../validators/validateZod';
import { updateAccountCenterSettingsSchema } from '../validators/schemas/accountSchemas';

router.patch('/settings', validateZod({ body: updateAccountCenterSettingsSchema }), async (c) => {
  // Le corps est déjà validé et typé
  const data = c.get('validatedBody');
  // Utilisation des données validées...
});
```

### Dans les services

Pour utiliser les schémas dans les services ou autres fichiers :

```typescript
import { 
  updateAccountCenterSettingsSchema,
  UpdateAccountCenterSettings   // Type inféré du schéma
} from '../validators/schemas/accountSchemas';

function processSettings(settings: UpdateAccountCenterSettings) {
  // Le type est correctement inféré...
}

// Pour valider manuellement
function validateInput(input: unknown): UpdateAccountCenterSettings {
  return updateAccountCenterSettingsSchema.parse(input);
}
```

## Types

Chaque schéma a un type TypeScript associé, généré avec `z.infer<typeof schemaName>`. 