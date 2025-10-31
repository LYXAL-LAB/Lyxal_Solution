# Schémas de Validation des Scopes d'Organisation

Ce document décrit les schémas de validation Zod utilisés pour les scopes d'organisation dans l'application LyxalAuth Gateway.

## Schémas disponibles

### `createOrganizationScopeSchema`

Schéma pour la validation de la création d'un scope d'organisation.

**Champs requis:**
- `organizationId` (string): L'identifiant de l'organisation.
- `name` (string): Le nom du scope.

**Champs optionnels:**
- `description` (string): Description du scope.

**Exemple d'utilisation:**

```typescript
import { createOrganizationScopeSchema } from '../validators/schemas/organizationScopeSchemas';

// Données à valider
const scopeData = {
  organizationId: 'org-123',
  name: 'read:users',
  description: 'Permet de lire les données des utilisateurs'
};

// Validation
try {
  const validatedData = createOrganizationScopeSchema.parse(scopeData);
  // Utiliser les données validées
} catch (error) {
  // Gérer l'erreur de validation
}
```

### `updateOrganizationScopeSchema`

Schéma pour la validation de la mise à jour d'un scope d'organisation.

**Champs optionnels (au moins un requis):**
- `name` (string): Le nouveau nom du scope.
- `description` (string): La nouvelle description du scope.

**Exemple d'utilisation:**

```typescript
import { updateOrganizationScopeSchema } from '../validators/schemas/organizationScopeSchemas';

// Données à valider
const updateData = {
  name: 'read:users:extended',
  description: 'Permet de lire les données étendues des utilisateurs'
};

// Validation
try {
  const validatedData = updateOrganizationScopeSchema.parse(updateData);
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
import { paginationSchema } from '../validators/schemas/organizationScopeSchemas';

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

- `CreateOrganizationScopeData`
- `UpdateOrganizationScopeData`
- `PaginationData`

## Fonctions de validation

Les fonctions de validation correspondantes sont disponibles dans le fichier `validators/organizationScopeValidation.ts`:

- `validateCreateOrganizationScope(data: unknown): CreateOrganizationScopeData`
- `validateUpdateOrganizationScope(data: unknown): UpdateOrganizationScopeData`
- `validatePagination(data: unknown): PaginationData` 