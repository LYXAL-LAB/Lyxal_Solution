 # Schémas de Validation SAML

Ce document décrit les schémas de validation Zod utilisés pour les routes liées à l'authentification SAML dans l'application LyxalAuth Gateway.

## Schémas disponibles

### `samlAuthRedirectSchema`

Schéma pour la validation des requêtes d'authentification SAML via Redirect binding (GET).

**Champs requis:**
- `SAMLRequest` (string): La requête SAML encodée en Base64.

**Champs optionnels:**
- `RelayState` (string): État à conserver entre la requête et la réponse.

**Exemple d'utilisation:**

```typescript
import { samlAuthRedirectSchema } from '../validators/schemas/samlAuthSchemas';

// Données à valider
const requestData = {
  SAMLRequest: 'base64encodedrequest',
  RelayState: 'somestate'
};

// Validation
try {
  const validatedData = samlAuthRedirectSchema.parse(requestData);
  // Utiliser les données validées
} catch (error) {
  // Gérer l'erreur de validation
}
```

### `samlAuthPostSchema`

Schéma pour la validation des requêtes d'authentification SAML via POST binding (POST).

**Champs requis:**
- `SAMLRequest` (string): La requête SAML encodée en Base64.

**Champs optionnels:**
- `RelayState` (string): État à conserver entre la requête et la réponse.

**Exemple d'utilisation:**

```typescript
import { samlAuthPostSchema } from '../validators/schemas/samlAuthSchemas';

// Données à valider
const requestData = {
  SAMLRequest: 'base64encodedrequest',
  RelayState: 'somestate'
};

// Validation
try {
  const validatedData = samlAuthPostSchema.parse(requestData);
  // Utiliser les données validées
} catch (error) {
  // Gérer l'erreur de validation
}
```

## Types exportés

Les types suivants sont inférés à partir des schémas et exportés pour une utilisation dans d'autres parties de l'application:

- `SamlAuthRedirectData`
- `SamlAuthPostData`

## Fonctions de validation

Les fonctions de validation correspondantes sont disponibles dans le fichier `validators/samlAuthValidation.ts`:

- `validateSamlAuthRedirect(data: unknown): SamlAuthRedirectData`
- `validateSamlAuthPost(data: unknown): SamlAuthPostData`