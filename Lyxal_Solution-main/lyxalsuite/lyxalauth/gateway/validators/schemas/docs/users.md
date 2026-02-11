# Documentation des schémas de validation pour Users

Ce document décrit les schémas de validation utilisés pour les utilisateurs dans l'API Gateway.

## Schémas disponibles

### CreateUserSchema

Ce schéma permet de valider les données pour la création d'un utilisateur.

```typescript
export const createUserSchema = z.object({
  username: z.string().min(3),
  name: z.string().optional(),
  primaryEmail: z.string().email().optional(),
  primaryPhone: z.string().optional(),
  password: z.string().min(8).optional(),
  customData: z.record(z.unknown()).optional()
});
```

#### Exemple d'utilisation

```typescript
// Exemple de payload valide pour la création d'un utilisateur
const validPayload = {
  username: "johnsmith",
  name: "John Smith",
  primaryEmail: "john.smith@example.com",
  password: "StrongPassword123!"
};

// Validation
const result = validateCreateUser(validPayload);
```

### UpdateUserSchema

Ce schéma permet de valider les données pour la mise à jour d'un utilisateur.

```typescript
export const updateUserSchema = z.object({
  username: z.string().optional(),
  name: z.string().optional(),
  primaryEmail: z.string().email().optional(),
  primaryPhone: z.string().optional(),
  customData: z.record(z.unknown()).optional()
});
```

### UpdatePasswordSchema

Ce schéma permet de valider les données pour la mise à jour du mot de passe d'un utilisateur.

```typescript
export const updatePasswordSchema = z.object({
  currentPassword: z.string().min(1),
  newPassword: z.string().min(8)
    .regex(/[A-Z]/)
    .regex(/[a-z]/)
    .regex(/[0-9]/)
    .regex(/[^A-Za-z0-9]/)
});
```

### VerifyPasswordSchema

Ce schéma permet de valider les données pour la vérification du mot de passe d'un utilisateur.

```typescript
export const verifyPasswordSchema = z.object({
  password: z.string().min(1)
});
```

### UpdateSuspensionSchema

Ce schéma permet de valider les données pour la mise à jour du statut de suspension d'un utilisateur.

```typescript
export const updateSuspensionSchema = z.object({
  isSuspended: z.boolean()
});
```

### AssignRolesSchema

Ce schéma permet de valider les données pour l'attribution de rôles à un utilisateur.

```typescript
export const assignRolesSchema = z.object({
  roleIds: z.array(z.string())
});
```

### UpdateCustomDataSchema

Ce schéma permet de valider les données pour la mise à jour des données personnalisées d'un utilisateur.

```typescript
export const updateCustomDataSchema = z.object({
  customData: z.record(z.unknown())
});
```

### LinkSocialIdentitySchema

Ce schéma permet de valider les données pour la liaison d'une identité sociale à un utilisateur.

```typescript
export const linkSocialIdentitySchema = z.object({
  provider: z.string().min(1),
  userId: z.string().min(1)
});
```

### PaginationSchema

Ce schéma permet de valider les paramètres de pagination pour la récupération d'utilisateurs.

```typescript
export const paginationSchema = z.object({
  page: z.string().transform(val => parseInt(val) || 1),
  page_size: z.string().transform(val => parseInt(val) || 20)
});
```

### CreateMfaVerificationSchema

Ce schéma permet de valider les données pour la création de vérification MFA pour un utilisateur.

```typescript
export const createMfaVerificationSchema = z.object({
  type: z.enum(['Totp', 'WebAuthn', 'BackupCode']),
  code: z.string().optional(),
  credential: z.record(z.unknown()).optional()
});
```

## Intégration avec les routes

Ces schémas sont utilisés dans les middlewares de validation pour les routes liées aux utilisateurs :

```typescript
import { validateCreateUser, validateUpdateUser } from '../validators/usersValidation';

// Route pour la création d'un utilisateur
app.post('/api/users', validateCreateUser());

// Route pour la mise à jour d'un utilisateur
app.patch('/api/users/:id', validateUpdateUser());
``` 