# Schémas de Validation des Rôles d'Organisation

Ce document décrit les schémas de validation Zod utilisés pour les rôles d'organisation dans l'application LyxalAuth Gateway.

## Schémas disponibles

### `createOrganizationRoleSchema`

Schéma pour la validation de la création d'un rôle d'organisation.

**Champs requis:**
- `organizationId` (string): L'identifiant de l'organisation.
- `name` (string): Le nom du rôle.

**Champs optionnels:**
- `description` (string): Description du rôle.

**Exemple d'utilisation:**

```typescript
import { createOrganizationRoleSchema } from '../validators/schemas/organizationRoleSchemas';

// Données à valider
const roleData = {
  organizationId: 'org-123',
  name: 'Admin',
  description: 'Rôle administrateur'
};

// Validation
try {
  const validatedData = createOrganizationRoleSchema.parse(roleData);
  // Utiliser les données validées
} catch (error) {
  // Gérer l'erreur de validation
}
```

### `updateOrganizationRoleSchema`

Schéma pour la validation de la mise à jour d'un rôle d'organisation.

**Champs optionnels (au moins un requis):**
- `name` (string): Le nouveau nom du rôle.
- `description` (string): La nouvelle description du rôle.

**Exemple d'utilisation:**

```typescript
import { updateOrganizationRoleSchema } from '../validators/schemas/organizationRoleSchemas';

// Données à valider
const updateData = {
  name: 'Super Admin',
  description: 'Rôle administrateur avec privilèges étendus'
};

// Validation
try {
  const validatedData = updateOrganizationRoleSchema.parse(updateData);
  // Utiliser les données validées
} catch (error) {
  // Gérer l'erreur de validation
}
```

### `assignOrganizationScopesSchema`

Schéma pour la validation de l'attribution de scopes à un rôle d'organisation.

**Champs requis:**
- `scopes` (array): Tableau de chaînes représentant les identifiants des scopes à attribuer.

**Exemple d'utilisation:**

```typescript
import { assignOrganizationScopesSchema } from '../validators/schemas/organizationRoleSchemas';

// Données à valider
const scopesData = {
  scopes: ['read:users', 'write:users', 'delete:users']
};

// Validation
try {
  const validatedData = assignOrganizationScopesSchema.parse(scopesData);
  // Utiliser les données validées
} catch (error) {
  // Gérer l'erreur de validation
}
```

### `assignResourceScopesSchema`

Schéma pour la validation de l'attribution de scopes de ressource à un rôle d'organisation.

**Champs requis:**
- `resourceScopes` (array): Tableau d'objets contenant:
  - `resourceId` (string): L'identifiant de la ressource.
  - `scopeIds` (array): Tableau de chaînes représentant les identifiants des scopes à attribuer pour cette ressource.

**Exemple d'utilisation:**

```typescript
import { assignResourceScopesSchema } from '../validators/schemas/organizationRoleSchemas';

// Données à valider
const resourceScopesData = {
  resourceScopes: [
    {
      resourceId: 'resource-1',
      scopeIds: ['read', 'write']
    },
    {
      resourceId: 'resource-2',
      scopeIds: ['admin']
    }
  ]
};

// Validation
try {
  const validatedData = assignResourceScopesSchema.parse(resourceScopesData);
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
import { paginationSchema } from '../validators/schemas/organizationRoleSchemas';

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

- `CreateOrganizationRoleData`
- `UpdateOrganizationRoleData`
- `AssignOrganizationScopesData`
- `AssignResourceScopesData`
- `PaginationData`

## Fonctions de validation

Les fonctions de validation correspondantes sont disponibles dans le fichier `validators/organizationRoleValidation.ts`:

- `validateCreateOrganizationRole(data: unknown): CreateOrganizationRoleData`
- `validateUpdateOrganizationRole(data: unknown): UpdateOrganizationRoleData`
- `validateAssignOrganizationScopes(data: unknown): AssignOrganizationScopesData`
- `validateAssignResourceScopes(data: unknown): AssignResourceScopesData`
- `validatePagination(data: unknown): PaginationData` 