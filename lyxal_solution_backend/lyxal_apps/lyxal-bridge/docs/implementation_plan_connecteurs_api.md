# Plan d'Implémentation : Connecteurs API en DEFINE FUNCTION

> **Objectif** : Créer des connecteurs d'appels API complets au format `DEFINE FUNCTION` SurrealQL, auto-suffisants et hot-deployables.
>
> **Date** : 2026-04-22

---

## 1. Stratégie retenue : Tout-SurrealQL avec primitives natives minimales

### Principe

```
┌─────────────────────────────────────────────────────────────┐
│              DEFINE FUNCTION fn::bridge::*                   │
│                                                             │
│  Chaque connecteur = du SurrealQL pur                       │
│  - Construit l'URL                                          │
│  - Appelle http::request() natif                            │
│  - Gère la logique métier (IF/ELSE, boucles, pagination)    │
│  - Log la trace                                             │
│  - Hot-deployable, modifiable par un agent IA               │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│              Fonctions natives Rust (universelles)           │
│                                                             │
│  http::request()     — HTTP avec retour complet             │
│  crypto::hmac::*     — HMAC keyed hash                      │
│  (optionnel) crypto::aes::* — chiffrement credentials       │
│                                                             │
│  + Les 100+ fonctions déjà existantes :                     │
│  crypto::sha256, encoding::base64, array::*, object::*,     │
│  string::*, list::*, time::*, parse::*, rand::*             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Pourquoi cette approche ?

| Critère | Rust natif (bridge::call) | DEFINE FUNCTION SurrealQL |
|:---|:---:|:---:|
| Flexibilité par connecteur | ⚠️ Limité par bridge_operations | ✅ Code libre |
| Hot-deploy sans recompiler | ❌ | ✅ |
| Agent IA crée un connecteur | ❌ | ✅ |
| Personnalisation par Realm | ❌ | ✅ |
| Lisibilité / Debug | ⚠️ Opaque | ✅ Code SQL |
| Chainage d'appels API | ❌ Impossible | ✅ LET + IF/ELSE |
| Pagination dynamique | ❌ | ✅ Boucle SurrealQL |

---

## 2. Inventaire des fonctions natives existantes

### ✅ Déjà disponible — aucun travail Rust nécessaire

#### Crypto
- `crypto::sha256(data)` → hash hex
- `crypto::sha512(data)` → hash hex
- `crypto::sha1(data)` → hash hex (legacy, GitHub webhooks)
- `crypto::md5(data)` → hash hex
- `crypto::blake3(data)` → hash hex
- `crypto::argon2::generate/compare` → password hashing
- `crypto::bcrypt::generate/compare` → password hashing

#### Encoding
- `encoding::base64::encode(bytes, padded?)` → string
- `encoding::base64::decode(string)` → bytes
- `encoding::cbor::encode/decode` → CBOR

#### HTTP (feature `http`)
- `http::get(url, headers?)` → body parsé
- `http::post(url, body?, headers?)` → body parsé
- `http::put(url, body?, headers?)` → body parsé
- `http::patch(url, body?, headers?)` → body parsé
- `http::delete(url, headers?)` → body parsé
- `http::head(url, headers?)` → None

#### Collections (50+ fonctions)
- `array::*` — add, append, filter, find, map, reduce, fold, sort, flatten, distinct, etc.
- `object::*` — entries, extend, remove, from_entries, keys, values, len
- `string::*` — concat, contains, replace, split, slice, join, matches, etc.
- `list::dedupe`, `list::aggregate`, `list::split_out`, `list::diff` (custom Lyxal)

#### Autres
- `time::now()`, `time::format()`, `rand::uuid()`, `parse::url::*`, etc.

---

## 3. Les VRAIS trous à combler (Rust natif)

### Trou 1 — `http::request()` avec retour complet ⚡ BLOQUANT

**Problème actuel** : `http::get()` retourne le body directement. Si status ≥ 400 → `bail!` (crash). Pas d'accès au status code ni aux headers de réponse.

**Impact** : Sans ça, impossible de :
- Gérer les erreurs (401, 403, 429, 500) en SurrealQL
- Lire les headers de pagination (`X-Next-Cursor`, `Link`)
- Implémenter un retry conditionnel
- Différencier les types d'erreurs

**Solution** : Créer `http::request(method, url, opts)` → `{ status, headers, body }`

```sql
-- Signature proposée
LET $resp = http::request("GET", "https://api.example.com/data", {
    headers: { "Authorization": "Bearer xxx", "Content-Type": "application/json" },
    body: { key: "value" },     -- optionnel
    timeout: 10000              -- optionnel, ms
});

-- Retour : toujours un objet, même en cas d'erreur HTTP
-- $resp.status  = 200 | 401 | 429 | 500 | ...
-- $resp.headers = { "Content-Type": "application/json", "X-Next-Cursor": "abc123", ... }
-- $resp.body    = { records: [...] } | "error message" | NONE
```

**Fichiers Rust à modifier** :
- `lyxal/core/src/function/util/http/mod.rs` — Nouvelle fonction `request()` qui ne fait pas `error_for_status()`
- `lyxal/core/src/function/http.rs` — Exposer `pub(crate) async fn request()`
- `lyxal/core/src/function/mod.rs` — Enregistrer `"http::request"` dans le dispatch async

**Code Rust estimé** : ~50 lignes (variante de la fonction `request()` existante sans le `error_for_status()`)

### Trou 2 — `crypto::hmac::sha256/sha512` (HMAC keyed hash)

**Problème** : Les fonctions crypto existantes font du hash simple (`SHA256(data)`), pas du HMAC (`HMAC-SHA256(data, key)`). Ce sont deux opérations différentes.

**Impact** : Nécessaire pour :
- Vérification de webhooks Stripe : `HMAC-SHA256(payload, whsec_xxx)`
- Vérification de webhooks GitHub : `HMAC-SHA1(payload, secret)`
- Vérification de webhooks Shopify : `HMAC-SHA256(payload, secret)`
- AWS Signature V4

**Solution** :

```sql
-- Signature proposée
LET $signature = crypto::hmac::sha256($payload_string, $secret_key);
-- Retourne le HMAC hex
LET $signature = crypto::hmac::sha512($payload_string, $secret_key);
```

**Fichiers Rust à modifier** :
- `lyxal/core/src/function/crypto.rs` — Ajouter module `hmac`
- `lyxal/core/src/function/mod.rs` — Enregistrer dans le dispatch sync

**Dépendances** : crate `hmac` + `sha2` (déjà dans les dépendances via `sha2::Sha256`)

**Code Rust estimé** : ~20 lignes

### Trou 3 (optionnel) — `crypto::aes::encrypt/decrypt`

**Problème** : Les credentials dans `bridge_user_credentials.encrypted_data` sont chiffrés.

**Alternative** : Utiliser le RBAC natif de SurrealDB (permissions sur la table) au lieu du chiffrement applicatif. Suffisant pour le MVP.

**Décision** : Reporter à plus tard sauf besoin explicite.

---

## 4. Helpers SurrealQL réutilisables (DEFINE FUNCTION)

### 4.1. `fn::bridge::get_token($provider)`

```sql
DEFINE FUNCTION fn::bridge::get_token($provider: string) {
    LET $creds = (SELECT encrypted_data FROM bridge_user_credentials 
                  WHERE provider = type::record("bridge_providers", $provider)
                  LIMIT 1)[0];
    IF $creds == NONE { 
        THROW "Aucun credential configuré pour le provider '" + $provider + "'. Créez un record dans bridge_user_credentials." 
    };
    RETURN $creds.encrypted_data;
};
```

### 4.2. `fn::bridge::build_url($base, $path, $params)`

```sql
DEFINE FUNCTION fn::bridge::build_url($base: string, $path: string, $params: option<object>) {
    LET $url = string::trim($base, "/") + $path;
    IF $params != NONE {
        FOR $key IN object::keys($params) {
            LET $url = string::replace($url, "{" + $key + "}", type::string($params[$key]));
        };
    };
    RETURN $url;
};
```

### 4.3. `fn::bridge::log($provider, $operation, $method, $url, $status)`

```sql
DEFINE FUNCTION fn::bridge::log(
    $provider: string, 
    $operation: string, 
    $method: string, 
    $url: string, 
    $status: int
) {
    CREATE bridge_execution_logs CONTENT {
        trace_id: rand::uuid(),
        context: { provider: $provider, operation: $operation },
        request: { method: $method, url: $url },
        response: { status: $status },
        timestamp: { started_at: time::now() }
    };
};
```

---

## 5. Pattern d'un connecteur complet (exemple Airtable)

### Structure de fichiers

```
dataseed/
  airtable/
    fn_bridge_airtable_auth.surql                  ← Helper auth
    fn_bridge_airtable_list_records.surql           ← GET /v0/{baseId}/{table}
    fn_bridge_airtable_get_record.surql             ← GET /v0/{baseId}/{table}/{recordId}
    fn_bridge_airtable_create_record.surql          ← POST /v0/{baseId}/{table}
    fn_bridge_airtable_update_record.surql          ← PATCH /v0/{baseId}/{table}/{recordId}
    fn_bridge_airtable_delete_record.surql          ← DELETE /v0/{baseId}/{table}/{recordId}
    permissions/
      shares/
        fn_airtable_permissions_shares_list.surql   ← GET /v0/meta/bases/{baseId}/shares
        ...
```

### Exemple complet : list_records avec http::request

```sql
DEFINE FUNCTION fn::bridge::airtable::list_records(
    $baseId: string, 
    $table: string, 
    $params: option<object>
) {
    -- 1. Auth
    LET $token = fn::bridge::get_token("airtable");
    
    -- 2. URL
    LET $url = fn::bridge::build_url(
        "https://api.airtable.com",
        "/v0/{baseId}/{table}",
        { baseId: $baseId, table: $table }
    );
    
    -- 3. Appel HTTP (natif, retour complet)
    LET $resp = http::request("GET", $url, {
        headers: { 
            "Authorization": "Bearer " + $token, 
            "Content-Type": "application/json" 
        }
    });
    
    -- 4. Trace
    fn::bridge::log("airtable", "list_records", "GET", $url, $resp.status);
    
    -- 5. Gestion d'erreur
    IF $resp.status == 401 { THROW "Airtable: Token invalide ou expiré" };
    IF $resp.status == 403 { THROW "Airtable: Permission insuffisante" };
    IF $resp.status == 429 { THROW "Airtable: Rate limit atteint, réessayez dans quelques secondes" };
    IF $resp.status >= 400 { THROW "Airtable error HTTP " + type::string($resp.status) };
    
    -- 6. Retour
    RETURN $resp.body;
};
```

### Exemple avancé : pagination automatique

```sql
DEFINE FUNCTION fn::bridge::airtable::list_all_records(
    $baseId: string, 
    $table: string
) {
    LET $token = fn::bridge::get_token("airtable");
    LET $base_url = fn::bridge::build_url(
        "https://api.airtable.com",
        "/v0/{baseId}/{table}",
        { baseId: $baseId, table: $table }
    );
    
    LET $all_records = [];
    LET $offset = NONE;
    
    -- Boucle de pagination (max 100 pages de sécurité)
    FOR $i IN 0..100 {
        LET $url = IF $offset != NONE {
            $base_url + "?offset=" + $offset
        } ELSE {
            $base_url
        };
        
        LET $resp = http::request("GET", $url, {
            headers: { "Authorization": "Bearer " + $token }
        });
        
        IF $resp.status != 200 { THROW "Airtable pagination error: HTTP " + type::string($resp.status) };
        
        LET $all_records = array::concat($all_records, $resp.body.records ?? []);
        LET $offset = $resp.body.offset;
        
        -- Plus de pages → sortir
        IF $offset == NONE { BREAK };
    };
    
    fn::bridge::log("airtable", "list_all_records", "GET", $base_url, 200);
    
    RETURN {
        records: $all_records,
        count: array::len($all_records)
    };
};
```

---

## 6. Phases d'exécution

### Phase 1 — Fonctions natives Rust (prerequis)

| # | Tâche | Fichiers | Estimation |
|:---:|:---|:---|:---:|
| 1.1 | Créer `http::request()` | `util/http/mod.rs`, `http.rs`, `mod.rs` | 2h |
| 1.2 | Créer `crypto::hmac::sha256/sha512` | `crypto.rs`, `mod.rs` | 1h |
| 1.3 | Test compilation `cargo check` | — | 30min |
| 1.4 | Tests unitaires | `tests/` | 1h |

### Phase 2 — Helpers SurrealQL

| # | Tâche | Fichiers |
|:---:|:---|:---|
| 2.1 | `fn::bridge::get_token` | `datafunction/fn_bridge_get_token.surql` |
| 2.2 | `fn::bridge::build_url` | `datafunction/fn_bridge_build_url.surql` |
| 2.3 | `fn::bridge::log` | `datafunction/fn_bridge_log.surql` |

### Phase 3 — Connecteurs Airtable (complet)

| # | Tâche | Fichiers |
|:---:|:---|:---|
| 3.1 | Réécrire les 5 CRUD avec http::request | `dataseed/airtable/*.surql` |
| 3.2 | Ajouter les opérations permissions/shares | `dataseed/airtable/permissions/shares/*.surql` |
| 3.3 | Ajouter pagination auto | `dataseed/airtable/fn_bridge_airtable_list_all_records.surql` |

### Phase 4 — Autres providers (prioritaires)

À définir selon les besoins. Candidats : Google Sheets, Slack, Stripe, GitHub, Notion, SendGrid.

---

## 7. Ce qui ne change PAS

- **Tables `bridge_*`** : restent le catalogue de référence (providers, auth schemas, logs)
- **Seed data des ~300 providers** : déjà en place dans `bridge_providers.surql`
- **Fonctions `list::*` custom** : parfaites pour post-traitement des réponses API
- **Crate `lyxal-bridge` Rust** : le code existant (executor, request, response, trace) peut être simplifié ou archivé. Les modules `rate_limit.rs` et `hooks.rs` pourraient être réutilisés à l'intérieur de `http::request()` si besoin.

---

## 8. Questions ouvertes

1. **Format de retour de `http::request()`** — `{ status: int, headers: object, body: any }` convient-il ?
2. **Credentials** — RBAC SurrealDB suffit ou chiffrement AES nécessaire ?
3. **Providers prioritaires** — Quels providers après Airtable ?
4. **Retry** — Faut-il un retry automatique dans `http::request()` (option `retry: 3`) ou on le gère en SurrealQL avec une boucle FOR ?
