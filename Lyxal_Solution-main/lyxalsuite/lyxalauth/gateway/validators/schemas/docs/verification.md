# Documentation des schémas de validation pour Verification

Ce document décrit les schémas de validation utilisés pour les routes de vérification dans l'API Gateway.

## Schémas disponibles

### CreateVerificationByPasswordSchema

Ce schéma permet de valider les données pour la création d'une vérification par mot de passe.

```typescript
export const createVerificationByPasswordSchema = z.object({
  userId: z.string().min(1, "L'ID utilisateur est requis"),
  password: z.string().min(1, "Le mot de passe est requis")
});
```

#### Exemple d'utilisation

```typescript
// Exemple de payload valide pour la création d'une vérification par mot de passe
const validPayload = {
  userId: "user123",
  password: "password123"
};

// Validation
const result = validateCreateVerificationByPassword(validPayload);
```

### CreateVerificationByCodeSchema

Ce schéma permet de valider les données pour la création d'une vérification par code.

```typescript
export const createVerificationByCodeSchema = z.object({
  userId: z.string().min(1, "L'ID utilisateur est requis"),
  codeType: z.string().min(1, "Le type de code est requis"),
  email: z.string().email("Format d'email invalide").optional(),
  phone: z.string().optional()
}).refine(
  data => !!(data.email || data.phone),
  {
    message: "Au moins un email ou un téléphone est requis",
    path: ["email"]
  }
);
```

#### Exemple d'utilisation

```typescript
// Exemple de payload valide pour la création d'une vérification par code
const validPayload = {
  userId: "user123",
  codeType: "email",
  email: "user@example.com"
};

// Validation
const result = validateCreateVerificationByCode(validPayload);
```

### VerifyCodeSchema

Ce schéma permet de valider les données pour la vérification d'un code.

```typescript
export const verifyCodeSchema = z.object({
  verificationId: z.string().min(1, "L'ID de vérification est requis"),
  code: z.string().min(1, "Le code est requis")
});
```

#### Exemple d'utilisation

```typescript
// Exemple de payload valide pour la vérification d'un code
const validPayload = {
  verificationId: "verification123",
  code: "123456"
};

// Validation
const result = validateVerifyCode(validPayload);
```

### CreateSocialVerificationSchema

Ce schéma permet de valider les données pour la création d'une vérification sociale.

```typescript
export const createSocialVerificationSchema = z.object({
  userId: z.string().min(1, "L'ID utilisateur est requis"),
  provider: z.string().min(1, "Le fournisseur est requis"),
  redirectUri: z.string().url("L'URI de redirection doit être une URL valide")
});
```

#### Exemple d'utilisation

```typescript
// Exemple de payload valide pour la création d'une vérification sociale
const validPayload = {
  userId: "user123",
  provider: "google",
  redirectUri: "https://example.com/callback"
};

// Validation
const result = validateCreateSocialVerification(validPayload);
```

### VerifySocialVerificationSchema

Ce schéma permet de valider les données pour la vérification d'une vérification sociale.

```typescript
export const verifySocialVerificationSchema = z.object({
  verificationId: z.string().min(1, "L'ID de vérification est requis"),
  code: z.string().min(1, "Le code est requis"),
  state: z.string().optional()
});
```

#### Exemple d'utilisation

```typescript
// Exemple de payload valide pour la vérification d'une vérification sociale
const validPayload = {
  verificationId: "verification123",
  code: "auth-code",
  state: "state-token"
};

// Validation
const result = validateVerifySocialVerification(validPayload);
```

### RequestVerificationCodeSchema

Ce schéma permet de valider les données pour la demande d'un code de vérification.

```typescript
export const requestVerificationCodeSchema = z.object({
  phone: z.string().optional(),
  email: z.string().email("Format d'email invalide").optional(),
  purpose: z.string().min(1, "L'objectif est requis"),
  codeType: z.string().optional()
}).refine(
  data => !!(data.email || data.phone),
  {
    message: "Au moins un email ou un téléphone est requis",
    path: ["email"]
  }
);
```

#### Exemple d'utilisation

```typescript
// Exemple de payload valide pour la demande d'un code de vérification
const validPayload = {
  email: "user@example.com",
  purpose: "signup"
};

// Validation
const result = validateRequestVerificationCode(validPayload);
```

## Intégration avec les routes

Ces schémas sont utilisés dans les middlewares de validation pour les routes liées à la vérification :

```typescript
import { 
  validateCreateVerificationByPassword,
  validateCreateVerificationByCode,
  validateVerifyCode,
  validateCreateSocialVerification,
  validateVerifySocialVerification
} from '../validators/verificationValidation';

// Route pour la création d'une vérification par mot de passe
app.post('/verification/by-password', validateCreateVerificationByPassword());

// Route pour la création d'une vérification par code
app.post('/verification/by-code', validateCreateVerificationByCode());

// Route pour la vérification d'un code
app.post('/verification/verify-code', validateVerifyCode());

// Route pour la création d'une vérification sociale
app.post('/verification/social', validateCreateSocialVerification());

// Route pour la vérification d'une vérification sociale
app.post('/verification/social/verify', validateVerifySocialVerification());
``` 