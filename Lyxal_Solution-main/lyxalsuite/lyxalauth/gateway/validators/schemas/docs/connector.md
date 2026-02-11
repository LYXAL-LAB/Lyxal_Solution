# Documentation des schémas de validation pour Connecteurs

Ce document décrit les schémas de validation Zod utilisés pour les routes liées à la gestion des connecteurs dans l'API Gateway.

## createConnectorSchema

Ce schéma valide les données pour la création d'un nouveau connecteur.

### Structure

```typescript
{
  target: string, // Identifiant du type de connecteur, non vide
  config: Record<string, unknown>, // Configuration spécifique au connecteur
  metadata?: { // Métadonnées optionnelles
    name: string, // Nom du connecteur, non vide
    description?: string, // Description optionnelle
    logo?: string, // URL du logo, doit être une URL valide
    logoDark?: string // URL du logo en mode sombre, doit être une URL valide
  }
}
```

### Règles de validation

- `target` est obligatoire et ne peut pas être vide
- `config` est obligatoire et peut contenir n'importe quelles propriétés
- `metadata` est optionnel mais s'il est fourni :
  - `name` est obligatoire et ne peut pas être vide
  - `logo` et `logoDark` doivent être des URLs valides s'ils sont fournis

### Utilisation

```typescript
import { createConnectorSchema } from '../validators/schemas/connectorSchemas';
import { validateZod } from '../validators/validateZod';

// Dans une route Hono
router.post('/', validateZod({ body: createConnectorSchema }), async (c) => {
  // Les données validées sont disponibles via c.get('validatedBody')
  const data = c.get('validatedBody');
  // ...
});
```

## updateConnectorSchema

Ce schéma valide les données pour la mise à jour d'un connecteur existant.

### Structure

```typescript
{
  config?: Record<string, unknown>, // Configuration à mettre à jour, optionnelle
  metadata?: { // Métadonnées à mettre à jour, optionnelles
    name?: string, // Nom du connecteur, non vide si fourni
    description?: string, // Description
    logo?: string, // URL du logo, doit être une URL valide si fourni
    logoDark?: string // URL du logo en mode sombre, doit être une URL valide si fourni
  }
}
```

### Règles de validation

- Tous les champs sont optionnels (mise à jour partielle)
- Si `metadata.name` est fourni, il ne peut pas être vide
- Si `metadata.logo` ou `metadata.logoDark` sont fournis, ils doivent être des URLs valides

### Utilisation

```typescript
import { updateConnectorSchema } from '../validators/schemas/connectorSchemas';
import { validateZod } from '../validators/validateZod';

// Dans une route Hono
router.patch('/:id', validateZod({ body: updateConnectorSchema }), async (c) => {
  // Les données validées sont disponibles via c.get('validatedBody')
  const data = c.get('validatedBody');
  // ...
});
```

## testPasswordlessConnectorSchema

Ce schéma valide les données pour tester un connecteur sans mot de passe.

### Structure

```typescript
{
  connectorId: string, // ID du connecteur, non vide
  phone?: string, // Numéro de téléphone, optionnel
  email?: string // Email, doit être un format d'email valide si fourni
}
```

### Règles de validation

- `connectorId` est obligatoire et ne peut pas être vide
- Au moins l'un des deux champs `email` ou `phone` doit être fourni
- Si `email` est fourni, il doit être dans un format valide

### Utilisation

```typescript
import { testPasswordlessConnectorSchema } from '../validators/schemas/connectorSchemas';
import { validateZod } from '../validators/validateZod';

// Dans une route Hono
router.post('/test-passwordless', validateZod({ body: testPasswordlessConnectorSchema }), async (c) => {
  // Les données validées sont disponibles via c.get('validatedBody')
  const data = c.get('validatedBody');
  // ...
});
```

## getAuthorizationUriSchema

Ce schéma valide les données pour récupérer l'URI d'autorisation d'un connecteur.

### Structure

```typescript
{
  state: string, // État pour la sécurité CSRF, non vide
  redirectUri: string, // URI de redirection après authentification, doit être une URL valide
  connectorId?: string // ID du connecteur, optionnel
}
```

### Règles de validation

- `state` est obligatoire et ne peut pas être vide
- `redirectUri` est obligatoire et doit être une URL valide
- `connectorId` est optionnel (peut être récupéré depuis les paramètres de route)

### Utilisation

```typescript
import { getAuthorizationUriSchema } from '../validators/schemas/connectorSchemas';
import { validateZod } from '../validators/validateZod';

// Dans une route Hono
router.post('/:id/authorization-uri', validateZod({ body: getAuthorizationUriSchema }), async (c) => {
  // Les données validées sont disponibles via c.get('validatedBody')
  const data = c.get('validatedBody');
  // ...
});
```

## Bonnes pratiques

1. Toujours utiliser le middleware `validateZod` pour les validations dans les routes
2. Gérer correctement les erreurs de validation et retourner des messages d'erreur clairs
3. Pour les contraintes complexes (comme exiger au moins un champ parmi plusieurs), utiliser la méthode `refine` de Zod
4. Pour les URLs, utiliser le validateur `url()` intégré pour garantir des formats valides 