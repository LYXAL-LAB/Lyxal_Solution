# Documentation des schémas de validation pour SignInExperience

Ce document décrit les schémas de validation utilisés pour l'expérience de connexion dans l'API Gateway.

## Schémas disponibles

### UpdateSignInExperienceSchema

Ce schéma permet de valider les données pour la mise à jour de l'expérience de connexion.

```typescript
export const updateSignInExperienceSchema = z.object({
  branding: z.object({
    logoUrl: z.string().url({ message: 'L\'URL du logo doit être une URL valide' }).optional(),
    darkLogoUrl: z.string().url({ message: 'L\'URL du logo en mode sombre doit être une URL valide' }).optional(),
    favicon: z.string().url({ message: 'L\'URL du favicon doit être une URL valide' }).optional(),
    darkFavicon: z.string().url({ message: 'L\'URL du favicon en mode sombre doit être une URL valide' }).optional(),
    appName: z.record(z.string()).optional(),
    appNameAlt: z.record(z.string()).optional(),
    themeOverride: z.record(z.any()).optional(),
  }).optional(),
  color: z.object({
    primaryColor: z.string().regex(/^#[\da-f]{3}([\da-f]{3})?$/i).optional(),
    isDarkModeEnabled: z.boolean().optional(),
    darkPrimaryColor: z.string().regex(/^#[\da-f]{3}([\da-f]{3})?$/i).optional(),
  }).optional(),
  // ... autres propriétés
}).partial();
```

#### Exemple d'utilisation

```typescript
// Exemple de payload valide pour la mise à jour de l'expérience de connexion
const validPayload = {
  branding: {
    logoUrl: "https://example.com/logo.png",
    appName: {
      fr: "Mon Application",
      en: "My Application"
    }
  },
  color: {
    primaryColor: "#1a73e8",
    isDarkModeEnabled: true
  },
  termsEnabled: true,
  termsUrl: {
    fr: "https://example.com/terms-fr",
    en: "https://example.com/terms-en"
  },
  signIn: {
    methods: [
      {
        identifier: "email",
        password: true,
        verificationCode: false,
        isPasswordPrimary: true
      }
    ]
  }
};

// Validation
const result = validateUpdateSignInExperience(validPayload);
```

### GetSignInExperienceSchema

Ce schéma permet de valider les paramètres de requête pour la récupération de l'expérience de connexion.

```typescript
export const getSignInExperienceSchema = z.object({
  organizationId: z.string().optional(),
  appId: z.string().optional()
});
```

#### Exemple d'utilisation

```typescript
// Exemple de paramètres valides pour la récupération de l'expérience de connexion
const validParams = {
  organizationId: "org_12345",
  appId: "app_67890"
};

// Validation
const result = validateGetSignInExperience(validParams);
```

## Intégration avec les routes

Ces schémas sont utilisés dans les middlewares de validation pour les routes liées à l'expérience de connexion :

```typescript
import { validateUpdateSignInExperience, validateGetSignInExperience } from '../validators/signInExperienceValidation';

// Route pour la mise à jour de l'expérience de connexion
app.put('/api/sign-in-experience', validateUpdateSignInExperience());

// Route pour la récupération de l'expérience de connexion
app.get('/api/sign-in-experience', validateGetSignInExperience());
``` 