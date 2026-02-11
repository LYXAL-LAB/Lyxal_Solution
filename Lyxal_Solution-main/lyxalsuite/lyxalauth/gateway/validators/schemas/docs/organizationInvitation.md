# Schémas de Validation des Invitations d'Organisation

Ce document décrit les schémas de validation Zod utilisés pour les invitations d'organisation dans l'application LyxalAuth Gateway.

## Schémas disponibles

### `createOrganizationInvitationSchema`

Schéma pour la validation de la création d'une invitation à une organisation.

**Champs requis:**
- `organizationId` (string): L'identifiant de l'organisation.
- `invitee` (string): L'adresse email de la personne invitée.

**Champs optionnels:**
- `expiresInSeconds` (number): Durée de validité de l'invitation en secondes.
- `role` (string): Identifiant du rôle à attribuer à l'invité.

**Exemple d'utilisation:**

```typescript
import { createOrganizationInvitationSchema } from '../validators/schemas/organizationInvitationSchemas';

// Données à valider
const invitationData = {
  organizationId: 'org-123',
  invitee: 'user@example.com',
  expiresInSeconds: 86400, // 24 heures
  role: 'admin'
};

// Validation
try {
  const validatedData = createOrganizationInvitationSchema.parse(invitationData);
  // Utiliser les données validées
} catch (error) {
  // Gérer l'erreur de validation
}
```

### `updateOrganizationInvitationStatusSchema`

Schéma pour la validation de la mise à jour du statut d'une invitation.

**Champs requis:**
- `status` (enum): Le nouveau statut de l'invitation. Doit être soit `'accepted'` soit `'declined'`.

**Exemple d'utilisation:**

```typescript
import { updateOrganizationInvitationStatusSchema } from '../validators/schemas/organizationInvitationSchemas';

// Données à valider
const statusUpdateData = {
  status: 'accepted'
};

// Validation
try {
  const validatedData = updateOrganizationInvitationStatusSchema.parse(statusUpdateData);
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
import { paginationSchema } from '../validators/schemas/organizationInvitationSchemas';

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

- `CreateOrganizationInvitationData`
- `UpdateOrganizationInvitationStatusData`
- `PaginationData`

## Fonctions de validation

Les fonctions de validation correspondantes sont disponibles dans le fichier `validators/organizationInvitationValidation.ts`:

- `validateCreateOrganizationInvitation(data: unknown): CreateOrganizationInvitationData`
- `validateUpdateOrganizationInvitationStatus(data: unknown): UpdateOrganizationInvitationStatusData`
- `validatePagination(data: unknown): PaginationData`