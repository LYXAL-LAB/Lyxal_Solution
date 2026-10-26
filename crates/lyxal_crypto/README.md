# 🔐 Lyxal Crypto (`lyxal_crypto`)

> **Façade cryptographique officielle, unifiée et durcie de Lyxal OS.**

`lyxal_crypto` fournit l'ensemble des primitives et mécanismes cryptographiques requis par l'écosystème Lyxal (chiffrement symétrique authentifié AES-256-GCM, hachage SHA-256 et BLAKE3, dérivation de clés HKDF-SHA256, authentification de messages HMAC-SHA256 et hachage de mots de passe Argon2id).

---

## 🏛️ Architecture & Philosophie

- **Façade unifiée** : Zéro dispersion des dépendances crypto directes (`sha2`, `aes-gcm`, `argon2`, etc.) dans les crates métiers.
- **Sécurité par défaut (Secure by Design)** :
  - Génération de clés et d'aléas basée strictement sur `rand_core::OsRng` (CSPRNG système direct).
  - Nettoyage automatique de la mémoire sensible via `Zeroize` / `Zeroizing`.
  - Types opaques non clonables, non sérialisables et protégés contre les fuites via `Debug` masqué (`[REDACTED]`).
  - Vérifications en temps constant (`Constant-Time`) natives pour les tags HMAC et mots de passe.
  - Dérivation de contexte AAD canonique et obligatoire pour le chiffrement multi-tenant.
- **Séparation des responsabilités** : `lyxal_crypto` gère les opérations cryptographiques pures et les formats d'enveloppes standardisées (`lyxal:v1:...`). La gestion du coffre-fort distribué (KMS / Vault / HSM) est une responsabilité hôte distincte.

---

## 📦 Primitives & Fonctionnalités

### 1. Chiffrement Authentifié (AEAD AES-256-GCM)
- Chiffrement symétrique AES-256-GCM (NIST SP 800-38D).
- Nonce 96-bit (12 octets) cryptographiquement aléatoire et unique par opération.
- Tag d'authentification 128-bit (16 octets) garantissant l'intégrité et l'authenticité.
- Contexte AAD canonique lié au `tenant_id` et au domaine métier.
- Format d'enveloppe sérialisé : `lyxal:v1:<key_id>:<nonce_hex>:<tag_hex>:<ciphertext_hex>`.
- Rotation de clés et ré-encryption sans déchiffrement applicatif intermédiaire.

### 2. Hachage & Empreintes Cryptographiques (`hash`)
- **SHA-256** (FIPS 180-4) : Digest 256-bit brut et hexadécimal, API streaming (`Sha256Hasher`).
- **BLAKE3** : Hachage ultra-rapide et hautement sécurisé, API streaming (`Blake3Hasher`).

### 3. Authentification de Messages (`hmac`)
- **HMAC-SHA256** (RFC 2104 / RFC 4231) : Signature et vérification en temps constant natif (`verify_hmac_sha256` / `verify_slice`).

### 4. Dérivation de Clés (`kdf`)
- **HKDF-SHA256** (RFC 5869) : Dérivation extract-and-expand pour clés de session ou sous-clés avec sortie `Zeroizing<[u8; 32]>`.

### 5. Hachage de Mots de Passe (`password`)
- **Argon2id** (RFC 9106) : Profil durci Lyxal v1 (`m_cost = 64 MiB`, `t_cost = 3`, `p_cost = 1`).
- Format PHC standardisé `$argon2id$v=19$m=65536,t=3,p=1$...`.
- Salt aléatoire de 128 bits via `OsRng`.
- Fonction `needs_rehash()` pour la mise à niveau transparente en cas d'évolution de la politique de sécurité.

---

## 🚀 Utilisation

### Chiffrement & Déchiffrement AES-256-GCM

```rust
use lyxal_crypto::{EncryptionContext, EncryptionKey, EncryptionService, Plaintext};

// Clé 256 bits protégée en mémoire
let key = EncryptionKey::generate();
let service = EncryptionService::new(key, "key-prod-01");

// Contexte AAD multi-tenant
let ctx = EncryptionContext::builder()
    .with_tenant("tenant_lyxal_corp")
    .with_purpose("customer_pii")
    .build();

// Chiffrement
let ciphertext = service.encrypt(Plaintext::from("donnée secrète"), &ctx)?;
println!("Enveloppe sécurisée : {}", ciphertext.as_str());

// Déchiffrement
let decrypted = service.decrypt(&ciphertext, &ctx)?;
assert_eq!(decrypted.as_str(), "donnée secrète");
```

### Hachage & Vérification de Mots de Passe

```rust
use lyxal_crypto::password::{hash_password, verify_password, needs_rehash};

// Hachage Argon2id avec politique Lyxal
let hash = hash_password("mot-de-passe-ultra-sécurisé")?;

// Vérification temps constant
let is_valid = verify_password("mot-de-passe-ultra-sécurisé", &hash)?;
assert!(is_valid);

// Détection de migration de politique
if needs_rehash(&hash)? {
    // Re-hacher avec les nouveaux paramètres
}
```

### Signatures HMAC & Dérivation HKDF

```rust
use lyxal_crypto::hmac::{sign_hmac_sha256, verify_hmac_sha256};
use lyxal_crypto::kdf::hkdf_sha256_32;

let key = b"cle_secrete_hmac_32_octets_minim";
let data = b"payload_a_signer";

let signature = sign_hmac_sha256(key, data)?;
let is_authentic = verify_hmac_sha256(key, data, &signature)?;
assert!(is_authentic);

// Dérivation HKDF
let ikm = b"entree_de_materiel_cle";
let salt = b"sel_optionnel";
let info = b"contexte_applicatif";
let derived_key = hkdf_sha256_32(ikm, Some(salt), info)?;
```

---

## 🛡️ Conformité & Validation

| Norme / Référence | Domaine | Statut de conformité |
| :--- | :--- | :--- |
| **NIST SP 800-38D** | AES-256-GCM | Validé par vecteurs officiels NIST SP 800-38D (Cas 13 à 16) |
| **FIPS 180-4** | SHA-256 | Validé par vecteurs officiels NIST SHA-256 |
| **BLAKE3 Official Specs** | BLAKE3 | Validé par vecteurs officiels de référence BLAKE3 |
| **RFC 4231** | HMAC-SHA256 | Validé par vecteurs de test RFC 4231 (Cas 1, 2, 3, 7) |
| **RFC 5869** | HKDF-SHA256 | Validé par vecteurs de test RFC 5869 |
| **RFC 9106** | Argon2id | Validé par format PHC standardisé et tests de parité |

---

## 📜 Licence

Propriétaire - Lyxal OS Platform. Tous droits réservés.
