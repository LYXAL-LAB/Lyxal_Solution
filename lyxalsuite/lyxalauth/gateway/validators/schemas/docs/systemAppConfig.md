# Schémas de Validation de Configuration d'Application Système

Ce document décrit les schémas de validation Zod utilisés pour les configurations d'application système dans l'application LyxalAuth Gateway.

## Schémas disponibles

### `systemAppConfigSchema`

Schéma pour la validation de la structure des configurations d'application système. Ce schéma est principalement utilisé pour la documentation et le typage, car les routes actuelles ne nécessitent pas de validation d'entrée utilisateur.

**Champs requis:**
- `version` (string): Version de l'application.
- `environment` (string): Environnement d'exécution (production, development, etc.).
- `defaultLocale` (string): Locale par défaut de l'application.
- `supportedLocales` (string[]): Liste des locales supportées par l'application.

**Champs optionnels:**
- `buildNumber` (string): Numéro de build de l'application.
- `features` (Record<string, boolean>): Indicateurs de fonctionnalités activées/désactivées.
- `constants` (Record<string, string | number | boolean | null>): Constantes diverses de l'application.

**Exemple d'utilisation:**

```typescript
import { systemAppConfigSchema } from '../validators/schemas/systemAppConfigSchemas';

// Données à valider
const configData = {
  version: '1.0.0',
  buildNumber: '12345',
  environment: 'production',
  defaultLocale: 'fr',
  supportedLocales: ['fr', 'en', 'es'],
  features: {
    darkMode: true,
    betaFeatures: false
  },
  constants: {
    maxUploadSize: 10485760,
    sessionTimeout: 3600,
    appName: 'LyxalAuth',
    isDemo: false
  }
};

// Validation
try {
  const validatedData = systemAppConfigSchema.parse(configData);
  // Utiliser les données validées
} catch (error) {
  // Gérer l'erreur de validation
}
```

## Types exportés

Les types suivants sont inférés à partir des schémas et exportés pour une utilisation dans d'autres parties de l'application:

- `SystemAppConfigData`

## Fonctions de validation

Les fonctions de validation correspondantes sont disponibles dans le fichier `validators/systemAppConfigValidation.ts`:

- `validateSystemAppConfig(data: unknown): SystemAppConfigData`

## Notes spécifiques

Les routes systemAppConfig actuelles ne nécessitent généralement pas de validation d'entrée utilisateur car elles sont principalement des endpoints GET qui servent la configuration du système. Les schémas et validateurs fournis ici sont conçus pour maintenir la cohérence de l'architecture et pour prendre en charge d'éventuelles fonctionnalités futures. 