# DEFINE CREDENTIAL - Gestion sécurisée des secrets

## Introduction

`DEFINE CREDENTIAL` est une nouvelle fonctionnalité de SurrealDB permettant de stocker de manière sécurisée les secrets et credentials (clés API, tokens OAuth, secrets webhook, etc.) avec **chiffrement de bout en bout**.

Contrairement à `DEFINE PARAM` qui stocke les valeurs en clair, `DEFINE CREDENTIAL` chiffre automatiquement toutes les valeurs sensibles avant de les persister dans la base de données.

## Syntaxe

```sql
DEFINE CREDENTIAL [IF NOT EXISTS | OVERWRITE] @name
  TYPE @type
  VALUE @value
  [ALGORITHM @algorithm]
  [HEADERS @header_name]
  [EXPIRES @duration]
  [REFRESH @refresh_token]
  [COMMENT @comment]
```

### Paramètres

| Paramètre | Requis | Description |
|-----------|--------|-------------|
| `@name` | ✅ | Nom unique du credential |
| `TYPE` | ✅ | Type de credential (voir ci-dessous) |
| `VALUE` | ✅ | La valeur secrète à stocker (sera chiffrée) |
| `ALGORITHM` | ❌ | Algorithme cryptographique associé |
| `HEADERS` | ❌ | Nom du header HTTP pour les webhooks |
| `EXPIRES` | ❌ | Durée de validité (pour OAuth) |
| `REFRESH` | ❌ | Token de rafraîchissement (pour OAuth) |
| `COMMENT` | ❌ | Description du credential |

### Types de credentials

| Type | Usage |
|------|-------|
| `API` | Clés API pour appels HTTP sortants |
| `WEBHOOK` | Secrets pour vérifier les signatures de webhooks entrants |
| `OAUTH` | Tokens OAuth2 (access + refresh) |
| `JWT` | Clés de signature/vérification JWT |
| `CUSTOM` | Tout autre type de secret |

### Algorithmes supportés

| Algorithme | Description |
|------------|-------------|
| `HMAC_SHA256` | HMAC avec SHA-256 (défaut) |
| `HMAC_SHA512` | HMAC avec SHA-512 |
| `RSA` | Signature RSA |
| `ED25519` | Signature Ed25519 |

## Exemples

### Clé API Stripe

```sql
-- Définir la clé API Stripe pour les paiements
DEFINE CREDENTIAL stripe_api
  TYPE API
  VALUE "sk_live_51ABC123xyz..."
  ALGORITHM HMAC_SHA256
  COMMENT "Clé API Stripe production";

-- Utilisation dans une fonction
DEFINE FUNCTION fn::process_payment($amount: number, $customer: string) {
  LET $api_key = $credential.stripe_api;
  
  RETURN http::post("https://api.stripe.com/v1/charges", {
    headers: {
      "Authorization": "Bearer " + $api_key
    },
    body: {
      amount: $amount,
      customer: $customer
    }
  });
};
```

### Secret Webhook Stripe

```sql
-- Définir le secret pour vérifier les webhooks Stripe
DEFINE CREDENTIAL stripe_webhook
  TYPE WEBHOOK
  VALUE "whsec_ABC123xyz..."
  ALGORITHM HMAC_SHA256
  HEADERS "Stripe-Signature"
  COMMENT "Secret de vérification webhook Stripe";

-- Le webhook handler utilisera automatiquement ce credential
DEFINE WEBHOOK stripe_events
  ON PATH "/webhooks/stripe"
  METHOD POST
  VERIFY STRIPE
  SECRET $credential.stripe_webhook
  HANDLER fn::handle_stripe_event;
```

### OAuth Google

```sql
-- Définir les tokens OAuth Google
DEFINE CREDENTIAL google_oauth
  TYPE OAUTH
  VALUE "ya29.access_token_here..."
  REFRESH "1//refresh_token_here..."
  EXPIRES 1h
  COMMENT "Tokens OAuth Google pour Gmail API";
```

### JWT Signing Key

```sql
-- Définir une clé de signature JWT
DEFINE CREDENTIAL jwt_signing_key
  TYPE JWT
  VALUE "-----BEGIN PRIVATE KEY-----\nMIIE..."
  ALGORITHM RSA
  COMMENT "Clé privée RSA pour signer les JWT";
```

### Multi-tenant (SaaS)

```sql
-- Chaque tenant a ses propres credentials isolés
USE NS tenant_abc DB production;

DEFINE CREDENTIAL stripe_api
  TYPE API
  VALUE "sk_live_tenant_abc_key..."
  COMMENT "Stripe API key for tenant ABC";

-- Autre tenant
USE NS tenant_xyz DB production;

DEFINE CREDENTIAL stripe_api
  TYPE API
  VALUE "sk_live_tenant_xyz_key..."
  COMMENT "Stripe API key for tenant XYZ";
```

## Supprimer un credential

```sql
-- Supprimer un credential
REMOVE CREDENTIAL stripe_api;

-- Supprimer seulement s'il existe (pas d'erreur sinon)
REMOVE CREDENTIAL IF EXISTS old_api_key;
```

## Sécurité

### Chiffrement

- **Algorithme** : AES-256 en mode authentifié
- **Nonce** : Généré aléatoirement pour chaque chiffrement
- **Authentification** : HMAC-SHA256 pour détecter toute altération
- **Clé maître** : Dérivée de la variable d'environnement `SURREALDB_CREDENTIAL_KEY`

### Configuration de la clé maître

```bash
# Production - OBLIGATOIRE !
export SURREALDB_CREDENTIAL_KEY="votre-clé-secrète-très-longue-et-aléatoire"

# Démarrer SurrealDB
surreal start --log debug file:mydatabase.db
```

> ⚠️ **IMPORTANT** : En production, vous DEVEZ définir `SURREALDB_CREDENTIAL_KEY`. Sans cette variable, une clé par défaut est utilisée (développement uniquement).

### Valeurs jamais exposées

Les valeurs des credentials ne sont **jamais** exposées :

```sql
-- INFO affiche [REDACTED]
INFO FOR DB;
-- Résultat: { credentials: { stripe_api: { type: "API", value: "[REDACTED]", ... } } }

-- Les logs affichent [REDACTED]
-- Les exports affichent [REDACTED]
```

### Accès aux valeurs

Les valeurs déchiffrées sont accessibles uniquement via :

1. **Variable `$credential`** dans les fonctions et handlers
2. **API interne** pour les composants système (webhooks, etc.)

```sql
DEFINE FUNCTION fn::call_api() {
  -- $credential.stripe_api retourne la valeur déchiffrée
  LET $key = $credential.stripe_api;
  RETURN http::get("https://api.example.com", {
    headers: { "Authorization": "Bearer " + $key }
  });
};
```

## Bonnes pratiques

### 1. Nommer explicitement

```sql
-- ✅ Bon : nom explicite avec contexte
DEFINE CREDENTIAL stripe_live_api TYPE API VALUE "...";
DEFINE CREDENTIAL stripe_test_api TYPE API VALUE "...";

-- ❌ Mauvais : nom vague
DEFINE CREDENTIAL key1 TYPE API VALUE "...";
```

### 2. Utiliser les commentaires

```sql
DEFINE CREDENTIAL sendgrid_api
  TYPE API
  VALUE "SG.xxx..."
  COMMENT "SendGrid API key - créée le 2024-01-15 - admin@company.com";
```

### 3. Rotation des credentials

```sql
-- Utiliser OVERWRITE pour la rotation
DEFINE CREDENTIAL OVERWRITE stripe_api
  TYPE API
  VALUE "sk_live_new_key..."
  COMMENT "Rotated on 2024-02-01";
```

### 4. Environnements séparés

```sql
-- Base de données de production
USE NS production DB main;
DEFINE CREDENTIAL stripe_api TYPE API VALUE "sk_live_...";

-- Base de données de staging
USE NS staging DB main;
DEFINE CREDENTIAL stripe_api TYPE API VALUE "sk_test_...";
```

## Différences avec DEFINE PARAM

| Aspect | DEFINE PARAM | DEFINE CREDENTIAL |
|--------|--------------|-------------------|
| Stockage | En clair | Chiffré |
| Accès | `$param_name` | `$credential.name` |
| Visibilité INFO | Valeur visible | `[REDACTED]` |
| Export | Valeur exportée | Non exporté |
| Usage | Config générale | Secrets uniquement |

## Intégration avec DEFINE WEBHOOK

```sql
-- Définir le credential
DEFINE CREDENTIAL github_webhook
  TYPE WEBHOOK
  VALUE "webhook_secret_from_github"
  ALGORITHM HMAC_SHA256
  HEADERS "X-Hub-Signature-256";

-- L'utiliser dans un webhook
DEFINE WEBHOOK github_events
  ON PATH "/webhooks/github"
  METHOD POST
  VERIFY HMAC
  SECRET $credential.github_webhook
  CONTENT TYPE JSON
  HANDLER fn::handle_github_event;
```

## API Programmatique

### Rust

```rust
use surrealdb_core::credential::{encrypt_credential, decrypt_credential};

// Chiffrer une valeur
let encrypted = encrypt_credential("sk_live_xxx")?;

// Déchiffrer
let decrypted = decrypt_credential(&encrypted)?;
```

## Limitations actuelles

1. **Pas de permissions granulaires** : Tous les utilisateurs avec accès DB peuvent accéder aux credentials
2. **Pas de versioning** : L'historique des rotations n'est pas conservé
3. **Pas d'expiration automatique** : Les credentials expirés doivent être gérés manuellement

## Roadmap

- [ ] Permissions granulaires par credential
- [ ] Versioning et audit trail
- [ ] Expiration automatique avec alertes
- [ ] Intégration avec HashiCorp Vault
- [ ] Support des secrets managers cloud (AWS Secrets Manager, Azure Key Vault)
