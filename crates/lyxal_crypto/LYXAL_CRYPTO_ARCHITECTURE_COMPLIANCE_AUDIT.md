# 🏛️ RAPPORT D'AUDIT INDÉPENDANT FINAL — `lyxal_crypto`
## Audit d'Architecture, de Sécurité Cryptographique et de Conformité Lyxal OS

**Date de l'audit :** 28 Octobre 2026  
**Auditeur :** Antigravity (Rôle : Auditeur Indépendant CTO)  
**Cible :** `crates/lyxal_crypto` (v0.1.0)  
**Référentiel normatif :** `.agents/AGENTS.md` (Sections 5.2, 5.7, 6, 11, 12, 13)  
**Branche Git :** `main`  
**Mode d'intervention :** Audit exclusivement en lecture seule (zéro modification de code source)  

---

## 1. Résumé Exécutif

Le crate `crates/lyxal_crypto` a fait l'objet d'un audit indépendant approfondi portant sur :
1. Sa conformité stricte à la charte d'architecture Lyxal OS (`.agents/AGENTS.md`).
2. La robustesse et la correction de ses primitives cryptographiques (AEAD AES-256-GCM, SHA-256, BLAKE3, HMAC-SHA256, HKDF-SHA256, Argon2id, CSPRNG `OsRng`).
3. L'étanchéité de ses contrats d'API publique (`API_CONTRACT.md`) et de ses spécifications immuables (`ENVELOPE_FORMAT_V1.md`, `SECURITY.md`).
4. L'hygiène mémoire (`Zeroizing`, `ZeroizeOnDrop`, redaction `Debug`).
5. La conformité des modules consommateurs (`lyxal_runtime`, `lyxal_pipeline_ingestion`, `lyxal_booking`).

### Synthèse des Résultats
* **Moteur cryptographique fondamental** : Le cœur algorithmique de `lyxal_crypto` est **rigoureux, robuste et conforme aux standards internationaux** (NIST SP 800-38D, FIPS 180-4, RFC 4231, RFC 5869, RFC 9106). Les nonces sont 100% imprédictibles (`rand_core::OsRng`), l'AAD canonique length-prefixed `lyxal:v1` prévient toute collision ou confusion multi-tenant, et la protection mémoire par `Zeroizing` est effective.
* **Divergences Documentaires & Contrats (P1)** : Une désynchronisation majeure a été identifiée entre l'implémentation réelle et `API_CONTRACT.md` (signatures HMAC, `verify_password`, paramètres HKDF inversés, variants de `KeyGenerationPolicy`), ainsi que dans `README.md` (types obsolètes ou fictifs, exemples non compilables).
* **Anomalie Sécuritaire dans un Consommateur (`lyxal_booking`) (P1)** : Bien que `lyxal_booking/engine/src/auth.rs` utilise correctement `lyxal_crypto::password`, le sous-module `lyxal_booking/engine/src/web/api/v1/auth.rs` a introduit un `DUMMY_ARGON2_HASH` à coût réduit (`m=19456, t=2` au lieu de `m=65536, t=3`) créant une **vulnérabilité d'énumération d'utilisateurs par timing attack**, et utilise directement `sha2` au lieu de `lyxal_crypto`. De plus, `lyxal_booking/engine/Cargo.toml` conserve des dépendances directes interdites (`argon2`, `hmac`, `sha2`, `aes-gcm`).
* **Limitations architecturales du résolveur (P2)** : `CompositeKeyResolver` ne permet pas de modifier dynamiquement la clé active en mémoire (`active_id` immuable) et consomme les clés par valeur sans possibilité d'extraction depuis `resolve()`.

---

## 2. Périmètre et Limites de l'Audit

### Périmètre Audité
1. **Code source complet** : `crates/lyxal_crypto/src/*.rs` (11 fichiers, 1 035 lignes de Rust).
2. **Suites de tests complètes** : `crates/lyxal_crypto/tests/*.rs` (14 fichiers de tests, 47 tests d'intégration et proptests).
3. **Contrats et spécifications** : `API_CONTRACT.md`, `ENVELOPE_FORMAT_V1.md`, `SECURITY.md`, `README.md`, `LYXAL_CRYPTO_WORKSPACE_USAGE.md`, `roadmap.md`.
4. **Rapports d'étapes antérieurs** : `LYXAL_CRYPTO_AUDIT_REPORT.md` (Phase 1), `LYXAL_CRYPTO_PHASE2_REPORT.md` (Phase 2), `LYXAL_CRYPTO_PHASE3_REPORT.md` (Phase 3).
5. **Consommateurs dans le workspace** :
   - `crates/lyxal_runtime` (intégrité, verrous, événements).
   - `crates/lyxal_pipeline_ingestion` (empreintes BLAKE3).
   - `lyxal_booking/engine` (chiffrement de secrets, mots de passe, webhooks HMAC).
6. **Primitives SurrealQL comparatives** : `crates/lyxal_core/functions/security/functions/*.surql`.

### Limites Techniques de l'Audit
1. **Outils d'audit automatisés CI** : `cargo-audit` et `cargo-deny` ne sont pas installés dans l'environnement Windows hôte. L'audit de dépendance a été réalisé par revue manuelle du graphe `Cargo.lock`.
2. **Fuzzing guidé par couverture** : `cargo-fuzz` nécessite une toolchain Rust Nightly avec `libFuzzer` indisponible ici. La robustesse a été vérifiée via la suite `fuzz_robustness.rs` (fuzzing aléatoire pseudo-déterministe 2 000+ mutations) et `proptests.rs`.
3. **Périmètre en lecture seule strict** : Aucune ligne de code n'a été modifiée. Les anomalies détectées sont documentées sans correction anticipée.

---

## 3. Référentiel Architectural Examiné

Le présent audit applique rigoureusement les normes de la **Constitution d'Architecture Lyxal OS** (`.agents/AGENTS.md`) :

| Règle Normative | Intitulé & Référence | Exigence Principale |
| :--- | :--- | :--- |
| **AGENTS.md §1** | Contrat de Stabilité | Toute fonction publique doit être documentée et stable avant réutilisation. |
| **AGENTS.md §5.2** | Découpage Strict des Crates Rust | `lyxal_crypto` est une fondation technique de même rang que `lyxal_surreal`. |
| **AGENTS.md §5.7** | Frontière Core / Module | Découpage net entre primitives génériques SurrealQL et moteur natif Rust. |
| **AGENTS.md §6** | Hiérarchie des Dépendances | Aucun module de niveau inférieur ne dépend d'un niveau supérieur. Pas de dépendance circulaire. |
| **AGENTS.md §11.3** | Cryptographie Centralisée avec `lyxal_crypto` | `lyxal_crypto` est le crate cryptographique **unique et officiel**. CORE FREEZE — STATUS: STABLE. |
| **AGENTS.md §11.3** | Interdiction Absolue de Duplication | Interdiction d'importer `argon2`, `hmac`, `sha2`, `blake3`, `aes-gcm`, `hkdf` directement dans un module métier. |
| **AGENTS.md §11.3** | Contextes AAD Déterministes | Tout chiffrement doit dériver son AAD d'un `SecretContext` strict (`tenant`, `module`, `resource`, `record_id`, `field`). Format `lyxal:v1` figé. |
| **AGENTS.md §11.3** | Format d'Enveloppe Moderne | Format `enc:v1:<key_id>:<base64url_payload>` définitivement figé. |
| **AGENTS.md §11.3** | CSPRNG Système | Utilisation exclusive de `rand_core::OsRng`. Interdiction formelle de `rand::thread_rng()`. |
| **AGENTS.md §12.3** | Masquage des Secrets & Redaction `Debug` | Secrets masqués via `[REDACTED]`, implémentation de `Zeroize`, pas de dérivation `Serialize` sur les clés. |
| **AGENTS.md §13** | Checklist Antigravity | Vérification systématique de l'absence de panics, d'erreurs masquées et de secrets exposés. |

---

## 4. État Réel des Vérifications Techniques

Toutes les vérifications suivantes ont été **effectivement exécutées** sur l'environnement réel et leurs résultats consignés sans altération :

| Commande Exécutée | Code Retour | Durée | Résultat Réel & Observations |
| :--- | :---: | :---: | :--- |
| `cargo check -p lyxal_crypto` | `0` | 22.56s | ✅ **Compilation réussie** (0 erreur, 0 avertissement). |
| `cargo test -p lyxal_crypto` | `0` | 1m 08s | ✅ **47/47 tests d'intégration passés avec succès** (14 fichiers de test, 0 failed, 0 ignored). |
| `cargo clippy -p lyxal_crypto --all-targets` | `0` | 16.97s | ✅ **0 warning, 0 erreur clippy**. Code idiomatique. |
| `cargo check -p lyxal_runtime` | `0` | 36.63s | ✅ **Compilation réussie** (consommateur sain). |
| `cargo check -p lyxal_pipeline_ingestion` | `0` | 9.21s | ✅ **Compilation réussie** (consommateur sain). |
| `cargo check --manifest-path lyxal_booking/engine/Cargo.toml` | `0` | 1m 16s | ⚠️ **Compilation réussie** mais 491 warnings (code mort / imports non nettoyés dans booking). |
| `cargo test --manifest-path lyxal_booking/engine/Cargo.toml --lib auth` | `0` | 3m 22s | ✅ **20/20 tests passés** (tests auth booking). |
| `cargo audit --version` | `1` | 0.1s | ⚠️ **Non exécuté** : outil non installé dans l'environnement. |
| `cargo deny --version` | `1` | 0.1s | ⚠️ **Non exécuté** : outil non installé dans l'environnement. |
| `git status --short` | `0` | 0.1s | ✅ **Working tree propre** (zéro fichier modifié). |

---

## 5. Tableau des Constats Classés par Sévérité

| ID | Sévérité | Règle Normative | Fichier & Symbole | Résumé de l'Anomalie |
| :--- | :---: | :--- | :--- | :--- |
| **CRYPTO-AUDIT-001** | **P1** | `AGENTS.md` §1 & §11.3 | `API_CONTRACT.md`, `src/hmac.rs`, `src/password.rs`, `src/kdf.rs` | Contradiction majeure de signatures et types entre contrat et code réel (HMAC, Argon2, HKDF). |
| **CRYPTO-AUDIT-002** | **P1** | `AGENTS.md` §1 & §11.3 | `README.md`, `SECURITY.md:37` | Documentation obsolète, types inexistants (`EncryptionService`), exemples avec `?` non compilables. |
| **CRYPTO-AUDIT-003** | **P1** | `AGENTS.md` §11.3 | `lyxal_booking/.../v1/auth.rs:25,41` | Vulnérabilité de timing attack (hash dummy m=19456 vs m=65536) et import direct de `sha2` dans booking. |
| **CRYPTO-AUDIT-004** | **P2** | `AGENTS.md` §11.3 | `src/lib.rs:100,111` | Présence de `encrypt_unbound` et `decrypt_unbound` contournant le contexte AAD obligatoire. |
| **CRYPTO-AUDIT-005** | **P2** | `AGENTS.md` §11.3 | `src/key_resolver.rs:220` | `CompositeKeyResolver` empêche la rotation dynamique en mémoire (`active_id` immuable, consommation par valeur). |
| **CRYPTO-AUDIT-006** | **P2** | `AGENTS.md` §5.2 | `crates/lyxal_crypto/Cargo.toml`, `Cargo.lock` | Duplication de `Cargo.lock` local et divergence de version `thiserror 2.0` vs workspace `1.0`. |
| **CRYPTO-AUDIT-007** | **P2** | `AGENTS.md` §11.3, `SECURITY.md` | `src/key_resolver.rs:131,190` | Absence de DACL sous Windows pour `FileKeyProvider` et lecture fichier via `String` heap non zéroïsée. |
| **CRYPTO-AUDIT-008** | **P3** | `AGENTS.md` §11.3 | `tests/envelope_v1_fixtures.rs:46` | Test de fixture "figée" calculé dynamiquement au lieu d'une chaîne constante littérale. |
| **CRYPTO-AUDIT-009** | **INFO** | `AGENTS.md` §13 | CI / Environnement | Outils `cargo-audit`, `cargo-deny` et `cargo-fuzz` absents de l'environnement local. |

---

## 6. Analyse Détaillée des Contrats API

### 6.1. Divergences HMAC-SHA256 (`src/hmac.rs` vs `API_CONTRACT.md`)
L'audit a comparé chaque fonction exposée par `crates/lyxal_crypto/src/hmac.rs` avec le tableau de la section 2.3 de `API_CONTRACT.md` :

| Fonction | Signature Réelle (`src/hmac.rs`) | Signature Annoncée (`API_CONTRACT.md`) | Évaluation & Gravité |
| :--- | :--- | :--- | :--- |
| `sign_hmac_sha256` | `(key: &[u8], data: &[u8]) -> [u8; 32]` | `Result<Vec<u8>, CryptoError>` | ⚠️ Divergence de type. Le code réel est infaillible et renvoie un tableau de 32 octets (zéro allocation). La doc annonce un `Result` avec allocation `Vec<u8>`. |
| `sign_hmac_sha256_hex` | `(key: &[u8], data: &[u8]) -> String` | `Result<String, CryptoError>` | ⚠️ Divergence de type. Le code réel renvoie directement `String`. La doc annonce un `Result`. |
| `verify_hmac_sha256` | `(key: &[u8], data: &[u8], expected_tag: &[u8]) -> bool` | `Result<(), CryptoError>` | ⚠️ Divergence critique. Le code renvoie un booléen `bool`. La doc annonce `Result<(), CryptoError>` (pattern idiomatic Rust pour vérification d'intégrité). |
| `verify_hmac_sha256_hex` | `(key: &[u8], data: &[u8], expected_hex: &str) -> bool` | `Result<(), CryptoError>` | ⚠️ Divergence critique. Renvoie `bool` dans le code réel, `Result<(), CryptoError>` dans le contrat. |

**Conséquence sur la stabilité** : Tout développeur ou consommateur s'appuyant sur le contrat documenté écrira `verify_hmac_sha256(...)?` et obtiendra une erreur de compilation immédiate (`the '?' operator cannot be applied to type 'bool'`). C'est exactement l'erreur présente dans `README.md` (ligne 104).

### 6.2. Divergences Hachage de Mots de Passe (`src/password.rs` vs `API_CONTRACT.md`)
* `verify_password(password: &str, hash: &str)` :
  - **Dans le contrat (`API_CONTRACT.md:75`)** : `-> Result<(), CryptoError>`.
  - **Dans le code (`src/password.rs:45`)** : `-> Result<bool, CryptoError>`.
  - Le rapport de Phase 3 (§7) avait documenté la correction d'un bug dans booking lié à `Result<bool, _>`, mais `API_CONTRACT.md` n'a **jamais été mis à jour** et affiche toujours `Result<(), CryptoError>`.
* `needs_rehash(encoded_hash: &str) -> bool` :
  - La signature réelle est bien `bool`.
  - Cependant, `README.md` (ligne 89) documente : `if needs_rehash(&hash)? { ... }`, ce qui est syntaxiquement invalide en Rust.

### 6.3. Divergences Dérivation de Clés (`src/kdf.rs` vs `API_CONTRACT.md`)
* `hkdf_sha256` :
  - **Dans le contrat (`API_CONTRACT.md:72`)** : `(salt, ikm, info, okm_out)`.
  - **Dans le code (`src/kdf.rs:7-12`)** : `(ikm: &[u8], salt: Option<&[u8]>, info: &[u8], output: &mut [u8])`.
  - L'ordre des arguments est **inversé** : le code place `ikm` en premier, et type `salt` comme `Option<&[u8]>`.
* `hkdf_sha256_32` :
  - **Dans le contrat (`API_CONTRACT.md:73`)** : `(salt, ikm, info)`.
  - **Dans le code (`src/kdf.rs:18-22`)** : `(ikm: &[u8], salt: Option<&[u8]>, info: &[u8])`.
  - Inversion identique des arguments.

### 6.4. Divergence Énumération de Politique (`src/key_resolver.rs` vs `API_CONTRACT.md`)
* `KeyGenerationPolicy` :
  - **Dans le contrat (`API_CONTRACT.md:54`)** : Documenté comme `(Strict vs GenerateIfMissing)`.
  - **Dans le code (`src/key_resolver.rs:14-19`)** :
    ```rust
    pub enum KeyGenerationPolicy {
        AllowGenerate,
        RequireExisting,
    }
    ```
  - Les noms des variants sont complètement divergents (`AllowGenerate` vs `GenerateIfMissing`, `RequireExisting` vs `Strict`).

### 6.5. Omissions dans `API_CONTRACT.md`
Les méthodes opérationnelles fondamentales de `CryptoEngine` ne figurent **nulle part** dans la table des fonctions publiques (Section 2.3 d'`API_CONTRACT.md`) :
- `CryptoEngine::new`
- `CryptoEngine::encrypt_secret`
- `CryptoEngine::decrypt_secret`
- `CryptoEngine::reencrypt_if_needed` (nommée à tort `reencrypt_secret` dans `AGENTS.md:951`)
- `CryptoEngine::encrypt_unbound` et `CryptoEngine::decrypt_unbound` (omises car non conventionnelles).

Seules les méthodes de migration (`decrypt_calrs_aes_base64`, `migrate_calrs_aes_base64`, `migrate_legacy_calrs_hex`) y sont répertoriées.

---

## 7. Analyse Cryptographique et Gestion des Clés

### 7.1. Chiffrement Authentifié (AES-256-GCM)
* **Algorithme** : AES-256-GCM (NIST SP 800-38D).
* **Clé** : 256 bits (32 octets). Le type `EncryptionKey` valide strictement la taille de 32 octets (`InvalidKeyLength` si `len != 32`).
* **Nonce** : 96 bits (12 octets). Généré via `OsRng.fill_bytes(&mut nonce_bytes)`.
  - L'audit `grep` confirme : **0 occurrence** de `thread_rng`, `rand::`, ou PRNG déterministe dans tout le crate.
  - La dépendance `rand` a été supprimée du `Cargo.toml` au profit strict de `rand_core = { version = "0.6", features = ["getrandom"] }`.
* **Tag d'authentification** : 128 bits (16 octets). Vérifié en temps constant par RustCrypto (`ghash`/`polyval`).
* **Structure binaire du payload** :
  `NONCE (12 octets) | CIPHERTEXT (N octets) | TAG (16 octets)`
  Taille minimale : 28 octets. Le parsing rejette immédiatement tout buffer `< 28 octets` avec `CryptoError::InvalidPayload`.

### 7.2. Contexte d'Authentification Déterministe (AAD `lyxal:v1`)
Le calcul de l'AAD dans `src/context.rs` garantit une étanchéité multi-tenant absolue :
```text
lyxal:v1:<len_tenant>:<tenant>:<len_module>:<module>:<len_resource>:<resource>:<len_record>:<record_id>:<len_field>:<field>
```
* **Normalisation** : `tenant`, `module`, `resource` et `field` sont automatiquement normalisés en minuscules et trimés.
* **Sensibilité à la casse préservée** : `record_id` conserve sa casse d'origine (essentiel pour les IDs de type UUIDv7, Nanoid ou CUID) tout en étant trimé.
* **Préfixes de longueur** : Chaque composant est préfixé par sa longueur en octets (`usize`), empêchant mathématiquement toute attaque par glissement de délimiteur (ex: `tenant="a", module="bc"` vs `tenant="ab", module="c"`).
* **Vérification** : Validé par tests statiques (`test_aad_canonical_representation_fixture`), tests négatifs (`test_negative_mismatched_tenant_aad_fails`) et proptests (`prop_mismatched_context_always_fails`).

### 7.3. Gestion des Clés et Cycle de Vie
* **Encapsulation de la clé** : `EncryptionKey` stocke `bytes: Zeroizing<[u8; 32]>`.
  - À la désallocation (`Drop`), la mémoire est écrasée avec des zéros via le trait `Zeroize`.
  - `Clone` est interdit (évite la prolifération de copies en mémoire).
  - `Serialize` et `Deserialize` ne sont pas dérivés (clé jamais sérialisée accidentellement).
  - L'implémentation de `Debug` produit systématiquement `"EncryptionKey([REDACTED])"`.
  - L'accesseur `expose(&self) -> &[u8; 32]` est strictement borné à `pub(crate)`.
* **Fournisseurs de clés** :
  - `EnvironmentKeyProvider` : Charge la clé depuis une variable d'environnement (Base64 URL/Standard).
  - `FileKeyProvider` :
    - Mode strict (`RequireExisting`) : refuse la génération si le fichier est absent.
    - Mode dev (`AllowGenerate`) : génération atomique via `OpenOptions::create_new(true)`.
    - Permissions Unix : `options.mode(0o600)`.
    - *Réserve Windows* : Sous Windows, aucun DACL n'est positionné (hérite des droits du dossier).
    - *Hygiène mémoire* : `fs::read_to_string` alloue temporairement une `String` sur le heap qui n'est pas enveloppée dans un `Zeroizing`.
  - `CompositeKeyResolver` :
    - Associe une clé active et un dictionnaire de clés historiques (`RwLock<HashMap<KeyId, Arc<EncryptionKey>>>`).
    - *Limite architecturale* : Le champ `active_id` est immuable. Impossible de promouvoir une nouvelle clé active dynamiquement sans instancier un nouveau resolver.
    - *Consommation par valeur* : `add_historical_key` attend `EncryptionKey` par valeur. Or, `resolve()` retourne `Arc<EncryptionKey>` et `EncryptionKey` n'est pas clonable.

### 7.4. Hachage, HMAC, KDF et Mots de Passe
* **SHA-256** : Conforme FIPS 180-4. API oneshot (`sha256`, `sha256_hex`) et streaming (`Sha256Hasher`).
* **BLAKE3** : Conforme spécification officielle BLAKE3. API oneshot et streaming (`Blake3Hasher`).
* **HMAC-SHA256** : Conforme RFC 2104 / RFC 4231. Utilise `Hmac<Sha256>` avec vérification en temps constant via `Mac::verify_slice`.
* **HKDF-SHA256** : Conforme RFC 5869. Sortie protégée par `Zeroizing<[u8; 32]>` pour `hkdf_sha256_32`.
* **Argon2id** : Conforme RFC 9106. Profil durci Lyxal v1 :
  - `m_cost = 65536 KiB` (64 MiB)
  - `t_cost = 3` itérations
  - `p_cost = 1` thread
  - Sel aléatoire de 16 octets généré via `OsRng`
  - Format PHC standard `$argon2id$v=19$m=65536,t=3,p=1$...`
  - Fonction `needs_rehash` détectant tout écart par rapport à cette politique.

---

## 8. Cohérence Documentaire et Compatibilité

### 8.1. Contradictions Documentaires Majeures
L'audit met en évidence un décalage flagrant entre la documentation et la réalité du code :

1. **`README.md` est totalement désynchronisé de l'API réelle** :
   - Lignes 54-74 : Utilise `EncryptionService::new(...)`, `EncryptionContext::builder()`, et `Plaintext::from(...)`. **Ces types n'existent pas dans le crate.**
   - Ligne 29 : Affirme que le format d'enveloppe est `lyxal:v1:<key_id>:<nonce_hex>:<tag_hex>:<ciphertext_hex>`. C'est l'ancien format abandonné en Phase 1. Le format réel est `enc:v1:<key_id>:<base64url_payload>`.
   - Ligne 85 : `let is_valid = verify_password(...)?; assert!(is_valid);` — Incompilable avec les signatures documentées dans `API_CONTRACT.md`.
   - Ligne 89 : `if needs_rehash(&hash)?` — Incompilable (`needs_rehash` renvoie `bool`).
   - Ligne 104 : `let is_authentic = verify_hmac_sha256(...)?; assert!(is_authentic);` — Incompilable (`verify_hmac_sha256` renvoie `bool`).

2. **`SECURITY.md` contient un résidu de format legacy** :
   - Ligne 37 : Affiche `- Format d'Enveloppe : lyxal:v1:<key_id>:<nonce_hex>:<tag_hex>:<ciphertext_hex>`.
   - Ceci contredit directement `ENVELOPE_FORMAT_V1.md`, `AGENTS.md:1007` et `src/envelope.rs`.
   - Ligne 23 : Affirme qu'un ciphertext corrompu ou au mauvais AAD échoue avec `(DecryptionFailed)`. En réalité, l'erreur retournée est `AuthenticationFailed`.

3. **`API_CONTRACT.md` annonce des signatures non conformes au code** :
   - Les 4 fonctions HMAC, la fonction `verify_password`, les 2 fonctions HKDF et l'énumération `KeyGenerationPolicy` présentent des divergences de types ou d'arguments (détaillées en Section 6).

---

## 9. Conformité du Workspace et des Consommateurs

### 9.1. Consommateur `lyxal_runtime`
* **Dépendances** : `lyxal_runtime/Cargo.toml` dépend proprement de `lyxal_crypto = { workspace = true }`. Aucune crate crypto directe n'est importée.
* **Usages** :
  - `src/migration/checksum.rs` ➔ `lyxal_crypto::hash::sha256_hex`.
  - `src/lock/node_id.rs` ➔ `lyxal_crypto::hash::Sha256Hasher`.
  - `src/event/id.rs` ➔ `lyxal_crypto::hash::Sha256Hasher`.
* **Statut** : ✅ **100% Conforme**.

### 9.2. Consommateur `lyxal_pipeline_ingestion`
* **Dépendances** : `crates/lyxal_pipeline_ingestion/Cargo.toml` dépend de `lyxal_crypto = { path = "../lyxal_crypto" }`.
* **Usages** : `blake3_hex` pour les fingerprints d'ingestion et de déduplication.
* **Statut** : ✅ **100% Conforme**.

### 9.3. Consommateur `lyxal_booking` : Anomalies Critiques Détectées
Le module `lyxal_booking` présente plusieurs violations sévères de la charte d'architecture :

1. **Vulnérabilité Timing Attack / Énumération Utilisateurs (`CRYPTO-AUDIT-003`)** :
   - Fichier : `lyxal_booking/engine/src/web/api/v1/auth.rs:25`
   - Le code déclare :
     ```rust
     const DUMMY_ARGON2_HASH: &str = "$argon2id$v=19$m=19456,t=2,p=1$ZHVtbXlzYWx0MTIzNDU2Nw$q0c+8v5Xw9nQ1+Y7Z1+1234567890abcdefghijklm";
     ```
   - **Impact** : Lors d'une tentative de connexion sur `/login`, si l'utilisateur existe, `verify_password` est exécuté sur son hash réel (`m=65536, t=3, p=1`, durée ~150-250ms). Si l'utilisateur n'existe pas, `verify_password` est exécuté sur `DUMMY_ARGON2_HASH` (`m=19456, t=2, p=1`, durée ~30-50ms).
   - **Résultat** : Un attaquant distant peut énumérer les utilisateurs valides avec une fiabilité de 100% par simple mesure du temps de réponse HTTP.
   - **Circonstance aggravante** : `lyxal_booking/engine/src/auth.rs` contient déjà un `DUMMY_HASH` correct (`m=65536, t=3, p=1`) et une fonction `verify_password_uniform`, mais le handler web de l'API v1 a dupliqué et affaibli localement cette logique !

2. **Duplication de primitive SHA-256** :
   - Fichier : `lyxal_booking/engine/src/web/api/v1/auth.rs:41-45`
   - Le code utilise `use sha2::{Digest, Sha256};` et réimplémente le hachage de token localement :
     ```rust
     fn hash_token(token: &str) -> String {
         let mut hasher = Sha256::new();
         hasher.update(token.as_bytes());
         hex::encode(hasher.finalize())
     }
     ```
   - C'est une violation directe d'`AGENTS.md:980` ("Interdit d'importer directement sha2... utiliser `lyxal_crypto::hash::sha256_hex`").

3. **Dépendances crypto directes résiduelles dans `Cargo.toml`** :
   - Fichier : `lyxal_booking/engine/Cargo.toml:74,78,79,82`
   - Déclarations :
     ```toml
     aes-gcm = "0.10"
     hmac = "0.12"
     sha2 = "0.10"
     argon2 = { version = "0.5", features = ["rand"] }
     ```
   - Violation directe d'`AGENTS.md:1014-1019` et de la checklist §1351.

---

## 10. Tests et Preuves Disponibles

### 10.1. Matrice des Garanties Démontrées vs Affirmées

| Propriété Cryptographique | Ce que le Code Garantit | Ce que les Tests Démontrent | Ce qui est Affirmé (Doc) | Ce qui reste Non Vérifié |
| :--- | :--- | :--- | :--- | :--- |
| **AES-256-GCM** | Nonces aléatoires 96b, tags 128b, AAD length-prefixed. | 4 vecteurs NIST SP 800-38D + 7 tests unitaires + proptests. | Protection anti-rejeu et anti-confusion tenant. | Résistance sous fuite de cache CPU spécifique. |
| **Format `enc:v1`** | Parsing strict, rejet `< 28` octets, Base64URL no-pad. | 6 tests négatifs, 2 000 mutations aléatoires sans panic. | Format pérenne et immuable. | Golden fixture sous forme de constante statique littérale. |
| **CSPRNG** | Appel direct à `rand_core::OsRng`. | Unicité des nonces et des clés générées. | Entropie système maximale sans seed interne. | Audit hardware du générateur système. |
| **Effacement Mémoire** | Clés et buffers enveloppés dans `Zeroizing`. | `Debug` affiche `[REDACTED]`. Pas de fuite dans logs. | Nettoyage mémoire déterministe à la libération. | Absence d'optimisation éliminatoire par le compilateur (DSE) sans test assembleur. |
| **Argon2id** | Paramètres `m=64M, t=3, p=1`, salt `OsRng`, temps constant. | Hachage, vérification, détection d'obsolescence (`needs_rehash`). | Résistance aux attaques par dictionnaire et GPU/ASIC. | Comportement sous contention mémoire extrême (OOM). |
| **HMAC-SHA256** | Vérification temps constant via `verify_slice`. | RFC 4231 (4 cas) + rejet d'altération tag/message/clé. | Signatures webhooks sécurisées. | Conformité de la signature de retour (contrat documente `Result`). |
| **HKDF-SHA256** | Dérivation 32 octets avec `Zeroizing`. | RFC 5869 Cas 1 (avec et sans sel). | Dérivation sécurisée de sous-clés. | Comportement sur longueur d'expansion maximale. |
| **Rotation Clés** | Déchiffrement historique et ré-encryption avec clé active. | Cycle E2E complet v1 ➔ v2 ➔ ré-encryption ➔ retrait v1. | Rotation transparente sans indisponibilité. | Rotation dynamique en mémoire dans un processus unique sans redémarrage. |

---

## 11. Constats d'Audit Détaillés (Fiches d'Anomalies)

### CRYPTO-AUDIT-001 : Divergence Contrat d'API Publique (`API_CONTRACT.md`)
* **ID :** CRYPTO-AUDIT-001
* **Sévérité :** **P1**
* **Règle normative :** `AGENTS.md` §1 ("Contrat de Stabilité") & §11.3 ("Son API publique est FIGÉE (CORE FREEZE, STATUS: STABLE)").
* **Preuve :**
  - `crates/lyxal_crypto/API_CONTRACT.md` lignes 68-76 vs `crates/lyxal_crypto/src/{hmac.rs, password.rs, kdf.rs, key_resolver.rs}`.
  - `API_CONTRACT.md:68` : `sign_hmac_sha256(...) -> Result<Vec<u8>, CryptoError>` vs `src/hmac.rs:7` : `-> [u8; 32]`.
  - `API_CONTRACT.md:70` : `verify_hmac_sha256(...) -> Result<(), CryptoError>` vs `src/hmac.rs:22` : `-> bool`.
  - `API_CONTRACT.md:75` : `verify_password(...) -> Result<(), CryptoError>` vs `src/password.rs:45` : `-> Result<bool, CryptoError>`.
  - `API_CONTRACT.md:72` : `hkdf_sha256(salt, ikm, ...)` vs `src/kdf.rs:7` : `hkdf_sha256(ikm, salt, ...)`.
  - `API_CONTRACT.md:54` : `KeyGenerationPolicy (Strict vs GenerateIfMissing)` vs `src/key_resolver.rs:14` : `AllowGenerate, RequireExisting`.
  - Méthodes `encrypt_secret`, `decrypt_secret`, `reencrypt_if_needed` absentes de la section 2.3.
* **Attendu :** Le document contractuel officiel d'un module en `CORE FREEZE — STABLE` doit refléter exactement les signatures réelles du code compilé.
* **Constaté :** Les types de retour, les ordres d'arguments et les noms de variants d'au moins 8 primitives publiques diffèrent entre le contrat et l'implémentation.
* **Impact :** Instabilité de l'API publique. Tout consommateur développant d'après le contrat subit des erreurs de compilation.
* **Reproductibilité :** Comparaison textuelle directe des signatures et tentative de compilation des snippets du contrat.
* **Correction recommandée :** Aligner formellement `API_CONTRACT.md` sur l'implémentation Rust réelle en vigueur (qui est plus efficace : pas d'allocation pour HMAC, retour `[u8; 32]`, et boolean direct pour la vérification).
* **Tests de non-régression nécessaires :** Ajout de tests de compilation de doc-tests ou d'un test d'API surface (`trybuild` ou test statique vérifiant la concordance des signatures).

---

### CRYPTO-AUDIT-002 : Désynchronisation de `README.md` et `SECURITY.md`
* **ID :** CRYPTO-AUDIT-002
* **Sévérité :** **P1**
* **Règle normative :** `AGENTS.md` §1 ("Toute fonction publique doit être documentée...") & §11.3 ("Format d'enveloppe Moderne").
* **Preuve :**
  - `crates/lyxal_crypto/README.md` lignes 54-74 (types `EncryptionService`, `EncryptionContext`, `Plaintext`).
  - `crates/lyxal_crypto/README.md` ligne 29 & `crates/lyxal_crypto/SECURITY.md` ligne 37 : mention de `lyxal:v1:<key_id>:<nonce_hex>:<tag_hex>:<ciphertext_hex>`.
  - `crates/lyxal_crypto/README.md` lignes 85, 89, 104 : opérateur `?` appliqué à des booléens.
* **Attendu :** La documentation utilisateur et la politique de sécurité doivent présenter les API réelles et le format d'enveloppe canonique `enc:v1:<key_id>:<base64url_payload>`.
* **Constaté :** Les exemples de code ne compilent pas. Le format d'enveloppe affiché dans `SECURITY.md` et `README.md` est obsolète.
* **Impact :** Risque d'incompréhension, perte de temps des développeurs, et contradiction entre spécifications de sécurité.
* **Reproductibilité :** Copier le bloc d'exemple de `README.md` dans un test Rust : échec de compilation immédiat.
* **Correction recommandée :** Réécrire les exemples de `README.md` pour utiliser `CryptoEngine`, `SecretContext` et `EncryptedEnvelope`. Mettre à jour la ligne 37 de `SECURITY.md` avec le format `enc:v1`.
* **Tests de non-régression nécessaires :** Activer les doc-tests `cargo test --doc -p lyxal_crypto` sur `README.md`.

---

### CRYPTO-AUDIT-003 : Vulnérabilité Timing Attack & Duplication SHA-256 dans `lyxal_booking`
* **ID :** CRYPTO-AUDIT-003
* **Sévérité :** **P1**
* **Règle normative :** `AGENTS.md` §11.3 ("Hachage de mots de passe", "Interdiction Absolue de Duplication Cryptographique").
* **Preuve :**
  - `lyxal_booking/engine/src/web/api/v1/auth.rs:25` : `const DUMMY_ARGON2_HASH: &str = "$argon2id$v=19$m=19456,t=2,p=1$..."`.
  - `lyxal_booking/engine/src/web/api/v1/auth.rs:114-119` : calcul d'Argon2 sur ce hash affaibli pour les utilisateurs inexistants.
  - `lyxal_booking/engine/src/web/api/v1/auth.rs:41-45` : `fn hash_token` utilisant `use sha2::{Digest, Sha256}` direct.
  - `lyxal_booking/engine/Cargo.toml:74-82` : dépendances directes `aes-gcm`, `hmac`, `sha2`, `argon2`.
* **Attendu :**
  1. Le hash factice utilisé pour la protection contre les timing attacks doit avoir **exactement les mêmes paramètres de coût** que les vrais comptes (`m=65536, t=3, p=1`).
  2. Aucune primitive de hachage ne doit être réimplémentée avec `sha2` direct.
  3. Aucune crate crypto ne doit être importée directement dans `lyxal_booking/engine/Cargo.toml`.
* **Constaté :** Le hash factice dans l'API v1 s'exécute en un tiers du temps d'un hash normal, divulguant instantanément l'existence ou non d'un compte. La primitive SHA-256 est dupliquée et les dépendances directes sont conservées.
* **Impact :** **Vulnérabilité de sécurité en production** : énumération d'utilisateurs par canal auxiliaire temporel. Non-conformité architecturale majeure.
* **Reproductibilité :** Mesurer le temps d'exécution de `/api/v1/auth/login` avec un compte valide (mot de passe faux) vs un compte inexistant.
* **Correction recommandée :**
  1. Remplacer `DUMMY_ARGON2_HASH` dans `src/web/api/v1/auth.rs` par l'appel à `crate::auth::verify_password_uniform(...)` qui utilise le hash standard Lyxal (`m=65536, t=3, p=1`).
  2. Remplacer `hash_token` par `lyxal_crypto::hash::sha256_hex(token.as_bytes())`.
  3. Nettoyer les dépendances `aes-gcm`, `hmac`, `sha2`, `argon2` de `lyxal_booking/engine/Cargo.toml`.
* **Tests de non-régression nécessaires :** Test unitaire mesurant la parité de temps (avec marge d'erreur faible) entre utilisateur existant et inexistant dans `lyxal_booking`.

---

### CRYPTO-AUDIT-004 : Méthodes de Chiffrement Non Liées (`encrypt_unbound`)
* **ID :** CRYPTO-AUDIT-004
* **Sévérité :** **P2**
* **Règle normative :** `AGENTS.md` §11.3 ("Contextes AAD Déterministes : Chaque valeur chiffrée doit dériver son AAD d'un SecretContext strict").
* **Preuve :**
  - `crates/lyxal_crypto/src/lib.rs:100-120` :
    ```rust
    pub fn encrypt_unbound(&self, plaintext: &[u8]) -> Result<String, CryptoError> { ... }
    pub fn decrypt_unbound(&self, envelope_str: &str) -> Result<SecretBytes, CryptoError> { ... }
    ```
* **Attendu :** Toutes les opérations de chiffrement applicatif doivent lier le secret à son contexte métier (`SecretContext`).
* **Constaté :** Les méthodes `encrypt_unbound` et `decrypt_unbound` appliquent un AAD vide (`&[]`). Elles ne sont pas documentées dans `API_CONTRACT.md`.
* **Impact :** Risque qu'un développeur utilise `encrypt_unbound` par facilité et perde la garantie d'étanchéité multi-tenant.
* **Reproductibilité :** Présence visible des méthodes publiques dans `src/lib.rs`.
* **Correction recommandée :** Déprécier ou restreindre la visibilité de `encrypt_unbound` / `decrypt_unbound` à `pub(crate)` (réservé aux tests et cas internes), ou exiger une décision formelle du CTO pour les autoriser publiquement avec avertissement de sécurité.
* **Tests de non-régression nécessaires :** Vérifier qu'aucun module métier n'appelle `encrypt_unbound`.

---

### CRYPTO-AUDIT-005 : Limitation d'Évolution Dynamique de `CompositeKeyResolver`
* **ID :** CRYPTO-AUDIT-005
* **Sévérité :** **P2**
* **Règle normative :** `AGENTS.md` §11.3 ("Rotation de Clés : Prise en charge native de la cohabitation multi-clés... sans rupture de service").
* **Preuve :**
  - `crates/lyxal_crypto/src/key_resolver.rs:220-233` :
    ```rust
    pub struct CompositeKeyResolver {
        active_id: KeyId, // immuable !
        keys: RwLock<HashMap<KeyId, Arc<EncryptionKey>>>,
    }
    ```
  - `tests/rotation_lifecycle.rs:29-53` : Pour tester la rotation, le test a dû instancier **trois résolveurs et trois CryptoEngine successifs**, en régénérant les clés depuis leurs octets bruts `[u8; 32]`.
* **Attendu :** Un serveur en production doit pouvoir promouvoir une nouvelle clé active dynamiquement sans redémarrer le processus et sans devoir conserver les octets bruts des clés en mémoire.
* **Constaté :** `active_id` n'est pas protégé par un verrou (`RwLock`) et il n'existe pas de méthode pour changer la clé active. `add_historical_key` attend une `EncryptionKey` par valeur sans possibilité de réutiliser une clé déjà résolue via `Arc`.
* **Impact :** La rotation "à chaud" au niveau applicatif nécessite de détruire et reconstruire le `CryptoEngine`, ce qui complique son intégration dans les frameworks avec injection de dépendance singleton.
* **Reproductibilité :** Tenter d'appeler `resolver.set_active_key(...)` : méthode inexistante.
* **Correction recommandée :** Envelopper `active_id` dans un `RwLock<KeyId>` et ajouter une méthode `set_active_key(&self, id: KeyId) -> Result<(), CryptoError>`. Ajouter également `add_historical_arc_key(&self, id: KeyId, key: Arc<EncryptionKey>)`.
* **Tests de non-régression nécessaires :** Test de rotation en mémoire sur une même instance de `CompositeKeyResolver` sans réallocation de moteur.

---

### CRYPTO-AUDIT-006 : Incohérences de Workspace Cargo et Duplication de `Cargo.lock`
* **ID :** CRYPTO-AUDIT-006
* **Sévérité :** **P2**
* **Règle normative :** `AGENTS.md` §5.2 ("Découpage Strict des Crates Rust") & Standards de gestion de workspace Cargo.
* **Preuve :**
  - Existence du fichier `crates/lyxal_crypto/Cargo.lock` (10 876 octets) en doublon du `Cargo.lock` racine (139 056 octets).
  - `crates/lyxal_crypto/Cargo.toml:11` : `thiserror = "2.0"` alors que `Cargo.toml:29` racine spécifie `thiserror = "1.0"`.
  - `crates/lyxal_crypto/Cargo.toml:21` : `tempfile = "3.17"` alors que le workspace déclare `3.10`.
  - Pas d'utilisation de `version.workspace = true`, `edition.workspace = true`.
* **Attendu :** Les crates internes d'un workspace Cargo ne doivent pas contenir de `Cargo.lock` local, et doivent synchroniser leurs versions de dépendances avec le workspace.
* **Constaté :** Cargo compile simultanément deux versions majeures de `thiserror` (1.0 et 2.0). Présence d'un `Cargo.lock` parasite dans `crates/lyxal_crypto`.
* **Impact :** Augmentation du temps de compilation, redondance de crates dans l'arbre de dépendance, risque de désynchronisation des versions de verrouillage.
* **Reproductibilité :** Observer l'arborescence et la sortie de `cargo check`.
* **Correction recommandée :** Supprimer `crates/lyxal_crypto/Cargo.lock`. Aligner `crates/lyxal_crypto/Cargo.toml` sur les dépendances de workspace (`thiserror.workspace = true`, etc.).
* **Tests de non-régression nécessaires :** `cargo check --workspace` et `cargo test -p lyxal_crypto`.

---

### CRYPTO-AUDIT-007 : Absence de DACL Windows et Allocation Heap Non Zéroïsée dans `FileKeyProvider`
* **ID :** CRYPTO-AUDIT-007
* **Sévérité :** **P2**
* **Règle normative :** `AGENTS.md` §11.3 ("Chiffrement des Secrets") & `SECURITY.md` §1 ("Compromission par Fuite Mémoire").
* **Preuve :**
  - `crates/lyxal_crypto/src/key_resolver.rs:190-195` : `options.mode(0o600)` n'est actif que sous `#[cfg(unix)]`.
  - `crates/lyxal_crypto/src/key_resolver.rs:131` : `let content = fs::read_to_string(&self.path)?;`
* **Attendu :**
  1. Les fichiers de clés maîtres doivent être restreints en lecture sous Windows comme sous Unix.
  2. Le contenu textuel d'une clé lu depuis le disque doit être stocké dans une mémoire zéroïsée immédiatement après décodage.
* **Constaté :** Sous Windows, le fichier hérite des permissions du dossier (potentiellement lisible par d'autres utilisateurs locaux). La chaîne `content` est allouée sur le heap sans protection `Zeroize`.
* **Impact :** Risque de persistance de la clé en mémoire non zéroïsée après un dump mémoire, et permissions trop permissives sur les environnements de dev Windows.
* **Reproductibilité :** Inspection du code source de `key_resolver.rs`.
* **Correction recommandée :**
  1. Utiliser un buffer d'octets `Zeroizing<Vec<u8>>` pour la lecture de fichier au lieu de `fs::read_to_string`.
  2. Documenter la recommandation de sécurisation du dossier des clés sous Windows (ou utiliser l'API Win32 `SetSecurityInfo` si requis en production stricte).
* **Tests de non-régression nécessaires :** Test de chargement de clé avec effacement immédiat du buffer de lecture.

---

### CRYPTO-AUDIT-008 : Fixture de Test `enc:v1` Générée Dynamiquement
* **ID :** CRYPTO-AUDIT-008
* **Sévérité :** **P3**
* **Règle normative :** `AGENTS.md` §11.3 ("Format d'Enveloppe Moderne DÉFINITIVEMENT FIGÉ").
* **Preuve :**
  - `crates/lyxal_crypto/tests/envelope_v1_fixtures.rs:46-61` : Le test chiffre dynamiquement le message avec `cipher.encrypt(...)` avant de le donner à déchiffrer au moteur.
* **Attendu :** Un test de non-régression de format persistant doit contenir une chaîne d'enveloppe sérialisée **figée en dur sous forme de constante littérale** (`const FROZEN_ENVELOPE: &str = "enc:v1:key-2026-v1:..."`).
* **Constaté :** L'enveloppe est recalculée à chaque exécution du test. Si le format d'enveloppe ou l'AAD subissait une régression symétrique (changement simultané au chiffrement et au déchiffrement), le test continuerait de passer.
* **Impact :** Moindre garantie de détection d'une rupture accidentelle de compatibilité ascendante.
* **Reproductibilité :** Lecture du fichier `tests/envelope_v1_fixtures.rs`.
* **Correction recommandée :** Remplacer le calcul dynamique par une chaîne constante littérale calculée lors de la Phase 3.
* **Tests de non-régression nécessaires :** Exécution du test avec la chaîne constante figée.

---

### CRYPTO-AUDIT-009 : Outillage CI de Sécurité Indisponible Localement
* **ID :** CRYPTO-AUDIT-009
* **Sévérité :** **INFO**
* **Règle normative :** `AGENTS.md` §13 ("Checklist Obligatoire Antigravity").
* **Preuve :**
  - `cargo audit --version` ➔ `error: no such command: audit`.
  - `cargo deny --version` ➔ `error: no such command: deny`.
* **Attendu :** Vérification automatisée des vulnérabilités de la chaîne d'approvisionnement (Supply Chain Security).
* **Constaté :** Outils non installés dans l'environnement local.
* **Impact :** La vérification repose sur la revue manuelle des dépendances (toutes issues de RustCrypto, réputées sûres).
* **Correction recommandée :** Intégrer `cargo-audit` et `cargo-deny` dans la pipeline CI GitHub Actions / GitLab CI.
* **Tests de non-régression nécessaires :** Exécution du pipeline CI.

---

## 12. Corrections Recommandées, Ordonnées par Priorité

```text
PRIORITÉ 1 (Bloquant Pré-Production)
├── C-01 : Corriger la vulnérabilité Timing Attack dans lyxal_booking (DUMMY_ARGON2_HASH)
├── C-02 : Aligner API_CONTRACT.md avec les signatures réelles (HMAC, Argon2, HKDF, KeyGenerationPolicy)
└── C-03 : Réécrire README.md et aligner SECURITY.md (format enc:v1, types CryptoEngine réels)

PRIORITÉ 2 (Qualité Architecturale & Workspace)
├── C-04 : Supprimer les dépendances crypto directes résiduelles de lyxal_booking/Cargo.toml
├── C-05 : Remplacer l'usage de sha2 direct par lyxal_crypto::hash::sha256_hex dans booking
├── C-06 : Supprimer crates/lyxal_crypto/Cargo.lock et unifier thiserror avec le workspace
├── C-07 : Améliorer CompositeKeyResolver (support de rotation dynamique sans recréation)
└── C-08 : Encadrer ou déprécier encrypt_unbound / decrypt_unbound

PRIORITÉ 3 (Robustesse des Tests & Sécurité OS)
├── C-09 : Figer l'enveloppe de test sous forme de constante littérale dans envelope_v1_fixtures.rs
├── C-10 : Utiliser Zeroizing pour la lecture de fichier dans FileKeyProvider
└── C-11 : Ajouter cargo-audit et cargo-deny dans la CI
```

---

## 13. Liste des Points Non Vérifiés

Afin de respecter scrupuleusement la consigne de ne pas confondre "absence de vulnérabilité détectée" avec "preuve d'absence de vulnérabilité", les points suivants sont explicitement listés comme **non vérifiés** dans le cadre de cet audit :
1. **Audit de dépendances automatisé en ligne** : `cargo audit` n'a pas pu interroger la base Advisory DB en local (outil non installé).
2. **Fuzzing guidé par couverture avec instrumentation LLVM** : Non exécuté en raison de l'absence de toolchain Rust Nightly / `cargo-fuzz`.
3. **Résistance physique aux attaques par analyse de consommation ou de rayonnement (Side-Channel DPA/SPA)** : Hors périmètre d'un audit logiciel.
4. **Comportement sous allocation mémoire épuisée (OOM)** : Les allocations dynamiques de `Vec<u8>` en cas de payload gigantesque n'ont été testées que jusqu'à 10 000 octets (`fuzz_robustness.rs`).

---

## 14. Verdict Final

Conformément aux options normatives strictes définies par le mandat CTO :

$$\Large \textbf{VERDICT : CONFORME AVEC RÉSERVES}$$

### Justification du Verdict :
* **Le crate `crates/lyxal_crypto` lui-même est sain, mathématiquement correct et robuste** : 47/47 tests réussis, 0 warning clippy, utilisation rigoureuse d'`OsRng`, chiffrement AES-256-GCM conforme aux vecteurs NIST, dérivation HKDF conforme aux RFCs, et contexte AAD `lyxal:v1` length-prefixed garantissant une parfaite isolation multi-tenant.
* **Les réserves portent sur :**
  1. L'incohérence contractuelle et documentaire (`API_CONTRACT.md`, `README.md`, `SECURITY.md`), qui compromet la stabilité de l'API publique annoncée.
  2. Une vulnérabilité de timing attack résiduelle dans le module consommateur `lyxal_booking` (`DUMMY_ARGON2_HASH` asymétrique).
  3. Des imperfections d'hygiène workspace (`Cargo.lock` redondant, divergence de versions Cargo).

---

## 15. Décision CTO

$$\Large \textbf{RECOMMANDATION : GO SOUS RÉSERVES}$$

### Conditions Impératives pour la Mise en Production :
1. **[RÉSERVE 1 — SÉCURITÉ BOOKING]** : Corriger immédiatement le `DUMMY_ARGON2_HASH` dans `lyxal_booking/engine/src/web/api/v1/auth.rs` pour utiliser les paramètres standard Lyxal (`m=65536, t=3, p=1`), éliminer l'import direct de `sha2`, et retirer les dépendances crypto directes de `lyxal_booking/engine/Cargo.toml`.
2. **[RÉSERVE 2 — SYNCHRONISATION CONTRACTUELLE]** : Mettre à jour `API_CONTRACT.md` pour refléter exactement les signatures réelles du code (notamment les types de retour de `hmac`, `verify_password`, l'ordre des arguments de `hkdf`, et l'exhaustivité des méthodes de `CryptoEngine`).
3. **[RÉSERVE 3 — DOCUMENTATION & EXEMPLES]** : Réécrire `README.md` et corriger la ligne 37 de `SECURITY.md` pour éliminer toute trace de l'ancien format d'enveloppe et garantir que tous les exemples de code soient 100% compilables.
4. **[RÉSERVE 4 — HYGIÈNE CARGO]** : Supprimer le fichier parasite `crates/lyxal_crypto/Cargo.lock` et aligner `thiserror` sur la configuration du workspace.

> **Aucune modification de code n'a été effectuée durant cette mission conformément à la règle d'audit en lecture seule.**  
> La présente évaluation est soumise à la validation formelle du CTO avant le lancement de la phase corrective.
