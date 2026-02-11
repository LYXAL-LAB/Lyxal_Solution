# Schémas de Validation des Applications SAML

Ce document décrit les schémas de validation Zod utilisés pour les routes liées aux applications SAML dans l'application LyxalAuth Gateway.

## Schémas disponibles

### `certificateSchema`

Schéma pour la validation des certificats d'applications SAML.

**Champs optionnels:**
- `publicKey` (string): Contenu de la clé publique du certificat.
- `privateKey` (string): Contenu de la clé privée du certificat.

### `createSamlApplicationSchema`

Schéma pour la validation de la création d'applications SAML.

**Champs requis:**
- `name` (string): Nom de l'application SAML.
- `acs` (string): URL de service de consommation d'assertion (ACS) SAML.
- `entityId` (string): Identifiant d'entité SAML.

**Champs optionnels:**
- `description` (string): Description de l'application SAML.
- `notBeforeMinutes` (number): Délai en minutes avant lequel l'assertion SAML n'est pas valide.
- `expiresMinutes` (number): Durée de validité de l'assertion SAML en minutes.
- `certificate` (object): Certificat de l'application SAML, conforme au schéma `certificateSchema`.

**Exemple d'utilisation:**

```typescript
import { createSamlApplicationSchema } from '../validators/schemas/samlApplicationsSchemas';

// Données à valider
const applicationData = {
  name: 'Mon Application SAML',
  description: 'Une description de mon application SAML',
  acs: 'https://example.com/acs',
  entityId: 'urn:example:sp',
  notBeforeMinutes: 5,
  expiresMinutes: 60,
  certificate: {
    publicKey: '-----BEGIN CERTIFICATE-----\n...\n-----END CERTIFICATE-----',
    privateKey: '-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----'
  }
};

// Validation
try {
  const validatedData = createSamlApplicationSchema.parse(applicationData);
  // Utiliser les données validées
} catch (error) {
  // Gérer l'erreur de validation
}
```

### `updateSamlApplicationSchema`

Schéma pour la validation de la mise à jour d'applications SAML.

**Champs optionnels:**
- `name` (string): Nom de l'application SAML.
- `description` (string): Description de l'application SAML.
- `acs` (string): URL de service de consommation d'assertion (ACS) SAML.
- `entityId` (string): Identifiant d'entité SAML.
- `notBeforeMinutes` (number): Délai en minutes avant lequel l'assertion SAML n'est pas valide.
- `expiresMinutes` (number): Durée de validité de l'assertion SAML en minutes.
- `certificate` (object): Certificat de l'application SAML, conforme au schéma `certificateSchema`.

### `createSamlApplicationSecretSchema`

Schéma pour la validation de la création de secrets d'applications SAML.

**Champs requis:**
- `name` (string): Nom du secret.

**Champs optionnels:**
- `expiresAt` (string): Date d'expiration du secret au format ISO 8601.

### `updateSamlApplicationSecretSchema`

Schéma pour la validation de la mise à jour de secrets d'applications SAML.

**Champs optionnels:**
- `name` (string): Nom du secret.
- `expiresAt` (string): Date d'expiration du secret au format ISO 8601.

## Types exportés

Les types suivants sont inférés à partir des schémas et exportés pour une utilisation dans d'autres parties de l'application:

- `SamlCertificateData`
- `CreateSamlApplicationData`
- `UpdateSamlApplicationData`
- `CreateSamlApplicationSecretData`
- `UpdateSamlApplicationSecretData`

## Fonctions de validation

Les fonctions de validation correspondantes sont disponibles dans le fichier `validators/samlApplicationsValidation.ts`:

- `validateCreateSamlApplication(data: unknown): CreateSamlApplicationData`
- `validateUpdateSamlApplication(data: unknown): UpdateSamlApplicationData`
- `validateCreateSamlApplicationSecret(data: unknown): CreateSamlApplicationSecretData`
- `validateUpdateSamlApplicationSecret(data: unknown): UpdateSamlApplicationSecretData` 