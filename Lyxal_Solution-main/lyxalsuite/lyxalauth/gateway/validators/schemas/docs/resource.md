# Schémas de Validation des Ressources API

Ce document décrit les schémas de validation Zod utilisés pour les ressources API dans l'application LyxalAuth Gateway.

## Schémas disponibles

### `createResourceSchema`

Schéma pour la validation de la création d'une ressource API.

**Champs requis:**
- `name` (string): Le nom de la ressource API.
- `identifier` (string): L'identifiant unique de la ressource API.

**Champs optionnels:**
- `description` (string): Description de la ressource API.
- `isDefault` (boolean): Indique si la ressource API est définie comme défaut.
- `accessTokenLifespan` (number): Durée de vie du jeton d'accès en secondes.

**Exemple d'utilisation:**

```typescript
import { createResourceSchema } from '../validators/schemas/resourceSchemas';

// Données à valider
const resourceData = {
  name: 'API de gestion des utilisateurs',
  identifier: 'user-management-api',
  description: 'API pour la gestion des utilisateurs',
  isDefault: true,
  accessTokenLifespan: 3600
};

// Validation
try {
  const validatedData = createResourceSchema.parse(resourceData);
  // Utiliser les données validées
} catch (error) {
  // Gérer l'erreur de validation
}
```

### `updateResourceSchema`

Schéma pour la validation de la mise à jour d'une ressource API.

**Champs optionnels (au moins un requis):**
- `name` (string): Le nouveau nom de la ressource API.
- `description` (string): La nouvelle description de la ressource API.
- `accessTokenLifespan` (number): La nouvelle durée de vie du jeton d'accès en secondes.

**Exemple d'utilisation:**

```typescript
import { updateResourceSchema } from '../validators/schemas/resourceSchemas';

// Données à valider
const updateData = {
  name: 'API de gestion des utilisateurs v2',
  description: 'API améliorée pour la gestion des utilisateurs',
  accessTokenLifespan: 7200
};

// Validation
try {
  const validatedData = updateResourceSchema.parse(updateData);
  // Utiliser les données validées
} catch (error) {
  // Gérer l'erreur de validation
}
```

### `setResourceAsDefaultSchema`

Schéma pour la validation de la définition d'une ressource API comme défaut.

**Champs requis:**
- `isDefault` (boolean): Indique si la ressource API doit être définie comme défaut.

**Exemple d'utilisation:**

```typescript
import { setResourceAsDefaultSchema } from '../validators/schemas/resourceSchemas';

// Données à valider
const defaultData = {
  isDefault: true
};

// Validation
try {
  const validatedData = setResourceAsDefaultSchema.parse(defaultData);
  // Utiliser les données validées
} catch (error) {
  // Gérer l'erreur de validation
}
```

### `createResourceScopeSchema`

Schéma pour la validation de la création d'un scope de ressource API.

**Champs requis:**
- `name` (string): Le nom du scope.

**Champs optionnels:**
- `description` (string): Description du scope.

**Exemple d'utilisation:**

```typescript
import { createResourceScopeSchema } from '../validators/schemas/resourceSchemas';

// Données à valider
const scopeData = {
  name: 'read:users',
  description: 'Permet de lire les données des utilisateurs'
};

// Validation
try {
  const validatedData = createResourceScopeSchema.parse(scopeData);
  // Utiliser les données validées
} catch (error) {
  // Gérer l'erreur de validation
}
```

### `updateResourceScopeSchema`

Schéma pour la validation de la mise à jour d'un scope de ressource API.

**Champs optionnels (au moins un requis):**
- `name` (string): Le nouveau nom du scope.
- `description` (string): La nouvelle description du scope.

**Exemple d'utilisation:**

```typescript
import { updateResourceScopeSchema } from '../validators/schemas/resourceSchemas';

// Données à valider
const updateData = {
  name: 'read:users:extended',
  description: 'Permet de lire les données étendues des utilisateurs'
};

// Validation
try {
  const validatedData = updateResourceScopeSchema.parse(updateData);
  // Utiliser les données validées
} catch (error) {
  // Gérer l'erreur de validation
}
```

### `paginationSchema`

Schéma pour la validation des paramètres de pagination.

**Champs optionnels:**
- `page` (number): Le numéro de page (entier positif).
- `pageSize` (number): Le nombre d'éléments par page (entier positif).

**Valeurs par défaut:**
- `page`: 1
- `pageSize`: 20

**Exemple d'utilisation:**

```typescript
import { paginationSchema } from '../validators/schemas/resourceSchemas';

// Données à valider
const paginationData = {
  page: 2,
  pageSize: 15
};

// Validation
try {
  const validatedData = paginationSchema.parse(paginationData);
  // Utiliser les données validées
} catch (error) {
  // Gérer l'erreur de validation
}

// Avec des valeurs par défaut
const emptyPagination = {};
const defaultValues = paginationSchema.parse(emptyPagination);
// defaultValues = { page: 1, pageSize: 20 }
```

## Types exportés

Les types suivants sont inférés à partir des schémas et exportés pour une utilisation dans d'autres parties de l'application:

- `CreateResourceData`
- `UpdateResourceData`
- `SetResourceAsDefaultData`
- `CreateResourceScopeData`
- `UpdateResourceScopeData`
- `PaginationData`

## Fonctions de validation

Les fonctions de validation correspondantes sont disponibles dans le fichier `validators/resourceValidation.ts`:

- `validateCreateResource(data: unknown): CreateResourceData`
- `validateUpdateResource(data: unknown): UpdateResourceData`
- `validateSetResourceAsDefault(data: unknown): SetResourceAsDefaultData`
- `validateCreateResourceScope(data: unknown): CreateResourceScopeData`
- `validateUpdateResourceScope(data: unknown): UpdateResourceScopeData`
- `validatePagination(data: unknown): PaginationData` 