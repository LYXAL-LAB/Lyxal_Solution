# DEFINE WEBHOOK - Réception de webhooks HTTP

## Introduction

`DEFINE WEBHOOK` permet de définir des endpoints HTTP pour recevoir des webhooks de services externes (Stripe, GitHub, Twilio, etc.) directement dans SurrealDB.

Les webhooks sont automatiquement :
- **Vérifiés** : Validation des signatures cryptographiques
- **Parsés** : Conversion du payload selon le Content-Type
- **Routés** : Exécution de fonctions SurrealQL en réponse

## Syntaxe

```sql
DEFINE WEBHOOK [IF NOT EXISTS | OVERWRITE] @name
  ON PATH @path
  [METHOD @http_method]
  [AUTH @auth_type CREDENTIAL @credential]
  [VERIFY @verification_mode]
  [SECRET @secret]
  [CONTENT TYPE @content_type]
  HANDLER @handler
  [DISABLED]
  [COMMENT @comment]
```

### Paramètres

| Paramètre | Requis | Défaut | Description |
|-----------|--------|--------|-------------|
| `@name` | ✅ | - | Nom unique du webhook |
| `ON PATH` | ✅ | - | Chemin URL (ex: `/webhooks/stripe`) |
| `METHOD` | ❌ | `POST` | Méthode HTTP (GET, POST, PUT, DELETE, PATCH) |
| `AUTH` | ❌ | `NONE` | Mode d'authentification de l'endpoint |
| `CREDENTIAL` | ❌ | - | Référence au credential pour l'auth |
| `VERIFY` | ❌ | `NONE` | Mode de vérification de signature |
| `SECRET` | ❌ | - | Secret pour la vérification |
| `CONTENT TYPE` | ❌ | `JSON` | Type de contenu attendu |
| `HANDLER` | ✅ | - | Fonction à exécuter |
| `DISABLED` | ❌ | - | Désactive le webhook |
| `COMMENT` | ❌ | - | Description |

### Modes d'authentification (AUTH)

| Mode | Description |
|------|-------------|
| `NONE` | Pas d'authentification requise |
| `BASIC` | Authentification Basic (username:password) |
| `BEARER` | Token Bearer dans le header Authorization |
| `HEADER @name` | Header personnalisé avec valeur exacte |
| `JWT` | Vérification de token JWT |

### Modes de vérification (VERIFY)

| Mode | Description | Header utilisé |
|------|-------------|----------------|
| `NONE` | Pas de vérification | - |
| `HMAC` | HMAC-SHA256 standard | Configurable |
| `STRIPE` | Format Stripe-Signature | `Stripe-Signature` |
| `RSA` | Signature RSA | Configurable |

### Types de contenu

| Type | Description |
|------|-------------|
| `JSON` | `application/json` |
| `FORM` | `application/x-www-form-urlencoded` |
| `RAW` | Texte brut |
| `BINARY` | Données binaires (base64) |

## Exemples

### Webhook Stripe basique

```sql
-- Définir le credential pour le secret
DEFINE CREDENTIAL stripe_webhook_secret
  TYPE WEBHOOK
  VALUE "whsec_xxxxxxxxxxxxx"
  ALGORITHM HMAC_SHA256;

-- Définir le webhook
DEFINE WEBHOOK stripe_payments
  ON PATH "/webhooks/stripe"
  METHOD POST
  VERIFY STRIPE
  SECRET $credential.stripe_webhook_secret
  CONTENT TYPE JSON
  HANDLER fn::handle_stripe_event
  COMMENT "Réception des événements Stripe";

-- Définir la fonction handler
DEFINE FUNCTION fn::handle_stripe_event($event: object) {
  -- $event contient le payload déjà parsé
  LET $type = $event.type;
  
  IF $type == "payment_intent.succeeded" {
    LET $payment = $event.data.object;
    
    -- Mettre à jour la commande
    UPDATE orders 
    SET status = "paid", 
        paid_at = time::now(),
        stripe_payment_id = $payment.id
    WHERE stripe_intent_id = $payment.id;
    
    RETURN { success: true, processed: $type };
  };
  
  IF $type == "payment_intent.payment_failed" {
    LET $payment = $event.data.object;
    
    UPDATE orders 
    SET status = "payment_failed",
        failure_reason = $payment.last_payment_error.message
    WHERE stripe_intent_id = $payment.id;
    
    RETURN { success: true, processed: $type };
  };
  
  -- Événement non géré
  RETURN { success: true, ignored: true, type: $type };
};
```

### Webhook GitHub

```sql
DEFINE CREDENTIAL github_secret
  TYPE WEBHOOK
  VALUE "your_github_webhook_secret"
  ALGORITHM HMAC_SHA256;

DEFINE WEBHOOK github_events
  ON PATH "/webhooks/github"
  METHOD POST
  VERIFY HMAC
  SECRET $credential.github_secret
  CONTENT TYPE JSON
  HANDLER fn::handle_github_event;

DEFINE FUNCTION fn::handle_github_event($payload: object) {
  LET $action = $payload.action;
  LET $repo = $payload.repository.full_name;
  
  -- Logger l'événement
  CREATE github_events SET
    action = $action,
    repository = $repo,
    sender = $payload.sender.login,
    received_at = time::now(),
    raw_payload = $payload;
  
  -- Traitement spécifique selon l'événement
  IF $payload.pull_request != NONE {
    RETURN fn::handle_pull_request($payload);
  };
  
  IF $payload.issue != NONE {
    RETURN fn::handle_issue($payload);
  };
  
  RETURN { processed: true };
};
```

### Webhook Twilio (Form-encoded)

```sql
DEFINE WEBHOOK twilio_sms
  ON PATH "/webhooks/twilio/sms"
  METHOD POST
  VERIFY HMAC
  SECRET $credential.twilio_auth_token
  CONTENT TYPE FORM
  HANDLER fn::handle_incoming_sms;

DEFINE FUNCTION fn::handle_incoming_sms($data: object) {
  -- Twilio envoie des données form-encoded
  LET $from = $data.From;
  LET $to = $data.To;
  LET $body = $data.Body;
  
  -- Enregistrer le SMS
  CREATE sms_messages SET
    from_number = $from,
    to_number = $to,
    body = $body,
    received_at = time::now();
  
  -- Répondre avec TwiML
  RETURN {
    twiml: "<Response><Message>Message reçu!</Message></Response>"
  };
};
```

### Webhook sans vérification (développement)

```sql
-- ⚠️ À utiliser uniquement en développement !
DEFINE WEBHOOK dev_test
  ON PATH "/webhooks/test"
  METHOD POST
  VERIFY NONE
  CONTENT TYPE JSON
  HANDLER fn::debug_webhook
  COMMENT "Webhook de test - pas de vérification";

DEFINE FUNCTION fn::debug_webhook($payload: object) {
  -- Logger tout ce qu'on reçoit
  CREATE webhook_logs SET
    payload = $payload,
    received_at = time::now();
  
  RETURN { received: true };
};
```

### Webhook avec authentification Basic

```sql
-- Définir le credential pour l'authentification Basic
DEFINE CREDENTIAL webhook_basic_auth
  TYPE API
  VALUE "admin:super_secret_password"
  COMMENT "Credentials Basic Auth pour webhook interne";

-- Webhook protégé par Basic Auth
DEFINE WEBHOOK internal_api
  ON PATH "/webhooks/internal"
  METHOD POST
  AUTH BASIC CREDENTIAL $credential.webhook_basic_auth
  CONTENT TYPE JSON
  HANDLER fn::handle_internal_event
  COMMENT "Webhook interne - requiert Basic Auth";
```

### Webhook avec Bearer Token

```sql
-- Définir le token Bearer
DEFINE CREDENTIAL api_bearer_token
  TYPE API
  VALUE "my_secret_bearer_token_12345"
  COMMENT "Token Bearer pour webhook partenaire";

-- Webhook protégé par Bearer token
DEFINE WEBHOOK partner_events
  ON PATH "/webhooks/partner"
  METHOD POST
  AUTH BEARER CREDENTIAL $credential.api_bearer_token
  VERIFY HMAC
  SECRET $credential.partner_hmac_secret
  HANDLER fn::handle_partner_event
  COMMENT "Webhook partenaire - Bearer + HMAC";
```

### Webhook avec JWT

```sql
-- Définir la clé JWT
DEFINE CREDENTIAL jwt_public_key
  TYPE JWT
  VALUE "-----BEGIN PUBLIC KEY-----\nMIIB..."
  ALGORITHM RSA
  COMMENT "Clé publique pour vérification JWT";

-- Webhook protégé par JWT
DEFINE WEBHOOK secure_api
  ON PATH "/webhooks/secure"
  METHOD POST
  AUTH JWT CREDENTIAL $credential.jwt_public_key
  CONTENT TYPE JSON
  HANDLER fn::handle_secure_event;
```

### Webhook avec Header personnalisé

```sql
-- Définir le secret du header
DEFINE CREDENTIAL custom_header_secret
  TYPE API
  VALUE "x-custom-secret-value-here"
  COMMENT "Valeur du header X-Api-Key";

-- Webhook avec header personnalisé
DEFINE WEBHOOK custom_auth
  ON PATH "/webhooks/custom"
  METHOD POST
  AUTH HEADER "X-Api-Key" CREDENTIAL $credential.custom_header_secret
  HANDLER fn::handle_custom_event;
```

## URL des webhooks

Les webhooks sont accessibles via :

```
https://votre-surreal-instance.com/webhook/{namespace}/{database}/{path}
```

Exemple :
```
https://db.example.com/webhook/production/main/webhooks/stripe
```

## Variables disponibles dans le handler

Le handler reçoit automatiquement :

| Variable | Type | Description |
|----------|------|-------------|
| `$payload` | object | Le corps de la requête parsé |
| `$headers` | object | Les headers HTTP |
| `$method` | string | La méthode HTTP |
| `$path` | string | Le chemin de la requête |
| `$query` | object | Les paramètres de query string |

```sql
DEFINE FUNCTION fn::full_handler($payload: object) {
  -- Accès aux métadonnées via $this
  LET $content_type = $this.headers["content-type"];
  LET $user_agent = $this.headers["user-agent"];
  
  CREATE webhook_logs SET
    payload = $payload,
    headers = $this.headers,
    method = $this.method,
    path = $this.path,
    query = $this.query;
  
  RETURN { ok: true };
};
```

## Gestion des erreurs

### Retourner une erreur HTTP

```sql
DEFINE FUNCTION fn::handle_webhook($payload: object) {
  -- Validation
  IF $payload.type == NONE {
    THROW "Missing event type";  -- Retourne HTTP 400
  };
  
  -- Traitement...
  RETURN { success: true };
};
```

### Codes de retour

| Retour fonction | Code HTTP |
|-----------------|-----------|
| Objet avec `success: true` | 200 OK |
| `THROW "message"` | 400 Bad Request |
| Erreur non gérée | 500 Internal Server Error |

## Supprimer un webhook

```sql
-- Supprimer un webhook
REMOVE WEBHOOK stripe_payments;

-- Supprimer si existe
REMOVE WEBHOOK IF EXISTS old_webhook;
```

## Désactiver temporairement

```sql
-- Désactiver
DEFINE WEBHOOK OVERWRITE stripe_payments
  ON PATH "/webhooks/stripe"
  METHOD POST
  VERIFY STRIPE
  SECRET $credential.stripe_webhook_secret
  HANDLER fn::handle_stripe_event
  DISABLED;

-- Réactiver (retirer DISABLED)
DEFINE WEBHOOK OVERWRITE stripe_payments
  ON PATH "/webhooks/stripe"
  METHOD POST
  VERIFY STRIPE
  SECRET $credential.stripe_webhook_secret
  HANDLER fn::handle_stripe_event;
```

## Sécurité

### Différence entre AUTH et VERIFY

| Aspect | AUTH | VERIFY |
|--------|------|--------|
| **But** | Authentifier l'appelant | Vérifier l'intégrité du payload |
| **Quand** | Avant de traiter la requête | Après AUTH, avant le handler |
| **Mécanisme** | Username/password, token, JWT | Signature cryptographique |
| **Exemple** | Basic Auth, Bearer token | HMAC-SHA256, Stripe-Signature |
| **Erreur** | 401/403 Unauthorized | 400 Bad Request |

**Exemple complet avec AUTH + VERIFY :**

```sql
-- Webhook ultra-sécurisé : authentification + vérification signature
DEFINE WEBHOOK ultra_secure
  ON PATH "/webhooks/critical"
  METHOD POST
  -- 1. D'abord : authentifier l'appelant (Bearer token)
  AUTH BEARER CREDENTIAL $credential.api_token
  -- 2. Ensuite : vérifier la signature du payload (HMAC)
  VERIFY HMAC
  SECRET $credential.webhook_secret
  HANDLER fn::handle_critical_event;
```

### Toujours vérifier les signatures

```sql
-- ✅ Bon : vérification activée
DEFINE WEBHOOK secure_webhook
  ON PATH "/webhooks/secure"
  VERIFY STRIPE
  SECRET $credential.webhook_secret
  HANDLER fn::handler;

-- ❌ Mauvais : pas de vérification en production
DEFINE WEBHOOK insecure_webhook
  ON PATH "/webhooks/insecure"
  VERIFY NONE  -- Dangereux en production !
  HANDLER fn::handler;
```

### Utiliser DEFINE CREDENTIAL pour les secrets

```sql
-- ✅ Bon : secret chiffré
DEFINE CREDENTIAL webhook_secret TYPE WEBHOOK VALUE "whsec_xxx";
DEFINE WEBHOOK secure
  VERIFY HMAC
  SECRET $credential.webhook_secret
  ...;

-- ❌ Mauvais : secret en clair dans DEFINE PARAM
DEFINE PARAM $webhook_secret VALUE "whsec_xxx";  -- Pas chiffré !
```

### Valider le payload

```sql
DEFINE FUNCTION fn::handle_event($payload: object) {
  -- Valider les champs requis
  IF $payload.event_id == NONE {
    THROW "Missing event_id";
  };
  
  -- Vérifier l'idempotence (éviter les doublons)
  LET $existing = SELECT * FROM webhook_events 
    WHERE event_id = $payload.event_id;
  
  IF array::len($existing) > 0 {
    RETURN { already_processed: true };
  };
  
  -- Traiter l'événement...
};
```

## Bonnes pratiques

### 1. Idempotence

```sql
DEFINE FUNCTION fn::idempotent_handler($payload: object) {
  -- Utiliser l'ID de l'événement comme clé
  LET $event_id = $payload.id OR $payload.event_id;
  
  -- Vérifier si déjà traité
  LET $processed = SELECT * FROM processed_events 
    WHERE id = $event_id;
  
  IF array::len($processed) > 0 {
    RETURN { skipped: true, reason: "already_processed" };
  };
  
  -- Marquer comme en cours de traitement
  CREATE processed_events:[$event_id] SET
    started_at = time::now(),
    status = "processing";
  
  -- Traiter...
  
  -- Marquer comme terminé
  UPDATE processed_events:[$event_id] SET
    completed_at = time::now(),
    status = "completed";
  
  RETURN { success: true };
};
```

### 2. Logging complet

```sql
DEFINE FUNCTION fn::logged_handler($payload: object) {
  LET $log_id = rand::uuid();
  
  -- Logger la réception
  CREATE webhook_logs:[$log_id] SET
    received_at = time::now(),
    payload = $payload,
    status = "received";
  
  -- Traiter
  LET $result = fn::process_event($payload);
  
  -- Logger le résultat
  UPDATE webhook_logs:[$log_id] SET
    completed_at = time::now(),
    result = $result,
    status = "completed";
  
  RETURN $result;
};
```

### 3. Retry-friendly

```sql
DEFINE FUNCTION fn::retry_friendly_handler($payload: object) {
  -- Répondre rapidement (< 30s)
  -- Traitement asynchrone si nécessaire
  
  -- Créer une tâche pour traitement différé
  CREATE background_tasks SET
    type = "webhook_processing",
    payload = $payload,
    status = "pending",
    created_at = time::now();
  
  -- Répondre immédiatement
  RETURN { acknowledged: true };
};
```

## Intégrations courantes

### Stripe

```sql
DEFINE WEBHOOK stripe
  ON PATH "/webhooks/stripe"
  VERIFY STRIPE
  SECRET $credential.stripe_whsec
  HANDLER fn::stripe_handler;
```

### GitHub

```sql
DEFINE WEBHOOK github
  ON PATH "/webhooks/github"
  VERIFY HMAC
  SECRET $credential.github_secret
  HANDLER fn::github_handler;
```

### Slack

```sql
DEFINE WEBHOOK slack
  ON PATH "/webhooks/slack"
  VERIFY HMAC
  SECRET $credential.slack_signing_secret
  CONTENT TYPE FORM
  HANDLER fn::slack_handler;
```

### Discord

```sql
DEFINE WEBHOOK discord
  ON PATH "/webhooks/discord"
  VERIFY NONE  -- Discord utilise un autre mécanisme
  HANDLER fn::discord_handler;
```

## Debugging

### Voir tous les webhooks

```sql
INFO FOR DB;
-- Affiche les webhooks définis
```

### Tester un webhook localement

```bash
# Avec curl
curl -X POST http://localhost:8000/webhook/test/main/webhooks/test \
  -H "Content-Type: application/json" \
  -d '{"type": "test.event", "data": {"key": "value"}}'
```

### Logs

Les événements webhook sont loggés au niveau `info` :

```
[INFO] surrealdb::webhook: webhook:received path="/webhooks/stripe" method="POST"
[INFO] surrealdb::webhook: webhook:verified name="stripe_payments" 
[INFO] surrealdb::webhook: webhook:processed name="stripe_payments" duration=15ms
```
