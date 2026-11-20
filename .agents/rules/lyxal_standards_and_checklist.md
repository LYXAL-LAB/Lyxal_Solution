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

### Primitives STABLE Disponibles (Architecture V2)

| Primitive | Module | Fonctions & Types Principaux |
| :--- | :--- | :--- |
| **AES-256-GCM & Secrets** | `cipher`, `envelope`, `context`, `secret` | `CryptoEngine::seal`, `CryptoEngine::open`, `EncryptedEnvelope::parse`, `encode`, types sensibles `SecretBytes`, `SecretString` |
| **SHA-256** | `hash` | `sha256()`, `sha256_hex()`, `Sha256Hasher` |
| **BLAKE3** | `hash` | `blake3()`, `blake3_hex()`, `Blake3Hasher` |
| **Argon2id** | `password` | `hash_password()`, `verify_password()`, `PasswordHash::parse`, `PasswordHash::needs_rehash` |
| **TOTP (RFC 6238)** | `totp` | `TotpSecret`, `TotpConfig`, `totp_generate()`, `totp_verify()`, `totp_uri()` |
| **HMAC-SHA256** | `hmac` | `HmacKey`, `sign_hmac_sha256()`, `verify_hmac_sha256()` ; clé d'un protocole externe (webhooks) : `ExternalHmacKey`, `sign_external_hmac_sha256()`, `verify_external_hmac_sha256()` ; HMAC-SHA1 d'un protocole externe, **vérification seulement** (retours Twilio, K8) : `verify_external_hmac_sha1()` |
| **HKDF-SHA256** | `kdf` | `hkdf_sha256()` (retourne `SecretBytes`) |
| **ES256** (jetons des services push, K8) | `signing` | `EcdsaP256SigningKey` (`import_pkcs8`, `generate`, `public_key_uncompressed`, `sign_es256`, `export_pkcs8` pour ranger une clé VAPID générée) ; **signature seulement** (aucune vérification ES256 offerte) |
| **Signatures RSA et Ed25519** (RS256 des jetons push K8 ; P6 b, d) | `signing` | `RsaSigningKey` (`generate(RsaModulusBits)`, `import_pkcs8`, `sign_rs256`, `public_key`, `export_pkcs8` pour le coffre-fort), `RsaPublicKey` (`from_spki_der`, `from_pkcs1_der`, `verify_rs256`), `Ed25519SigningKey` (`generate`, `import_pkcs8`, `sign`, `public_key`, `export_pkcs8` pour le coffre-fort), `Ed25519PublicKey` (`from_bytes`, `verify`) ; calculées par `aws-lc-rs` |
| **DKIM** (RFC 6376, 8301, 8463 ; P6 c) | `dkim` | `DkimBodyHasher` (empreinte `bh=` en flux), `DkimHeaderCanonicalizer` → `DkimSignedData` (en-têtes de `h=` puis en-tête de signature sans `b=`), `DkimSigningKey` (`sign`, `public_key_record_bytes`), `DkimPublicKey` (`from_record`, `verify`) ; `rsa-sha256` et `ed25519-sha256` |
| **Chiffrement Web Push** (RFC 8291, K8) | `webpush` | `webpush_encrypt()` (`aes128gcm` : ECDH P-256 éphémère, HKDF-SHA256, AES-128-GCM), `WEBPUSH_MAX_PLAINTEXT_BYTES`, `WEBPUSH_OVERHEAD_BYTES` |
| **Chiffrement de fichiers en flux** (format v1, P6 i) | `stream` | `StreamKey` (`generate`, `seal` / `open` par `enc:v2`), `StreamEncryptor` (`new`, `update`, `finish`), `StreamDecryptor` (`new`, `plan_range`, `decrypt_segment`), `stream_ciphertext_len()` ; format `STREAM_FORMAT_V1.md` |
| **TLS côté serveur** (P6 a) | `tls` | `TlsCertifiedKey` (`from_pem`, `from_der`), `TlsCertificateStore` (certificats par nom SNI et par défaut, remplacement à chaud), `TlsServerOptions`, `tls_server_config()` (`rustls::ServerConfig`, fournisseur `aws-lc-rs`) ; `rustls` réexporté |
| **Gestion de clés & Trousseaux** | `key`, `key_resolver`, `providers` | `EncryptionKey`, `KeyId`, `KeyRingBuilder`, `KeyRing`, `KeyUse`, `KeyResolver`, `StaticKeyResolver`, `EnvironmentKeyProvider`, `FileKeyProvider` |

### Chiffrement des Secrets

Tous les secrets applicatifs :

* mots de passe ;
* tokens ;
* clés API ;
* données sensibles

sont manipulés sous forme de types sensibles opaques (`SecretBytes`, `SecretString`) et gérés exclusivement via :

```text
lyxal_crypto
```

### Règles d'Usage Obligatoires

1. **Hachage de mots de passe** : utiliser `lyxal_crypto::password::{hash_password, verify_password}` avec `PasswordHash`. Il est interdit d'importer directement `argon2`, `bcrypt` ou toute autre crate de hachage de mots de passe dans un module métier.

2. **Signature HMAC** : utiliser `lyxal_crypto::hmac::{sign_hmac_sha256, verify_hmac_sha256}` avec `HmacKey` (32 octets). Il est interdit d'importer directement `hmac` ou `sha2` dans un module métier pour signer ou vérifier des MACs.

3. **Hachage cryptographique** : utiliser `lyxal_crypto::hash::{sha256, blake3}`. Il est interdit d'importer directement `sha2` ou `blake3` dans un module métier.

4. **Dérivation de clés** : utiliser `lyxal_crypto::kdf::hkdf_sha256` produisant un `SecretBytes`. Il est interdit d'importer directement `hkdf` dans un module métier.

5. **Chiffrement de secrets** : utiliser `CryptoEngine::seal(&secret, &context)` et `CryptoEngine::open(&envelope, &context)` avec `SecretContext` strict et `EncryptedEnvelope`. Il est interdit d'appeler directement les primitives bas niveau de chiffrement dans un module métier.

6. **Types sensibles opaques** : tout secret en mémoire utilise `SecretBytes` ou `SecretString` qui implémentent `ZeroizeOnDrop` et dont le `Debug` est strictement masqué (`[REDACTED]`). L'accès intentionnel se fait via `.expose_secret()`.

7. **CSPRNG** : utiliser `rand_core::OsRng`. Il est interdit d'utiliser `rand::thread_rng()` ou tout PRNG déterministe pour la génération de matériel cryptographique.

8. **Codes TOTP (double facteur)** : utiliser `lyxal_crypto::totp::{TotpSecret, totp_generate, totp_verify, totp_uri}`. Il est interdit d'importer directement `sha1`, `totp-rs` ou toute autre crate TOTP/HOTP dans un module métier.

9. **Notifications push** (décision K8) : jetons VAPID et APNs signés par `lyxal_crypto::EcdsaP256SigningKey::sign_es256`, jeton du compte de service Google par `lyxal_crypto::RsaSigningKey::sign_rs256`, messages Web Push chiffrés par `lyxal_crypto::webpush_encrypt`. Il est interdit d'importer directement `ring`, `p256`, `rsa`, `jsonwebtoken`, `ece` ou toute autre crate de signature ou de chiffrement Web Push dans un module métier.

10. **TLS côté serveur** (décision C7) : toute configuration TLS est construite par `lyxal_crypto::tls_server_config` (TLS 1.2 minimum, pas de 0-RTT, pas de certificat client, fournisseur `aws-lc-rs` explicite) ; les certificats sont remis par `TlsCertifiedKey` et `TlsCertificateStore`. Les hôtes (`apps/*`) peuvent dépendre de `tokio-rustls` pour le seul transport (`TlsAcceptor`, `STARTTLS`), avec `lyxal_crypto::rustls`. Il est interdit d'appeler `rustls::ServerConfig::builder()` (arrêt par `panic!` quand les deux fournisseurs de `rustls` sont compilés) ou de construire une configuration `rustls` hors de `lyxal_crypto`.

11. **Fichiers chiffrés** (décision C9) : un fichier de taille quelconque est chiffré par `StreamEncryptor` / `StreamDecryptor` (format `STREAM_FORMAT_V1.md`) sous une `StreamKey` propre au fichier, scellée par `enc:v2` et rangée dans la fiche du fichier, jamais dans le fichier. Une lecture en flux interrompt sa réponse (connexion fermée) dès qu'un segment échoue, jamais ne la termine comme réussie.

12. **Signatures et clés asymétriques** (décisions C1, C2, C6) : signatures, vérifications et génération de clés RSA et Ed25519 par `lyxal_crypto::RsaSigningKey`, `RsaPublicKey`, `Ed25519SigningKey` et `Ed25519PublicKey` (moteur `aws-lc-rs`, seul moteur asymétrique ; la crate `rsa` n'est jamais utilisée, faille « Marvin »). Une clé privée ne sort de `lyxal_crypto` que par `export_pkcs8`, pour être rangée dans `lyxal_secrets`. Une vérification distingue le format invalide (erreur) de la signature fausse (`false`). Une génération RSA s'exécute hors de la boucle asynchrone (`spawn_blocking`).

13. **DKIM** (décisions C4, C5) : les octets signés (canonicalisation `simple` / `relaxed`, empreinte du corps, données signées sans la valeur `b=`) et la signature ou vérification `rsa-sha256` / `ed25519-sha256` passent par `lyxal_crypto::dkim` (`DkimBodyHasher`, `DkimHeaderCanonicalizer`, `DkimSigningKey`, `DkimPublicKey`) ; la lecture des balises, le choix des en-têtes de `h=`, le DNS et la politique (`t=`, `x=`, `i=`, `l=`) appartiennent aux crates du courrier. Signature en RSA de 2048 bits au moins et en Ed25519 ; vérification RSA de 1024 à 4096 bits (RFC 8301) ; `rsa-sha1` refusé ; `l=` lu, jamais produit. Il est interdit d'utiliser la cryptographie de `mail-auth` ou de recopier la canonicalisation DKIM hors de `lyxal_crypto`.

### Contextes AAD Déterministes

En mode lié (recommandé pour toute donnée multi-tenant et applicative), chaque valeur chiffrée doit dériver son AAD d'un `SecretContext` strict via `SecretContext::with_tenant` :

```text
tenant
module
resource
record_id
field
```

Pour les secrets d'infrastructure globaux dépourvus de contexte d'enregistrement ou de tenant, utiliser exclusivement `SecretContext::global(purpose)`. **Tout chiffrement à AAD vide est formellement interdit.**

### Format d'Enveloppe Canonique V2

Toute nouvelle écriture est scellée directement sous le format canonique V2 :

```text
enc:v2:<key_id>:<base64url_payload>
```

Ce format est documenté dans `crates/lyxal_crypto/ENVELOPE_FORMAT_V2.md`. L'ancien format `enc:v1` est conservé pour mémoire historique et n'est plus produit.

### Interdiction Absolue de Duplication Cryptographique

Il est **strictement interdit** :

* d'importer directement dans un module métier une crate crypto (`argon2`, `hmac`, `sha1`, `sha2`, `blake3`, `aes-gcm`, `hkdf`, `totp-rs`) si la primitive équivalente existe dans `lyxal_crypto` ;
* de déclarer, dans un paquet du workspace autre que `lyxal_crypto`, une dépendance directe vers `aes`, `aes-gcm`, `argon2`, `aws-lc-rs`, `aws-lc-sys`, `blake3`, `chacha20poly1305`, `ece`, `ed25519-dalek`, `hkdf`, `hmac`, `jsonwebtoken`, `mail-auth`, `openssl`, `p256`, `ring`, `rsa`, `rustls`, `sha1`, `sha2`, `totp-rs` ou `tokio-rustls` (permis aux seuls hôtes `apps/*`, pour le transport) ; contrôlé en CI par `scripts/ci/check_crypto_dependencies.py` (décision C12), qui refuse aussi tout appel `ring::`, `aws_lc_rs::` ou `ServerConfig` / `ClientConfig::builder` hors de `lyxal_crypto` ;
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

* X25519 (échange de clés)
* ChaCha20-Poly1305
* Cryptographie post-quantique
* KMS / HSM natif

Ed25519 n'est plus hors scope : signature, vérification et génération de clés sont offertes par `lyxal_crypto` (P6 b, d ; décision C3). X25519, ChaCha20-Poly1305 et l'échange de clés hybride X25519MLKEM768 restent hors scope **comme primitives offertes aux modules**, mais sont permis **à l'intérieur de TLS**, négociés par `rustls` (décision C3).

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

### Écritures SurrealQL filtrées par les permissions

Une écriture refusée par les permissions de table ne lève pas d'erreur : `CREATE` renvoie `[]`,
`UPDATE ONLY` et `DELETE ONLY` renvoient `NONE`. Toute fonction publique qui écrit vérifie donc le
résultat de son écriture principale (`DELETE ... RETURN BEFORE` pour une suppression) et renvoie
`fn::error_result("<MODULE>_WRITE_FORBIDDEN", ...)` au lieu d'annoncer un succès. Les tests du
module l'exercent sous une identité non autorisée.

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

Les retours de fonctions SurrealQL doivent être désérialisés dans des structures nommées et typées (SDK `surrealdb` 3.3 : trait `SurrealValue`, cf. skill `lyxal-surrealdb` §2.6) :

```rust
#[derive(Debug, SurrealValue)]
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
* [ ] Les entrées sont validées, nettoyées et contrôlées par `lyxal_core` (primitives, ou moteur `fn::*_object_execute` / `fn::*_pipeline_execute`) ; aucun validateur générique, pipeline ou schéma réécrit localement ; aucune donnée invalide signalée par `THROW` (`AGENTS.md` §5.7.8).

## SurrealQL

* [ ] Signature publique conforme.
* [ ] `$params: object` unique.
* [ ] Retour `result_ok` / `error_result`.
* [ ] `COMMENT` présent.
* [ ] Fonction inférieure à environ 300 lignes.
* [ ] Écriture principale vérifiée : une écriture filtrée par les permissions renvoie `<MODULE>_WRITE_FORBIDDEN` (§11.4).
* [ ] Tests `tests/*.test.surql` exécutés par `scripts/ci/test_lyxal_modules.py` (cas nominaux, erreurs, identités et permissions) ; chaque fonction publique appelée.

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
* [ ] Le Fencing transactionnel sur `event_stream_lease` est respecté par les fonctions d'avancement.
* [ ] L'avancement de curseur respecte l'invariant de contiguïté sans trou (`fn::event_flush_batch`).
* [ ] Les messages poisons sont transférés atomiquement en DLQ avant toute confirmation de curseur.
* [ ] La reprise post-crash (Crash Recovery) préserve les séquences existantes sans réassignation.

## Cryptographie (`lyxal_crypto`)

* [ ] Toute opération crypto utilise exclusivement `lyxal_crypto`.
* [ ] Aucune crate crypto (`argon2`, `hmac`, `sha1`, `sha2`, `blake3`, `aes-gcm`, `hkdf`, `totp-rs`) n'est importée directement dans le module métier.
* [ ] Les secrets sont manipulés sous forme de types sensibles opaques (`SecretBytes`, `SecretString`).
* [ ] L'accès aux secrets bruts est strictement intentionnel via `.expose_secret()` (zéro fuite en `Debug`).
* [ ] Les mots de passe sont hashés et vérifiés via `lyxal_crypto::password` (`PasswordHash`).
* [ ] Les signatures HMAC passent par `lyxal_crypto::hmac` (`HmacKey` 32 octets).
* [ ] Les secrets chiffrés utilisent `CryptoEngine::seal` / `open` avec `SecretContext` strict (`with_tenant` ou `global`) et `EncryptedEnvelope` (format `enc:v2`).
* [ ] Aucun AAD vide n'est utilisé pour le chiffrement.
* [ ] Aucun `rand::thread_rng()` — uniquement `rand_core::OsRng`.
* [ ] Aucune dépendance directe vers une crate cryptographique ni configuration TLS hors de `lyxal_crypto` (`scripts/ci/check_crypto_dependencies.py` ; `tokio-rustls` permis aux seuls hôtes) ; jamais `rustls::ServerConfig::builder()`.
* [ ] Les fichiers chiffrés utilisent `StreamEncryptor` / `StreamDecryptor` avec une `StreamKey` par fichier scellée par `enc:v2` ; une lecture en flux interrompue au premier segment en échec.
* [ ] Les signatures RSA / Ed25519 et DKIM passent par `lyxal_crypto` (`RsaSigningKey`, `Ed25519SigningKey`, `lyxal_crypto::dkim`) ; aucune clé privée exportée hors du rangement dans `lyxal_secrets` ; une vérification distingue erreur de format et signature fausse.
* [ ] Si un besoin crypto non couvert est identifié : signalé au CTO, **aucune implémentation avant validation**.

## Zéro Dette (régime pré-production, `AGENTS.md` §0)

* [ ] Aucun alias, champ, fonction ou format conservé uniquement pour compatibilité.
* [ ] Toute rupture de contrat est répercutée sur tous les appelants du dépôt dans le même changement.
* [ ] Une seule migration `migrations/0001_initial.surql`, à l'état cible.
* [ ] Aucun code mort ou commenté.
* [ ] Aucun document historique (rapport de clôture/audit/recette passé, changelog non livré, plan déjà exécuté) conservé dans le module.
* [ ] `ROADMAP.md` conservée et mise à jour (évolutions à venir seulement), jamais supprimée.
* [ ] Versions en `0.y.z`.

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

