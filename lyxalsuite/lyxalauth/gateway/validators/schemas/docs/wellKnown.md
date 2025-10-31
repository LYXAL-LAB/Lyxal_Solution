# Documentation des schémas Well-Known

Cette documentation décrit les schémas Zod utilisés pour valider les requêtes aux endpoints well-known.

## Table des matières

1. [Introduction](#introduction)
2. [Schémas disponibles](#schémas-disponibles)
   - [getFullSignInExperienceSchema](#getfullsigninexperienceschema)
   - [getWellKnownLocalizedPhrasesSchema](#getwellknownlocalizedphrasesschema)
3. [Exemples d'utilisation](#exemples-dutilisation)

## Introduction

Les endpoints well-known fournissent des informations publiques et des configurations qui peuvent être accessibles sans authentification. Ces schémas assurent la validation des paramètres de requête pour ces endpoints.

## Schémas disponibles

### getFullSignInExperienceSchema

Ce schéma valide les paramètres de requête pour obtenir la configuration complète de l'expérience de connexion.

**Structure :**

```typescript
z.object({
  organizationId: z.string().optional(),
  appId: z.string().optional()
})
```

**Champs :**

| Champ | Type | Description | Requis |
|-------|------|-------------|--------|
| organizationId | string | Identifiant de l'organisation pour filtrer l'expérience de connexion | Non |
| appId | string | Identifiant de l'application pour filtrer l'expérience de connexion | Non |

**Endpoint associé :** `GET /.well-known/sign-in-exp`

### getWellKnownLocalizedPhrasesSchema

Ce schéma valide les paramètres de requête pour obtenir les phrases localisées.

**Structure :**

```typescript
z.object({
  language: z.string().optional()
})
```

**Champs :**

| Champ | Type | Description | Requis |
|-------|------|-------------|--------|
| language | string | Code de langue pour filtrer les phrases (par exemple 'fr', 'en') | Non |

**Endpoint associé :** `GET /.well-known/phrases`

## Exemples d'utilisation

### Exemple 1: Récupération de l'expérience de connexion complète

```typescript
import { validateGetFullSignInExperience } from '../validators/wellKnownValidation';

// Avec des paramètres vides
const params1 = validateGetFullSignInExperience({});
// Résultat: {}

// Avec un ID d'organisation
const params2 = validateGetFullSignInExperience({
  organizationId: 'org123'
});
// Résultat: { organizationId: 'org123' }

// Avec un ID d'application
const params3 = validateGetFullSignInExperience({
  appId: 'app123'
});
// Résultat: { appId: 'app123' }
```

### Exemple 2: Récupération des phrases localisées

```typescript
import { validateGetWellKnownLocalizedPhrases } from '../validators/wellKnownValidation';

// Sans spécifier de langue (utilisera la langue par défaut)
const params1 = validateGetWellKnownLocalizedPhrases({});
// Résultat: {}

// Avec une langue spécifique
const params2 = validateGetWellKnownLocalizedPhrases({
  language: 'fr'
});
// Résultat: { language: 'fr' }
``` 