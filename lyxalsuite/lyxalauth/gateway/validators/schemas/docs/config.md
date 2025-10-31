# Documentation des schémas de validation pour Configurations

Ce document décrit les schémas de validation Zod utilisés pour les routes liées à la gestion des configurations dans l'API Gateway.

## updateAdminConsoleConfigSchema

Ce schéma valide les données pour la mise à jour de la configuration de la console d'administration.

### Structure

```typescript
{
  tenantId?: string, // ID du tenant, optionnel, non vide si fourni
  organizationId?: string, // ID de l'organisation, optionnel, non vide si fourni
  adminConsoleConfig?: Record<string, unknown> // Configuration de la console, optionnelle
}
```

### Règles de validation

- `tenantId` est optionnel mais ne peut pas être vide s'il est fourni
- `organizationId` est optionnel mais ne peut pas être vide s'il est fourni
- `adminConsoleConfig` est un objet optionnel pouvant contenir n'importe quelles propriétés

### Utilisation

```typescript
import { updateAdminConsoleConfigSchema } from '../validators/schemas/configSchemas';
import { validateZod } from '../validators/validateZod';

// Dans une route Hono
router.patch('/', validateZod({ body: updateAdminConsoleConfigSchema }), async (c) => {
  // Les données validées sont disponibles via c.get('validatedBody')
  const data = c.get('validatedBody');
  // ...
});
```

## upsertJwtCustomizerSchema

Ce schéma valide les données pour la création ou la mise à jour d'un personnalisateur JWT.

### Structure

```typescript
{
  targetId: string, // ID cible, non vide
  script: string, // Script de personnalisation, non vide
  isEnabled?: boolean // Si le personnalisateur est activé, optionnel
}
```

### Règles de validation

- `targetId` est obligatoire et ne peut pas être vide
- `script` est obligatoire et ne peut pas être vide
- `isEnabled` est optionnel et doit être un booléen

### Utilisation

```typescript
import { upsertJwtCustomizerSchema } from '../validators/schemas/configSchemas';
import { validateZod } from '../validators/validateZod';

// Dans une route Hono
router.put('/:targetId', validateZod({ body: upsertJwtCustomizerSchema }), async (c) => {
  // Les données validées sont disponibles via c.get('validatedBody')
  const data = c.get('validatedBody');
  // ...
});
```

## patchJwtCustomizerSchema

Ce schéma valide les données pour la mise à jour partielle d'un personnalisateur JWT.

### Structure

```typescript
{
  script?: string, // Script de personnalisation, optionnel, non vide si fourni
  isEnabled?: boolean // Si le personnalisateur est activé, optionnel
}
```

### Règles de validation

- `script` est optionnel mais ne peut pas être vide s'il est fourni
- `isEnabled` est optionnel et doit être un booléen
- Au moins un des champs doit être fourni (l'objet ne peut pas être vide)

### Utilisation

```typescript
import { patchJwtCustomizerSchema } from '../validators/schemas/configSchemas';
import { validateZod } from '../validators/validateZod';

// Dans une route Hono
router.patch('/:targetId', validateZod({ body: patchJwtCustomizerSchema }), async (c) => {
  // Les données validées sont disponibles via c.get('validatedBody')
  const data = c.get('validatedBody');
  // ...
});
```

## testJwtCustomizerSchema

Ce schéma valide les données pour tester un personnalisateur JWT.

### Structure

```typescript
{
  script: string, // Script de personnalisation, non vide
  baseUserClaims: Record<string, unknown>, // Claims de base de l'utilisateur
  userClaims?: Record<string, unknown>, // Claims utilisateur, optionnel
  protectedUserClaims?: Record<string, unknown> // Claims protégés, optionnel
}
```

### Règles de validation

- `script` est obligatoire et ne peut pas être vide
- `baseUserClaims` est obligatoire et doit être un objet
- `userClaims` est optionnel et doit être un objet s'il est fourni
- `protectedUserClaims` est optionnel et doit être un objet s'il est fourni

### Utilisation

```typescript
import { testJwtCustomizerSchema } from '../validators/schemas/configSchemas';
import { validateZod } from '../validators/validateZod';

// Dans une route Hono
router.post('/test', validateZod({ body: testJwtCustomizerSchema }), async (c) => {
  // Les données validées sont disponibles via c.get('validatedBody')
  const data = c.get('validatedBody');
  // ...
});
```

## Bonnes pratiques

1. Toujours utiliser le middleware `validateZod` pour les validations dans les routes
2. Gérer correctement les erreurs de validation et retourner des messages d'erreur clairs
3. Utiliser le logger structuré pour tracer les erreurs de validation
4. Pour les mises à jour partielles, vérifier que l'objet n'est pas vide avec la méthode `refine` de Zod 