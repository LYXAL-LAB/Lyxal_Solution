# Schémas de Validation des Tokens de Sujet

Ce document décrit les schémas de validation Zod utilisés pour les tokens de sujet dans l'application LyxalAuth Gateway.

## Schémas disponibles

### `createSubjectTokenSchema`

Schéma pour la validation de la création d'un token de sujet.

**Champs requis:**
- `userId` (string): L'identifiant de l'utilisateur pour lequel le token est créé.

**Champs optionnels:**
- `expiresIn` (number): Durée de validité du token en secondes.
- `tenantId` (string): Identifiant du tenant associé au token.
- `scope` (string | string[]): Portée d'accès du token, peut être une chaîne unique ou un tableau de chaînes.

**Exemple d'utilisation:**

```typescript
import { createSubjectTokenSchema } from '../validators/schemas/subjectTokenSchemas';

// Données à valider
const tokenData = {
  userId: 'user123',
  expiresIn: 3600,
  tenantId: 'tenant123',
  scope: ['read:profile', 'write:profile']
};

// Validation
try {
  const validatedData = createSubjectTokenSchema.parse(tokenData);
  // Utiliser les données validées
} catch (error) {
  // Gérer l'erreur de validation
}
```

## Types exportés

Les types suivants sont inférés à partir des schémas et exportés pour une utilisation dans d'autres parties de l'application:

- `CreateSubjectTokenData`

## Fonctions de validation

Les fonctions de validation correspondantes sont disponibles dans le fichier `validators/subjectTokenValidation.ts`:

- `validateCreateSubjectToken(data: unknown): CreateSubjectTokenData` 