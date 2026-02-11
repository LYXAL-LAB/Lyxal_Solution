# Schémas de Validation des Rôles

Ce document décrit les schémas de validation Zod utilisés pour les rôles dans l'application LyxalAuth Gateway.

## Schémas disponibles

### `createRoleSchema`

Schéma pour la validation de la création d'un rôle.

**Champs requis:**
- `name` (string): Le nom du rôle.

**Champs optionnels:**
- `description` (string): Description du rôle.

**Exemple d'utilisation:**

```typescript
import { createRoleSchema } from '../validators/schemas/roleSchemas';

// Données à valider
const roleData = {
  name: 'admin',
  description: 'Rôle administrateur avec tous les droits'
};

// Validation
try {
  const validatedData = createRoleSchema.parse(roleData);
  // Utiliser les données validées
} catch (error) {
  // Gérer l'erreur de validation
}
```

### `updateRoleSchema`

Schéma pour la validation de la mise à jour d'un rôle.

**Champs optionnels (au moins un requis):**
- `name` (string): Le nouveau nom du rôle.
- `description` (string): La nouvelle description du rôle.

**Exemple d'utilisation:**

```typescript
import { updateRoleSchema } from '../validators/schemas/roleSchemas';

// Données à valider
const updateData = {
  name: 'super-admin',
  description: 'Rôle super administrateur avec droits étendus'
};

// Validation
try {
  const validatedData = updateRoleSchema.parse(updateData);
  // Utiliser les données validées
} catch (error) {
  // Gérer l'erreur de validation
}
```

### `assignRoleToUsersSchema`

Schéma pour la validation de l'assignation d'un rôle à des utilisateurs.

**Champs requis:**
- `userIds` (string[]): Tableau d'identifiants d'utilisateurs (non vide).

**Exemple d'utilisation:**

```typescript
import { assignRoleToUsersSchema } from '../validators/schemas/roleSchemas';

// Données à valider
const assignData = {
  userIds: ['user1', 'user2', 'user3']
};

// Validation
try {
  const validatedData = assignRoleToUsersSchema.parse(assignData);
  // Utiliser les données validées
} catch (error) {
  // Gérer l'erreur de validation
}
```

### `assignRoleToApplicationsSchema`

Schéma pour la validation de l'assignation d'un rôle à des applications.

**Champs requis:**
- `applicationIds` (string[]): Tableau d'identifiants d'applications (non vide).

**Exemple d'utilisation:**

```typescript
import { assignRoleToApplicationsSchema } from '../validators/schemas/roleSchemas';

// Données à valider
const assignData = {
  applicationIds: ['app1', 'app2', 'app3']
};

// Validation
try {
  const validatedData = assignRoleToApplicationsSchema.parse(assignData);
  // Utiliser les données validées
} catch (error) {
  // Gérer l'erreur de validation
}
```

### `linkScopesToRoleSchema`

Schéma pour la validation de la liaison de scopes à un rôle.

**Champs requis:**
- `scopeIds` (string[]): Tableau d'identifiants de scopes (non vide).

**Exemple d'utilisation:**

```typescript
import { linkScopesToRoleSchema } from '../validators/schemas/roleSchemas';

// Données à valider
const linkData = {
  scopeIds: ['scope1', 'scope2', 'scope3']
};

// Validation
try {
  const validatedData = linkScopesToRoleSchema.parse(linkData);
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
import { paginationSchema } from '../validators/schemas/roleSchemas';

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

- `CreateRoleData`
- `UpdateRoleData`
- `AssignRoleToUsersData`
- `AssignRoleToApplicationsData`
- `LinkScopesToRoleData`
- `PaginationData`

## Fonctions de validation

Les fonctions de validation correspondantes sont disponibles dans le fichier `validators/roleValidation.ts`:

- `validateCreateRole(data: unknown): CreateRoleData`
- `validateUpdateRole(data: unknown): UpdateRoleData`
- `validateAssignRoleToUsers(data: unknown): AssignRoleToUsersData`
- `validateAssignRoleToApplications(data: unknown): AssignRoleToApplicationsData`
- `validateLinkScopesToRole(data: unknown): LinkScopesToRoleData`
- `validatePagination(data: unknown): PaginationData` 