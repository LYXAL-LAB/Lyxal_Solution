---
trigger: always_on
---

# 🧘 10. Philosophie Finale Lyxal OS & Frontières

* 🗄️ **Les données** vivent dans **SurrealDB**.

* ⚙️ **Les règles métier et la logique des données** vivent dans **SurrealQL**. Priorité à SurrealQL pour toute logique métier liée aux données.

* 🧱 **Les primitives techniques génériques** sont réutilisées depuis **`lyxal_core`**.

* 🌐 **Les protocoles externes, moteurs temps réel, communications réseau, chiffrement, parsing et traitements système** restent implémentés en **Rust**.

* ⚡ **Les événements** orchestrent les modules entre eux.

* 🎨 **L'interface UI / CLI** ne contient **aucune logique métier**.

La répartition fondamentale est donc :

```text
LYXAL CORE
    │
    │ primitives génériques
    ▼
SURREALQL
    │
    │ règles métier / données
    ▼
RUST
    │
    │ protocoles / système / réseau
    ▼
EVENTS
    │
    │ orchestration
    ▼
UI
```

---

# 🔒 11. Standards Inviolables de Transport (`lyxal_surreal`) & Cryptographie (`lyxal_crypto`)

Afin de garantir une cohérence parfaite et d'empêcher toute régression future sur l'ensemble de la suite **Lyxal OS** (`lyxal_booking`, `lyxal_notification`, `lyxal_scheduler`, `lyxal_crm`, etc.), les règles suivantes s'imposent à tous les modules.

---

## 11.1. Transport Unifié `Surreal<Any>` & `LyxalSurrealCall`

### Store Unifié

Tout store de persistance d'un module métier doit être représenté par une structure enveloppant :

```rust
Surreal<Any>
```

avec :

```rust
surrealdb::engine::any::Any
```

Interdiction de créer des `enum (Ws/Mem)` locaux.

### Centralisation de `call_fn()`

La méthode d'exécution universelle :

```rust
call_fn()
```

existe à un seul endroit :

```text
lyxal_surreal
```

Aucun module métier ne doit surcharger ou dupliquer cette logique.

### Zéro `panic!`

Les appels au client transport ne doivent jamais générer de :

```rust
panic!
```

en mémoire.

---

## 11.2. Authentification des Moteurs Distants vs Embarqués

### Connexions Distantes

```text
ws://
wss://
```

requièrent obligatoirement une authentification `Root` (`signin`).

### Connexions Embarquées

```text
mem://
memory
```

ne doivent **JAMAIS** tenter d'authentification `Root`.

### Validation des Endpoints

Les schémas d'URL valides sont restreints à :

```text
ws://
wss://
mem://
memory
```

---

## 11.3. Cryptographie Centralisée avec `lyxal_crypto`

`lyxal_crypto` est le **crate cryptographique officiel et unique** de Lyxal OS.

Son API publique est **FIGÉE** (CORE FREEZE, STATUS: STABLE).

Le contrat complet est documenté dans `crates/lyxal_crypto/API_CONTRACT.md`.

### Primitives STABLE Disponibles

| Primitive | Module | Fonctions Principales |
| :--- | :--- | :--- |
| **AES-256-GCM** | `cipher`, `envelope`, `context` | `CryptoEngine::encrypt_secret`, `CryptoEngine::decrypt_secret`, `CryptoEngine::encrypt_unbound`, `CryptoEngine::decrypt_unbound`, `CryptoEngine::reencrypt_if_needed` |
| **SHA-256** | `hash` | `sha256()`, `sha256_hex()`, `Sha256Hasher` |
| **BLAKE3** | `hash` | `blake3()`, `blake3_hex()`, `Blake3Hasher` |
| **Argon2id** | `password` | `hash_password()`, `verify_password()`, `needs_rehash()` |
| **HMAC-SHA256** | `hmac` | `sign_hmac_sha256()`, `sign_hmac_sha256_hex()`, `verify_hmac_sha256()`, `verify_hmac_sha256_hex()` |
| **HKDF-SHA256** | `kdf` | `hkdf_sha256()`, `hkdf_sha256_32()` |
| **Gestion de clés** | `key`, `key_resolver` | `EncryptionKey`, `KeyId`, `KeyResolver`, `CompositeKeyResolver`, `EnvironmentKeyProvider`, `FileKeyProvider` |

### Chiffrement des Secrets

Tous les secrets :

* mots de passe ;
* tokens ;
* clés API ;
* données sensibles

sont gérés exclusivement via :

```text
lyxal_crypto
```

### Règles d'Usage Obligatoires

1. **Hachage de mots de passe** : utiliser `lyxal_crypto::password::{hash_password, verify_password}`. Il est interdit d'importer directement `argon2`, `bcrypt` ou toute autre crate de hachage de mots de passe dans un module métier.

2. **Signature HMAC** : utiliser `lyxal_crypto::hmac::{sign_hmac_sha256, verify_hmac_sha256}`. Il est interdit d'importer directement `hmac` ou `sha2` dans un module métier pour signer ou vérifier des MACs.

3. **Hachage cryptographique** : utiliser `lyxal_crypto::hash::{sha256, blake3}`. Il est interdit d'importer directement `sha2` ou `blake3` dans un module métier.

4. **Dérivation de clés** : utiliser `lyxal_crypto::kdf::{hkdf_sha256, hkdf_sha256_32}`. Il est interdit d'importer directement `hkdf` dans un module métier.

5. **Chiffrement de secrets** : utiliser `CryptoEngine` avec `SecretContext` (ou mode non lié `encrypt_unbound`/`decrypt_unbound`) et `EncryptedEnvelope`. Il est interdit d'appeler directement les primitives bas niveau `encrypt_aes_gcm` / `decrypt_aes_gcm` dans un module métier.

6. **CSPRNG** : utiliser `rand_core::OsRng`. Il est interdit d'utiliser `rand::thread_rng()` ou tout PRNG déterministe pour la génération de matériel cryptographique.

### Contextes AAD Déterministes

En mode lié (recommandé pour toute donnée multi-tenant et applicative), chaque valeur chiffrée doit dériver son AAD d'un `SecretContext` strict :

```text
tenant
module
resource
record_id
field
```

Le format AAD canonique `lyxal:v1` est **DÉFINITIVEMENT FIGÉ**. Sa spécification complète est documentée dans `crates/lyxal_crypto/ENVELOPE_FORMAT_V1.md`.

Le mode non lié (`encrypt_unbound` / `decrypt_unbound`, AAD vide) est réservé aux secrets d'infrastructure globaux dépourvus de contexte d'enregistrement ou de tenant.

### Format d'Enveloppe Moderne

Toute nouvelle écriture est scellée directement sous le format :

```text
enc:v1:<key_id>:<base64url_payload>
```

Ce format est **DÉFINITIVEMENT FIGÉ**. Toute modification future du schéma d'enveloppe devra introduire une version explicite (`enc:v2`).

### Interdiction Absolue de Duplication Cryptographique

Il est **strictement interdit** :

* d'importer directement dans un module métier une crate crypto (`argon2`, `hmac`, `sha2`, `blake3`, `aes-gcm`, `hkdf`) si la primitive équivalente existe dans `lyxal_crypto` ;
* de réimplémenter localement une primitive déjà fournie par `lyxal_crypto` ;
* de créer une variante locale pour éviter d'appeler `lyxal_crypto`.

### Extension Cryptographique — Validation CTO Obligatoire

> [!IMPORTANT]
>
> **RÈGLE INVIOLABLE : Toute fonctionnalité cryptographique supplémentaire nécessaire pour un module Lyxal OS doit impérativement passer par la validation explicite du CTO avant toute implémentation.**

Si un module métier identifie un besoin cryptographique non couvert par les primitives STABLE de `lyxal_crypto`, le processus suivant s'applique :

1. **Signaler le besoin** au CTO avec une justification produit réelle.
2. **Attendre la validation CTO** avant toute modification de `lyxal_crypto` ou tout ajout de dépendance crypto.
3. **Ne jamais ajouter** de nouvelle primitive cryptographique dans `lyxal_crypto` sans validation explicite.
4. **Ne jamais contourner** `lyxal_crypto` en important directement une crate crypto dans un module métier.

Les primitives actuellement **HORS SCOPE** (et qui le resteront jusqu'à validation CTO d'un besoin produit réel) :

* Ed25519 / X25519 (cryptographie asymétrique)
* ChaCha20-Poly1305
* Cryptographie post-quantique
* KMS / HSM natif

```text
Besoin crypto dans un module
        │
        ▼
Existe dans lyxal_crypto ?
        │
   ┌────┴────┐
   │         │
  OUI       NON
   │         │
   ▼         ▼
Utiliser   Signaler au CTO
lyxal_crypto   │
               ▼
         Validation CTO
               │
          ┌────┴────┐
          │         │
       VALIDÉ    REFUSÉ
          │         │
          ▼         ▼
    Implémenter   STOP
    dans lyxal_crypto
```

---

## 11.4. Interdiction Absolue des Erreurs Silencieuses

### Zéro Masquage d'Erreurs

Il est interdit de convertir silencieusement :

* un échec réseau ;
* une erreur SurrealQL ;
* une erreur de désérialisation

en :

```rust
None
```

ou :

```rust
Vec::new()
```

### Propagation par `Result`

Les extracteurs d'infrastructure doivent systématiquement retourner :

```rust
Result<Option<T>, LyxalSurrealError>
```

ou :

```rust
Result<Vec<T>, LyxalSurrealError>
```

---

## 11.5. Isolation du Domaine & Emplacement Restreint de `raw_query()`

### Visibilité de `raw_query()`

La méthode :

```rust
raw_query()
```

doit être restreinte :

```rust
pub(crate)
```

et réservée :

* au Module Runtime ;
* à l'installation de schémas/fonctions ;
* aux migrations ;
* aux tests.

### Domaines Découplés

La couche de transport :

```text
db.rs
```

ne contient aucune logique métier.

Les opérations de domaine consomment des types natifs SurrealDB :

```rust
RecordId
Datetime
```

et communiquent exclusivement via :

```rust
store.call_fn(...)
```

---

# 📦 12. Structure & Conventions des Modèles de Domaine (`models/`)

## 12.1. Arborescence Modulaire par Domaine

Tout module métier Lyxal OS organise ses structures Rust sous :

```text
models/
```

découpé par sous-domaines.

Exemple :

```text
models/
├── account.rs
├── calendar.rs
├── booking.rs
├── types.rs
└── mod.rs
```

`models/mod.rs` re-exporte publiquement les modèles de domaine et DTOs.

Cela garantit la stabilité des chemins d'import :

```rust
use crate::models::Booking;
```

---

## 12.2. Alias de Types Natifs SDK

Les identifiants et horodatages utilisent les alias natifs de la plateforme.

Exemples :

```rust
BookingRecordId
BookingDatetime
```

définis dans :

```text
models/types.rs
```

---

## 12.3. Ségrégation de Visibilité & Masquage des Secrets (`pub(crate)`)

### Modèles Publics

Ils ne contiennent :

* ni ciphertext ;
* ni `password_hash`.

Ils sont re-exportés avec :

```rust
pub use
```

### Structures de Persistance Internes

Elles sont définies :

```rust
pub(crate)
```

et re-exportées avec :

```rust
pub(crate) use
```

dans :

```text
models/mod.rs
```

Elles ne dérivent **JAMAIS `Serialize`**.

### Redaction `Debug`

Tous les secrets et hashs doivent être masqués dans les représentations `Debug`.

Exemple :

```text
[REDACTED]
```

---

## 12.4. Projections SurrealQL des Booléens de Statut (`*_configured`)

Les statuts d'existence de secrets :

```text
oidc_client_secret_configured
password_configured
oauth_configured
```

sont calculés dynamiquement dans la fonction SurrealQL projeteuse :

```text
fn::<module>_<action>
```

puis désérialisés dans le modèle Rust.

---

## 12.5. Remplacement des Tuples par des Structures Nommées

Les retours de fonctions SurrealQL doivent être désérialisés dans des structures nommées et typées :

```rust
#[derive(Debug, Deserialize)]
```

Les tuples anonymes tels que :

```rust
Vec<(String, String, ...)>
```

sont interdits pour les contrats publics de domaine.

---

# 🧭 13. Checklist Obligatoire Antigravity

Avant toute implémentation, Antigravity doit vérifier les points suivants.

## Architecture

* [ ] La responsabilité appartient-elle réellement au module ?
* [ ] Existe-t-elle déjà dans `lyxal_core` ?
* [ ] Existe-t-elle déjà dans un autre module ?
* [ ] La modification introduit-elle une dépendance circulaire ?
* [ ] La frontière SurrealQL / Rust est-elle respectée ?

## Core

* [ ] `validation` a été vérifié.
* [ ] `sanitize` a été vérifié.
* [ ] `security` a été vérifié.
* [ ] `utils` a été vérifié.
* [ ] Aucune primitive Core n'est dupliquée localement.

## SurrealQL

* [ ] Signature publique conforme.
* [ ] `$params: object` unique.
* [ ] Retour `result_ok` / `error_result`.
* [ ] `COMMENT` présent.
* [ ] Fonction inférieure à environ 300 lignes.
* [ ] Tests prévus.

## Rust

* [ ] `XxxParams` défini.
* [ ] `XxxResult` défini.
* [ ] Wrapper `store.call_fn(...)`.
* [ ] Aucune logique métier dupliquée.
* [ ] Aucun `panic!`.
* [ ] Aucun secret exposé.
* [ ] Aucun `raw_query()` métier.

## Error

* [ ] Codes d'erreurs identifiés.
* [ ] Préfixe du module respecté.
* [ ] Master data prévue.
* [ ] Aucune erreur silencieuse.

## Events (lyxal_event)

* [ ] Le module émetteur ne référence aucun module consommateur (zéro couplage).
* [ ] Les `DEFINE EVENT` SurrealDB passent exclusivement par `fn::event_publish`.
* [ ] Les structures d'événements implémentent `lyxal_event::Event` (`EVENT_TYPE`).
* [ ] Les handlers consommateurs implémentent `Handler<E>` et `EventConsumerModule`.
* [ ] L'idempotence du handler de domaine est garantie (transport At-Least-Once).
* [ ] Les abonnements persistants `EventSubscription` sont déclarés.
* [ ] Aucune erreur de handler n'est masquée silencieusement.

## Cryptographie (`lyxal_crypto`)

* [ ] Toute opération crypto utilise exclusivement `lyxal_crypto`.
* [ ] Aucune crate crypto (`argon2`, `hmac`, `sha2`, `blake3`, `aes-gcm`, `hkdf`) n'est importée directement dans le module métier.
* [ ] Les mots de passe sont hashés via `lyxal_crypto::password`.
* [ ] Les signatures HMAC passent par `lyxal_crypto::hmac`.
* [ ] Les secrets chiffrés utilisent `CryptoEngine` avec `SecretContext` et `EncryptedEnvelope`.
* [ ] Aucun `rand::thread_rng()` — uniquement `rand_core::OsRng`.
* [ ] Si un besoin crypto non couvert est identifié : signalé au CTO, **aucune implémentation avant validation**.

## Validation CTO

* [ ] `implementation_plan.md` rédigé.
* [ ] Fonctions Core réutilisées documentées.
* [ ] Fonctions nouvelles documentées.
* [ ] Éventuels besoins Core signalés.
* [ ] Éventuels besoins crypto signalés.
* [ ] Validation explicite du CTO obtenue.

> Tant que cette checklist n'est pas satisfaite et que le CTO n'a pas validé le plan, **aucune implémentation applicative ne doit commencer**.

---

# 🏁 14. Règle Finale

L'architecture Lyxal OS suit la hiérarchie suivante :

```text
┌───────────────────────────────────────────┐
│               LYXAL CORE                  │
│ validation · sanitize · security · utils  │
└─────────────────────┬─────────────────────┘
                      │
                      ▼
┌───────────────────────────────────────────┐
│             NOYAU TECHNIQUE               │
│ error · surreal · crypto · event · auth   │
└─────────────────────┬─────────────────────┘
                      │
                      ▼
┌───────────────────────────────────────────┐
│              MODULES MÉTIERS              │
│ booking · crm · documents · btp · etc.    │
└─────────────────────┬─────────────────────┘
                      │
                      ▼
┌───────────────────────────────────────────┐
│             UI / INTERFACES               │
│ Web · Mobile · CLI · API                  │
└───────────────────────────────────────────┘
```

Chaque responsabilité doit avoir **un propriétaire unique**.

Chaque module doit utiliser les contrats publics des couches inférieures sans connaître leur implémentation interne.

Chaque primitive générique existante doit être réutilisée depuis `lyxal_core`.

Chaque logique métier reste dans son module propriétaire.

Chaque interaction inter-module respecte les contrats publics ou le bus d'événements.

Chaque modification est planifiée et validée avant implémentation.

> **LYXAL CORE fournit les briques.
> SURREALQL porte le métier lié aux données.
> RUST porte les capacités système et protocolaires.
> LYXAL EVENT orchestre.
> LES MODULES composent.
> L'UI présente.**

---

# 🎨 15. Charte d'Extension UI & Console (`surrealist`) — Lyxal OS

Pour toute extension ou adaptation de l'interface graphique (basée sur le fork Surrealist v3.9.x), les règles suivantes sont strictement obligatoires :

### 15.1. Respect Strict du Design System & Stack Existante
* **Framework UI & Composants** : Utiliser exclusivement Mantine v9 (`@mantine/core`, `@mantine/hooks`, `@mantine/notifications`). Aucun framework CSS tiers (ex: Tailwind) ne doit être introduit.
* **Iconographie Unifiée** :
  - Consommer les icônes officielles `@surrealdb/ui` (ex: `iconCog`, `iconDatabase`, `iconPlus`).
  - Pour toute icône supplémentaire (ex: unités, référentiels), utiliser les chemins vectoriels SVG MDI issus de `@mdi/js` (ex: `mdiRuler`, `mdiShapeOutline`) rendus via le composant canonique `<Icon path={...} />`.
* **Thématisation & Design Tokens** :
  - L'interface supporte nativement les modes Clair (Light) et Sombre (Dark).
  - Interdiction d'utiliser des couleurs CSS codées en dur (`#ffffff`, `black`, etc.).
  - Utiliser systématiquement les variables Mantine (`var(--mantine-color-...)`) ou les classes CSS Modules (`style.module.scss`).

### 15.2. Frontière Données & Consommation SurrealQL
* **Pas de logique métier dans l'UI** : L'UI est un pur récepteur de présentation.
* **Consommation exclusive des fonctions SurrealQL publiques** :
  - Toute action de mutation ou lecture de données métier consomme les fonctions `fn::<module>_<action>` (ex: `fn::unite_type_create`, `fn::unite_create`).
  - L'UI ne doit jamais forger de requêtes complexes `UPDATE`/`DELETE` ad-hoc en direct si une fonction métier SurrealQL est définie.
* **Gestion du Cache & État** : Utiliser `@tanstack/react-query` pour les requêtes asynchrones et invalidations de cache (`useQuery`, `useMutation`, `useQueryClient`).
* **Contrat de retour universel** :
  - Traitement systématique du standard Lyxal : `fn::result_ok($data)` et `fn::error_result($code, $language, $details)`.
  - Notification contextuelle d'erreur utilisateur via `@mantine/notifications` en exploitant le message d'erreur résolu.

### 15.3. Structure Modulaire des Écrans Métiers
* Les vues et paramètres spécifiques à Lyxal OS sont isolés dans des modules dédiés (ex: `src/screens/surrealist/pages/Connection/settings/tabs/referentials.tsx`).
* Tout ajout d'onglet dans les paramètres respecte la chaîne de typage :
  1. `src/types.tsx` (`ConnectionSettingsTab`, `ConnectionView`)
  2. `src/constants.tsx` (`CONNECTION_SETTINGS_TABS`, `CONNECTION_SETTINGS_TAB_LABELS`, `SETTINGS_VIEWS`)
  3. `src/screens/surrealist/pages/Connection/sidebar.tsx` (`ALWAYS_SETTINGS_TABS`)
  4. `src/screens/surrealist/pages/Connection/index.tsx` (`SETTINGS_COMPONENTS`, `SETTINGS_VIEW_COMPONENTS`)

