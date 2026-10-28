# 🏛️ Contrat d'API Publique & Classification de Stabilité — `lyxal_crypto`

**Statut du Crate** : `CORE FREEZE — STABLE`  
**Version** : `0.1.0` (Contrat figé en vue de `1.0.0`)  
**Date d'entrée en vigueur** : 02 Septembre 2026

---

## 1. Principes Directeurs du Freeze

1. **Aucune régression d'API** : Les signatures et types classés `STABLE` ne subiront aucun breaking change.
2. **Étanchéité des types** : Les types sensibles implémentent `Zeroize` et masquent leurs représentations via `Debug` (`[REDACTED]`).
3. **Séparation nette Legacy vs Moderne** : Les fonctions de déchiffrement legacy sont isolées sous la classification `MIGRATION-ONLY`.

---

## 2. Matrice Complète des Éléments d'API Publique

### 2.1. Modules Publics (`pub mod`)

| Module | Classification | Rôle & Périmètre | Consommateurs |
| :--- | :--- | :--- | :--- |
| `pub mod cipher` | `CONTROLLED-USAGE` | Primitives cryptographiques pures AES-256-GCM (NIST SP 800-38D). Usage contrôlé pour adaptateurs de transport et migrations. Préférer `CryptoEngine` pour le stockage applicatif. | Modules d'infrastructure, adaptateurs Booking |
| `pub mod context` | `STABLE` | Contexte d'authentification AAD multi-tenant `SecretContext`. | `lyxal_booking`, modules métiers |
| `pub mod envelope` | `STABLE` | Structure et encodage d'enveloppe `enc:v1` (`EncryptedEnvelope`). | `lyxal_booking`, moteurs de stockage |
| `pub mod error` | `STABLE` | Types d'erreurs fortement typées `CryptoError`. | Tout le workspace |
| `pub mod hash` | `STABLE` | Hachage cryptographique SHA-256 (FIPS 180-4) et BLAKE3 (oneshot + streaming). | `lyxal_runtime`, modules Lyxal |
| `pub mod hmac` | `STABLE` | Authentification de messages HMAC-SHA256 (RFC 2104 / RFC 4231). | `lyxal_booking`, webhooks, API tokens |
| `pub mod kdf` | `STABLE` | Dérivation de clés HKDF-SHA256 (RFC 5869) avec protection `Zeroizing`. | Gestionnaires de session / tokens |
| `pub mod key` | `STABLE` | Gestion des identifiants et clés de chiffrement (`KeyId`, `EncryptionKey`). | Tout le workspace |
| `pub mod key_resolver` | `STABLE` | Traits et implémentations de résolution de clés multi-sources. | `lyxal_booking`, serveurs hôtes |
| `pub mod password` | `STABLE` | Hachage et vérification de mots de passe Argon2id (RFC 9106) avec politique Lyxal v1. | `lyxal_booking`, `lyxal_auth` |

---

### 2.2. Structures & Types (`pub struct`, `pub type`, `pub enum`)

| Type | Module | Classification | Description & Contrat |
| :--- | :--- | :--- | :--- |
| `SecretContext` | `context` | `STABLE` | Contexte AAD `(tenant, module, resource, record_id, field)`. Normalisation automatique et format déterministe `lyxal:v1`. |
| `EncryptedEnvelope` | `envelope` | `STABLE` | Représentation d'une enveloppe `enc:v1:<key_id>:<base64url>`. |
| `EnvelopeVersion` | `envelope` | `STABLE` | Énumération des versions d'enveloppes (actuellement `V1`). |
| `CryptoError` | `error` | `STABLE` | Énumération exhaustive des erreurs cryptographiques. |
| `EncryptionKey` | `key` | `STABLE` | Clé 256-bit encapsulée, zéroïsée à l'abandon (`ZeroizeOnDrop`), non-clonable, non-sérialisable, masquée au `Debug`. |
| `KeyId` | `key` | `STABLE` | Identifiant textuel validé et non-vide d'une clé cryptographique. |
| `CryptoEngine<R: KeyResolver>` | `lib` | `STABLE` | Moteur applicatif universel pour le chiffrement/déchiffrement de secrets et la rotation. |
| `SecretBytes` | `lib` | `STABLE` | Alias pour `Zeroizing<Vec<u8>>` protégeant les octets déchiffrés en mémoire vive. |
| `SecretString` | `lib` | `STABLE` | Alias pour `Zeroizing<String>` protégeant les chaînes déchiffrées en mémoire vive. |
| `ReencryptResult` | `lib` | `STABLE` | Résultat d'une tentative de rotation (`Current` ou `Rotated(String)`). |
| `KeyResolver` (trait) | `key_resolver` | `STABLE` | Contrat de résolution `active_key_id()` et `resolve(&KeyId)`. |
| `EnvironmentKeyProvider` | `key_resolver` | `STABLE` | Résolveur de clés chargées depuis des variables d'environnement. |
| `FileKeyProvider` | `key_resolver` | `STABLE` | Résolveur de clés stockées sur le système de fichiers local. |
| `CompositeKeyResolver` | `key_resolver` | `STABLE` | Résolveur multi-clés en mémoire thread-safe (`RwLock`) supportant l'ajout de clés historiques. |
| `KeyGenerationPolicy` | `key_resolver` | `STABLE` | Politique de génération de clé locale (`RequireExisting` vs `AllowGenerate`). |
| `Sha256Hasher` | `hash` | `STABLE` | Hasher streaming incrémental SHA-256 (`update`, `finalize`, `finalize_hex`). |
| `Blake3Hasher` | `hash` | `STABLE` | Hasher streaming incrémental BLAKE3 (`update`, `finalize`, `finalize_hex`). |

---

### 2.3. Fonctions & Méthodes Publiques

| Fonction / Méthode | Module | Classification | Description & Règle d'usage |
| :--- | :--- | :--- | :--- |
| `CryptoEngine::new(resolver: R) -> Self` | `lib` | `STABLE` | Constructeur du moteur principal acceptant tout `KeyResolver`. |
| `CryptoEngine::encrypt_secret(&self, plaintext: &[u8], context: &SecretContext) -> Result<String, CryptoError>` | `lib` | `STABLE` | Chiffrement lié canonique avec AAD `lyxal:v1` sous enveloppe `enc:v1:<key_id>:<base64url>`. |
| `CryptoEngine::decrypt_secret(&self, envelope_str: &str, context: &SecretContext) -> Result<SecretBytes, CryptoError>` | `lib` | `STABLE` | Déchiffrement lié canonique avec vérification stricte de l'AAD. |
| `CryptoEngine::encrypt_unbound(&self, plaintext: &[u8]) -> Result<String, CryptoError>` | `lib` | `STABLE` | Chiffrement non lié (sans AAD contextuel, AAD vide) sous enveloppe `enc:v1:<key_id>:<base64url>`. |
| `CryptoEngine::decrypt_unbound(&self, envelope_str: &str) -> Result<SecretBytes, CryptoError>` | `lib` | `STABLE` | Déchiffrement non lié (sans AAD contextuel). |
| `CryptoEngine::reencrypt_if_needed(&self, envelope_str: &str, context: &SecretContext) -> Result<ReencryptResult, CryptoError>` | `lib` | `STABLE` | Rotation transparente de clé vers la clé active courante. |
| `sha256(data: &[u8]) -> [u8; 32]` | `hash` | `STABLE` | Hachage SHA-256 direct renvoyant 32 octets bruts. |
| `sha256_hex(data: &[u8]) -> String` | `hash` | `STABLE` | Hachage SHA-256 direct renvoyant une chaîne hexadécimale 64 chars en minuscules. |
| `blake3(data: &[u8]) -> [u8; 32]` | `hash` | `STABLE` | Hachage BLAKE3 direct renvoyant 32 octets bruts. |
| `blake3_hex(data: &[u8]) -> String` | `hash` | `STABLE` | Hachage BLAKE3 direct renvoyant une chaîne hexadécimale 64 chars en minuscules. |
| `sign_hmac_sha256(key: &[u8], data: &[u8]) -> [u8; 32]` | `hmac` | `STABLE` | Signature HMAC-SHA256 (infaillible) renvoyant 32 octets bruts. |
| `sign_hmac_sha256_hex(key: &[u8], data: &[u8]) -> String` | `hmac` | `STABLE` | Signature HMAC-SHA256 (infaillible) renvoyant une chaîne hexadécimale en minuscules. |
| `verify_hmac_sha256(key: &[u8], data: &[u8], expected_tag: &[u8]) -> bool` | `hmac` | `STABLE` | Vérification HMAC-SHA256 temps constant native (`verify_slice`). |
| `verify_hmac_sha256_hex(key: &[u8], data: &[u8], expected_hex: &str) -> bool` | `hmac` | `STABLE` | Vérification HMAC-SHA256 temps constant depuis signature hexadécimale. |
| `hkdf_sha256(ikm: &[u8], salt: Option<&[u8]>, info: &[u8], output: &mut [u8]) -> Result<(), CryptoError>` | `kdf` | `STABLE` | Dérivation HKDF-SHA256 générique vers un buffer mutable (RFC 5869). |
| `hkdf_sha256_32(ikm: &[u8], salt: Option<&[u8]>, info: &[u8]) -> Result<Zeroizing<[u8; 32]>, CryptoError>` | `kdf` | `STABLE` | Dérivation HKDF-SHA256 spécialisée 32 octets zéroïsés. |
| `hash_password(password: &str) -> Result<String, CryptoError>` | `password` | `STABLE` | Hachage Argon2id politique Lyxal v1 (`m=65536, t=3, p=1, salt=OsRng`). Sortie PHC. |
| `verify_password(password: &str, encoded_hash: &str) -> Result<bool, CryptoError>` | `password` | `STABLE` | Vérification temps constant d'un mot de passe contre un hash PHC. |
| `needs_rehash(encoded_hash: &str) -> bool` | `password` | `STABLE` | Détecte si un hash nécessite une mise à niveau vers les paramètres Lyxal v1. |
| `encrypt_aes_gcm(key: &EncryptionKey, plaintext: &[u8], aad: &[u8]) -> Result<Vec<u8>, CryptoError>` | `cipher` | `CONTROLLED-USAGE` | Primitive AEAD bas niveau produisant `Nonce (12B) \| Ciphertext \| Tag (16B)`. Usage contrôlé (adaptateurs de transport, migrations de protocoles). Préférer `CryptoEngine::encrypt_secret` pour le stockage applicatif standard. |
| `decrypt_aes_gcm(key: &EncryptionKey, payload: &[u8], aad: &[u8]) -> Result<Zeroizing<Vec<u8>>, CryptoError>` | `cipher` | `CONTROLLED-USAGE` | Primitive AEAD bas niveau consommant `Nonce (12B) \| Ciphertext \| Tag (16B)` avec vérification en temps constant. Usage contrôlé (adaptateurs de transport, migrations historiques). Préférer `CryptoEngine::decrypt_secret`. |
