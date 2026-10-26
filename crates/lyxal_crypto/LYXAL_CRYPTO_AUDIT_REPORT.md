# 🛡️ RAPPORT D'AUDIT TECHNIQUE COMPLET — `lyxal_crypto`

> **Date de l'audit** : 2 Septembre 2026  
> **Cible** : `crates/lyxal_crypto` (v0.1.0)  
> **Auteur** : CTO Assistant / Antigravity System  
> **Statut de l'audit** : ✅ AUDIT COMPLET RÉALISÉ  

---

## 1. Executive Summary

Le crate `lyxal_crypto` est le moteur cryptographique officiel du Noyau Technique de Lyxal OS.

L'audit révèle un module **extrêmement propre, rigoureusement conçu pour la cryptographie symétrique (AEAD AES-256-GCM) et la gestion de clés applicatives**, avec une excellente hygiène mémoire (`Zeroizing`, `Arc<EncryptionKey>`, interdiction de clonage et de sérialisation, `Debug` masqué).

Le module est déjà **fortement et concrètement intégré en production avec `lyxal_booking`** (chiffrement des mots de passe CalDAV/CardDAV, tokens OAuth, client secrets, mots de passe SMTP, secrets Captcha, webhooks HMAC).

### Points Forts
- **Cryptographie Standard** : Utilisation exclusive de `aes-gcm` (RustCrypto) 256 bits avec nonces aléatoires 96 bits et tags 128 bits. Aucune cryptographie maison.
- **Sécurité Multi-Tenant par AAD** : Contexte d'authentification lié (`SecretContext`) sérialisé sous format canonique préfixé par la longueur, interdisant mathématiquement le déchiffrement cross-tenant ou cross-ressource avec une même clé.
- **Gestion Mémoire Exemplaire** : Type `EncryptionKey` non clonable, non sérialisable, mémoire nettoyée à la libération (`zeroize`), types `SecretBytes` et `SecretString` protégés.
- **Rotation et Enveloppes** : Format d'enveloppe explicite et versionné `enc:v1:<key_id>:<base64url>` et support de rotation à chaud via `CompositeKeyResolver` et `reencrypt_if_needed`.
- **Politique Fichier Stricte** : `FileKeyProvider` gère la création atomique avec permissions POSIX `0600` et distingue les modes Dev (`AllowGenerate`) et Production (`RequireExisting`).

### Limites Identifiées & Axes de Progression
- **Périmètre Restreint au Symétrique** : Le crate n'implémente actuellement aucune primitive de hachage standard (SHA-256, BLAKE3), de hachage de mot de passe utilisateur (Argon2id), de signature (Ed25519) ou de dérivation de clé (HKDF/Argon2). `lyxal_runtime` est ainsi obligé de dépendre directement de `sha2`.
- **Absence de Vecteurs de Test NIST/RFC** : Les tests (13/13 réussis) couvrent les roundtrips, les altérations et la rotation, mais manquent de vecteurs officiels NIST SP 800-38D.
- **Absence de Fuzzing & Proptest** : Le parser d'enveloppes et les points d'entrée de déchiffrement n'ont pas encore de suite de fuzzing `cargo-fuzz` ou `proptest`.
- **Workspace Manifest** : Le crate était initialement omis du tableau `workspace.members` du `Cargo.toml` racine.

---

## 2. État du Build & Qualité Rust

| Outil | Commande | Résultat | Remarques |
| :--- | :--- | :---: | :--- |
| **Cargo Check** | `cargo check -p lyxal_crypto` | **0 erreur** | ✅ Compile proprement (après ajout au workspace) |
| **Cargo Test** | `cargo test -p lyxal_crypto` | **13/13 OK** | ✅ 7 tests encryption, 3 key_resolver, 3 migration |
| **Cargo Clippy** | `cargo clippy -p lyxal_crypto --all-targets --all-features -- -D warnings` | **0 warning** | ✅ Code propre et idiomatique |
| **Cargo Fmt** | `cargo fmt --check --manifest-path crates/lyxal_crypto/Cargo.toml` | **Conforme** | ✅ Formatage standardisé appliqué |

---

## 3. Architecture Actuelle

```text
crates/lyxal_crypto/
├── Cargo.toml
├── roadmap.md
├── src/
│   ├── lib.rs              <-- Point d'entrée, CryptoEngine<R>, SecretBytes, SecretString, Migration helpers
│   ├── cipher.rs           <-- Primitives bas niveau AES-256-GCM (encrypt_aes_gcm, decrypt_aes_gcm)
│   ├── context.rs          <-- SecretContext & format canonique AAD anti-collision
│   ├── envelope.rs         <-- Format d'enveloppe enc:v1:<key_id>:<base64url> & parsing
│   ├── error.rs            <-- Enum CryptoError avec thiserror 2.0
│   ├── key.rs              <-- KeyId (ASCII strict) & EncryptionKey (Zeroizing, masqué)
│   └── key_resolver.rs     <-- Trait KeyResolver, EnvironmentKeyProvider, FileKeyProvider, CompositeKeyResolver
└── tests/
    ├── encryption.rs       <-- Tests d'intégration chiffrement / déchiffrement / AAD / altération
    ├── key_resolver.rs     <-- Tests providers, politiques Dev/Strict et rotation
    └── migration.rs        <-- Tests migration Cal.rs legacy (Hex et Base64 brut)
```

---

## 4. Cartographie des Composants

| Fichier | Rôle | Structures / Types Clés | Statut |
| :--- | :--- | :--- | :---: |
| `lib.rs` | Façade principale & Moteur | `CryptoEngine<R>`, `ReencryptResult`, `SecretBytes`, `SecretString` | **TERMINÉ** |
| `cipher.rs` | Chiffrement symétrique AEAD | `encrypt_aes_gcm`, `decrypt_aes_gcm` | **TERMINÉ** |
| `context.rs` | Contexte d'authentification lié (AAD) | `SecretContext` | **TERMINÉ** |
| `envelope.rs` | Encodage et décodage des enveloppes | `EncryptedEnvelope`, `EnvelopeVersion` | **TERMINÉ** |
| `key.rs` | Types fondamentaux de clés | `KeyId`, `EncryptionKey` | **TERMINÉ** |
| `key_resolver.rs` | Résolution et rotation des clés | `KeyResolver`, `EnvironmentKeyProvider`, `FileKeyProvider`, `CompositeKeyResolver` | **TERMINÉ** |
| `error.rs` | Gestion des erreurs typées | `CryptoError` | **TERMINÉ** |

### Statut des Sous-Couches Cryptographiques Standardisées

| Couche | Statut | Commentaire |
| :--- | :---: | :--- |
| `symmetric` | **TERMINÉ** | AES-256-GCM avec AAD et nonces 96-bit |
| `envelope` | **TERMINÉ** | Format `enc:v1:<key_id>:<payload>` |
| `key` | **TERMINÉ** | Zeroize, non clonable, masqué Debug |
| `secret` | **TERMINÉ** | `SecretBytes`, `SecretString` via `Zeroizing` |
| `error` | **TERMINÉ** | Typé, sans fuite d'informations sensibles |
| `random` | **PARTIEL** | Utilise `rand::thread_rng()`, pas d'abstraction CSPRNG explicite |
| `encoding` | **PARTIEL** | Base64URL et Hex pour migration |
| `hash` | **ABSENT** | Pas de SHA-256/BLAKE3 dans le crate (géré séparément dans SurrealQL / runtime) |
| `password` | **ABSENT** | Pas de hachage unidirectionnel (Argon2id) dans le crate Rust |
| `asymmetric` | **ABSENT** | Pas de X25519 / Curve25519 |
| `signature` | **ABSENT** | Pas de Ed25519 / ECDSA |
| `hmac` | **ABSENT** | Pas de HMAC-SHA256 direct dans le crate Rust |
| `kdf` | **ABSENT** | Pas de HKDF / Argon2 KDF |

---

## 5. Audit des Primitives Cryptographiques

### 5.1. AES-256-GCM
- **Crate** : `aes-gcm` version `0.10.3` (RustCrypto).
- **Algorithme** : AES-GCM standardisé (NIST SP 800-38D).
- **Taille de Clé** : 256 bits (32 octets).
- **Taille de Nonce** : 96 bits (12 octets) générés aléatoirement par opération via CSPRNG.
- **Taille de Tag d'Authentification** : 128 bits (16 octets).
- **Vérification de l'Intégrité** : Rejet automatique si le tag, le ciphertext ou l'AAD sont altérés.
- **Usage Réel** : Moteur de chiffrement universel de secrets pour `lyxal_booking`.

---

## 6. Audit de la Gestion des Clés & Sécurité Mémoire

### 6.1. Types et Invariants
- `EncryptionKey` :
  - Encapsule `Zeroizing<[u8; 32]>`.
  - N'implémente pas `Clone` (interdit les copies accidentelles en mémoire).
  - N'implémente pas `Serialize` / `Deserialize`.
  - Implémente `fmt::Debug` personnalisé affichant strictement `EncryptionKey([REDACTED])`.
  - Méthode `expose()` avec visibilité `pub(crate)` réservée aux primitives de chiffrement internes.
- `KeyId` :
  - Validation stricte `[A-Za-z0-9._-]{1,64}` (rejet immédiat des espaces, `:`, Unicode).
- `Zeroize sur Drop` :
  - La mémoire contenant la clé est automatiquement effacée lors de la libération du type `EncryptionKey`.

### 6.2. Fournisseurs de Clés (`KeyResolver`)
1. **`EnvironmentKeyProvider`** :
   - Décode la variable d'environnement (ex: `LYXAL_CRYPTO_MASTER_KEY`).
   - Exige un encodage Base64 strict de 32 octets.
   - Conserve la clé sous `Arc<EncryptionKey>` pour permettre le partage sans duplication.
2. **`FileKeyProvider`** :
   - Mode DEV (`AllowGenerate`) : Création atomique (`create_new(true)`) avec permissions `0600` sous Unix, gestion gracieuse des courses concurrentes (`AlreadyExists`).
   - Mode PROD STRICT (`RequireExisting`) : Échoue avec `GenerationProhibited` si le fichier n'existe pas.
3. **`CompositeKeyResolver`** :
   - Clé active pour les nouveaux chiffrements.
   - Table `HashMap<KeyId, Arc<EncryptionKey>>` protégée par `RwLock` pour la résolution des anciennes clés lors de rotations.

---

## 7. Nonces, IV et Random

- **Génération de Nonce** : `rand::thread_rng().fill_bytes(&mut nonce_bytes)` dans `cipher.rs`.
- **Génération de Clé** : `rand::thread_rng().fill_bytes(&mut buf)` dans `EncryptionKey::generate()`.
- **Analyse de Sécurité** :
  - `rand::thread_rng()` sous `rand 0.8` utilise un CSPRNG basé sur ChaCha12 auto-réensemencé par l'OS (`OsRng`).
  - Aucun nonce n'est généré par compteur séquentiel ou timestamp prévisible.
  - **Recommandation durcissement** : Pour la génération des clés maîtresses critiques, préférer explicitement `rand_core::OsRng` afin d'éviter tout risque lié au clonage d'état PRNG en mémoire lors de `fork()` sous Linux.

---

## 8. Chiffrement Authentifié & Format des Données (AAD & Enveloppe)

### 8.1. AAD Anti-Collision
Pour éviter toute attaque de confusion de contexte, `SecretContext` génère un AAD déterministe préfixé par la longueur de chaque champ :
```text
lyxal:v1:<len_t>:<tenant>:<len_m>:<module>:<len_r>:<resource>:<len_rec>:<record_id>:<len_f>:<field>
```
*Exemple* : `lyxal:v1:7:default:7:booking:22:booking_caldav_source:14:source_cal_101:8:password`

### 8.2. Format de l'Enveloppe Scellée
```text
enc:v1:<key_id>:<payload_base64url>
```
Où `payload` est la concaténation brute :
```text
[ Nonce (12 octets) | Ciphertext (N octets) | Tag Auth (16 octets) ]
```
Le payload décodé doit mesurer au minimum 28 octets.

---

## 9. Rotation de Clés

- **Statut** : **FONCTIONNEL**
- **Processus** :
  1. La méthode `engine.reencrypt_if_needed(envelope_str, &context)` analyse la clé d'enveloppe.
  2. Si `key_id == active_id`, renvoie `ReencryptResult::Current`.
  3. Si la clé est différente, déchiffre via la clé historique correspondante dans le resolver, puis rechiffre avec la clé active et renvoie `ReencryptResult::Rotated(new_envelope)`.
- **Tests** : Validé dans `tests/key_resolver.rs` (`test_composite_key_resolver_supports_rotation`).

---

## 10. Multi-Tenancy & Isolation Lyxal

- Le paramètre `tenant` est obligatoire dans `SecretContext::with_tenant(...)`.
- L'isolation est garantie cryptographiquement par l'AAD : un enregistrement chiffré pour le tenant `acme` ne peut en aucun cas être déchiffré dans le contexte du tenant `globex`, même si les deux utilisent la même clé maîtresse.
- Aucune variable globale mutable dans le crate.

---

## 11. Intégration dans l'Écosystème Lyxal

```text
┌──────────────────────────────────────────────────────────────────┐
│                          lyxal_booking                           │
│  - CalDAV / CardDAV Passwords                                    │
│  - OAuth Tokens & Client Secrets                                 │
│  - SMTP Credentials                                              │
│  - Captcha Secrets & Webhook Keys                                │
└─────────────────────────────────┬────────────────────────────────┘
                                  │ utilise
                                  ▼
┌──────────────────────────────────────────────────────────────────┐
│                           lyxal_crypto                           │
│  - CryptoEngine<R> / KeyResolver                                 │
│  - AES-256-GCM AEAD Engine                                       │
│  - SecretContext (AAD Multi-Tenant)                              │
│  - EncryptedEnvelope (enc:v1:...)                                │
└──────────────────────────────────────────────────────────────────┘
```

- **`lyxal_booking`** : Intégration complète et validée (via `crypto_helpers.rs`).
- **`lyxal_runtime`** : Dépend actuellement directement de `sha2` pour ses sommes de contrôle de migrations et IDs de nœuds. Une future version de `lyxal_crypto` exposant une primitive de hachage standard permettra d'unifier ces usages.
- **`lyxal_core`** : Héberge les fonctions déclaratives de sécurité SurrealQL (`functions/security/*.surql`).

---

## 12. Analyse des Risques & Dette Technique

| ID | Catégorie | Description | Sévérité | Recommandation |
| :---: | :--- | :--- | :---: | :--- |
| **R1** | Scope | Absence de primitives de hachage standard (SHA-256, BLAKE3) dans `lyxal_crypto`, forçant `lyxal_runtime` à importer `sha2` directement | **MEDIUM** | Ajouter un sous-module `hash` standardisé dans `lyxal_crypto` (P1). |
| **R2** | Scope | Absence de primitive de hachage de mots de passe utilisateur (Argon2id) dans le crate Rust | **MEDIUM** | Ajouter un sous-module `password` (Argon2id) avec coût mémoire paramétrable (P1). |
| **R3** | Tests | Absence de vecteurs de test officiels NIST SP 800-38D pour AES-GCM | **LOW** | Intégrer les vecteurs de test NIST dans `tests/` (P4). |
| **R4** | Tests | Absence de suite de fuzzing sur le parseur d'enveloppes `EncryptedEnvelope::parse` | **LOW** | Ajouter des tests basés sur `proptest` / `cargo-fuzz` (P4). |
| **R5** | RNG | Utilisation de `rand::thread_rng()` au lieu d'`OsRng` direct pour la génération de clés maîtresses | **LOW** | Basculer la génération de clé maîtresse sur `rand_core::OsRng` (P0). |
| **R6** | Doc | Absence d'un `README.md` explicatif à la racine du crate (seul `roadmap.md` est présent) | **LOW** | Créer le `README.md` standard Lyxal (P5). |

---

## 13. Grille d'Évaluation de Maturité

| Catégorie | Note | Justification |
| :--- | :---: | :--- |
| **Architecture** | **9/10** | Découpage modulaire clair, séparation stricte des responsabilités |
| **API** | **9/10** | API fortement typée, ergonomique, empêchant les mauvais usages |
| **Cryptographie** | **8/10** | AES-256-GCM irréprochable ; scope limité au symétrique pour l'instant |
| **Gestion des clés** | **8.5/10** | Clés protégées en mémoire, résolveurs multi-sources, rotation opérationnelle |
| **Sécurité mémoire** | **9.5/10** | Zeroizing systématique, Debug masqué, pas de Clone/Serialize sur les clés |
| **Gestion des erreurs** | **9/10** | Erreurs fortement typées (`thiserror 2.0`), aucune fuite de secret |
| **Tests** | **7.5/10** | 13 tests d'intégration complets, mais manque vecteurs NIST et fuzzing |
| **Documentation** | **7.5/10** | Roadmap claire et rustdoc complets, mais pas de README.md |
| **Intégration Lyxal** | **8/10** | Parfait avec `lyxal_booking`, à étendre au `lyxal_runtime` |
| **Production Readiness** | **8.5/10** | Prêt et stable pour la protection des secrets symétriques |
| **SCORE GLOBAL** | **85/100** | **Excellente base technique solide, saine et sécurisée** |

---

## 14. Roadmap Recommandée (P0 → P5)

```text
┌──────────────────────────────────────────────────────────────┐
│ P0 : Sécurité & Durcissement Immédiat                         │
│ - Basculer EncryptionKey::generate() sur OsRng               │
├──────────────────────────────────────────────────────────────┤
│ P1 : Primitives Fondamentales Manquantes                     │
│ - Module hash (SHA-256, SHA-512, BLAKE3)                     │
│ - Module password (Argon2id avec PHC format)                 │
│ - Module hmac (HMAC-SHA256 avec comparaison constant-time)   │
├──────────────────────────────────────────────────────────────┤
│ P2 : Architecture & Extensions                               │
│ - Module asymmetric / signature (Ed25519, X25519)            │
│ - Helpers universels encrypt_string, encrypt_json            │
├──────────────────────────────────────────────────────────────┤
│ P3 : Intégration Écosystème Lyxal                            │
│ - Migration des dépendances sha2 de lyxal_runtime vers crypto│
│ - Intégration avec lyxal_event & lyxal_notification          │
├──────────────────────────────────────────────────────────────┤
│ P4 : Tests Avancés & Fuzzing                                 │
│ - Suite de tests avec vecteurs officiels NIST SP 800-38D      │
│ - Tests de propriétés avec proptest / cargo-fuzz             │
├──────────────────────────────────────────────────────────────┤
│ P5 : Documentation & Packaging                               │
│ - Rédaction de README.md canonique                           │
│ - Exemples d'usage et guides d'intégration                   │
└──────────────────────────────────────────────────────────────┘
```

---

## 15. Verdict Final Obligatoire

### **Classification : ÉTAT D — mature mais nécessite durcissement**

### Ce qui sépare `lyxal_crypto` du niveau suivant (ÉTAT E — Production-Ready pour TOUTE la plateforme) :
1. **Extension du scope cryptographique** : Pour devenir l'unique brique crypto de Lyxal OS, le crate doit accueillir le hachage (`hash`), le hachage de mot de passe (`password` Argon2id) et le HMAC, évitant ainsi la dispersion des dépendances cryptographiques dans `lyxal_runtime`.
2. **Durcissement du RNG pour les clés** : Utilisation explicite d'`OsRng` pour la génération des clés maîtresses.
3. **Vecteurs de test officiels NIST** et tests de fuzzing sur le parseur d'enveloppes.
4. **Documentation utilisateur (`README.md`)** et ajout au workspace root consolidé.
