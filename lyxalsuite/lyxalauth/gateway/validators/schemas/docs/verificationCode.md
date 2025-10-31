# Schémas de Validation des Codes de Vérification

Ce document décrit les schémas de validation Zod utilisés pour les routes liées aux codes de vérification dans l'application LyxalAuth Gateway.

## Schémas disponibles

### `requestVerificationCodeSchema`

Schéma pour la validation des demandes de codes de vérification.

**Champs requis:**
- `purpose` (string): Objectif du code de vérification (ex: 'signup', 'login', 'reset-password').

**Champs conditionnels:**
- Au moins un de ces deux champs doit être présent:
  - `email` (string): Email de l'utilisateur.
  - `phone` (string): Numéro de téléphone de l'utilisateur.

**Champs optionnels:**
- `codeType` (string): Type de code à générer (ex: 'numeric', 'alphanumeric').

**Exemple d'utilisation:**

```typescript
import { validateRequestVerificationCode } from '../validators/verificationCodeValidation';

// Données à valider
const requestData = {
  email: 'utilisateur@example.com',
  purpose: 'signup',
  codeType: 'numeric'
};

// Validation
try {
  const validatedData = validateRequestVerificationCode(requestData);
  // Utiliser les données validées
} catch (error) {
  // Gérer l'erreur de validation
}
```

### `verifyVerificationCodeSchema`

Schéma pour la validation des vérifications de codes.

**Champs requis:**
- `code` (string): Le code de vérification à vérifier.
- `purpose` (string): Objectif du code de vérification (ex: 'signup', 'login', 'reset-password').

**Champs conditionnels:**
- Au moins un de ces deux champs doit être présent:
  - `email` (string): Email de l'utilisateur.
  - `phone` (string): Numéro de téléphone de l'utilisateur.

**Exemple d'utilisation:**

```typescript
import { validateVerifyVerificationCode } from '../validators/verificationCodeValidation';

// Données à valider
const verifyData = {
  email: 'utilisateur@example.com',
  code: '123456',
  purpose: 'signup'
};

// Validation
try {
  const validatedData = validateVerifyVerificationCode(verifyData);
  // Utiliser les données validées
} catch (error) {
  // Gérer l'erreur de validation
}
```

## Types exportés

Les types suivants sont inférés à partir des schémas et exportés pour une utilisation dans d'autres parties de l'application:

- `RequestVerificationCodeData`
- `VerifyVerificationCodeData`

## Fonctions de validation

Les fonctions de validation correspondantes sont disponibles dans le fichier `validators/verificationCodeValidation.ts`:

- `validateRequestVerificationCode(data: unknown): RequestVerificationCodeData`
- `validateVerifyVerificationCode(data: unknown): VerifyVerificationCodeData`