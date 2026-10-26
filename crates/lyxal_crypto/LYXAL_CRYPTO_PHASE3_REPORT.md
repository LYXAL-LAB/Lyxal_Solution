# 📋 LYXAL_CRYPTO — RAPPORT PHASE 3
## FREEZE API, ADOPTION WORKSPACE & RELEASE HARDENING

**Date** : 02 Septembre 2026  
**Statut** : `LYXAL_CRYPTO CORE FREEZE — STATUS: STABLE`  
**Version** : `0.1.0` (contrat figé en vue de `1.0.0`)

---

## 1. Core Freeze — Décision

Le crate `lyxal_crypto` est désormais **figé** en tant que socle cryptographique stable de Lyxal OS.

**Règles en vigueur à compter de ce freeze** :
- Aucune modification incompatible de `enc:v1`.
- Aucune modification incompatible de `lyxal:v1`.
- Aucune nouvelle primitive cryptographique sans besoin produit réel validé par le CTO.
- Toute rupture future doit être explicitement versionnée (`v2`).

---

## 2. Audit CSPRNG — Nonces

| Élément | Avant Phase 3 | Après Phase 3 |
| :--- | :--- | :--- |
| Source nonce AES-GCM 96 bits | `rand::thread_rng()` | `rand_core::OsRng` (CSPRNG système) |
| Dépendance `rand` | Présente dans `Cargo.toml` | **Supprimée** |
| Résidus `thread_rng` / `rand::` / `random()` | 1 occurrence dans `cipher.rs` | **0 occurrence** (audit grep exhaustif) |

**Justification** : `OsRng` utilise directement `getrandom` qui appelle `BCryptGenRandom` (Windows) / `/dev/urandom` (Linux). C'est le CSPRNG de référence pour les nonces cryptographiques — pas de seed interne, pas de PRNG déterministe.

---

## 3. Format Enveloppe `enc:v1` — Spécification Immuable

> 📜 Document de référence : [`ENVELOPE_FORMAT_V1.md`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_crypto/ENVELOPE_FORMAT_V1.md)

**Grammaire formelle** :
```text
enc:v1:<key_id>:<base64url_payload>
```

**Structure binaire du payload** :
```text
NONCE (12B) | CIPHERTEXT (N octets) | TAG (16B)
```

- Taille minimale : 28 octets.
- Algorithme : AES-256-GCM (NIST SP 800-38D).
- Nonce : 96 bits via `OsRng`.
- Encodage : Base64 URL-Safe sans padding.
- **Statut : DÉFINITIVEMENT FIGÉ.**

---

## 4. AAD `lyxal:v1` — Spécification Immuable

**Format canonique length-prefixed** :
```text
lyxal:v1:<len_tenant>:<tenant>:<len_module>:<module>:<len_resource>:<resource>:<len_record>:<record_id>:<len_field>:<field>
```

**Garanties** :
- Absence d'ambiguïté par préfixe de longueur sur chaque composant.
- Normalisation automatique en minuscules + trim.
- Anti-confusion multi-tenant : un ciphertext chiffré pour le tenant A ne déchiffre pas pour le tenant B.
- Anti-rejeu inter-enregistrements : un champ chiffré pour `record_123` ne déchiffre pas pour `record_456`.
- **Statut : DÉFINITIVEMENT FIGÉ.**

---

## 5. Contrat d'API Publique — Matrice de Classification

> 📜 Document de référence : [`API_CONTRACT.md`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_crypto/API_CONTRACT.md)

| Classification | Nombre d'éléments | Signification |
| :--- | :--- | :--- |
| `STABLE` | 30 types / fonctions | Aucun breaking change autorisé |
| `MIGRATION-ONLY` | 4 fonctions | Legacy Cal.rs uniquement, retrait futur planifié |
| `INTERNAL-CANDIDATE` | 2 fonctions | Primitives bas niveau, préférer `CryptoEngine` |

**Primitives classées STABLE** :
- AES-256-GCM (`CryptoEngine`, `EncryptedEnvelope`, `SecretContext`)
- SHA-256 (`sha256`, `sha256_hex`, `Sha256Hasher`)
- BLAKE3 (`blake3`, `blake3_hex`, `Blake3Hasher`)
- Argon2id (`hash_password`, `verify_password`, `needs_rehash`)
- HMAC-SHA256 (`sign_hmac_sha256`, `sign_hmac_sha256_hex`, `verify_hmac_sha256`, `verify_hmac_sha256_hex`)
- HKDF-SHA256 (`hkdf_sha256`, `hkdf_sha256_32`)
- Gestion de clés (`EncryptionKey`, `KeyId`, `KeyResolver`, `CompositeKeyResolver`, `EnvironmentKeyProvider`, `FileKeyProvider`)
- Types protégés (`SecretBytes`, `SecretString`, `ReencryptResult`)

---

## 6. Inventaire Crypto Workspace

> 📜 Document de référence : [`LYXAL_CRYPTO_WORKSPACE_USAGE.md`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_crypto/LYXAL_CRYPTO_WORKSPACE_USAGE.md)

| Module | Usage de `lyxal_crypto` | Statut |
| :--- | :--- | :--- |
| `lyxal_booking` | Argon2id (password), HMAC-SHA256 (webhooks), AES-256-GCM (secrets) | ✅ Migré Phase 3 |
| `lyxal_runtime` | SHA-256 (intégrité modules) | ✅ Intégré Phase 2 |
| `lyxal_crypto` | Toutes les primitives | ✅ Source unique |

---

## 7. Migration Argon2id — `lyxal_booking`

| Fichier | Avant Phase 3 | Après Phase 3 |
| :--- | :--- | :--- |
| [`auth.rs`](file:///c:/Users/HP/Desktop/Lyxal_OS/lyxal_booking/engine/src/auth.rs) | `argon2` crate locale + implémentation directe | `lyxal_crypto::password::{hash_password, verify_password}` |

**Corrections critiques appliquées** :
1. **Bug `verify_password`** : L'ancien code utilisait `.is_ok()` sur `verify_password()` → renvoyait `true` même quand le mot de passe était faux (car `Ok(false)` est toujours `Ok`). Corrigé vers `.unwrap_or(false)` sur le `Result<bool, _>`.
2. **`verify_password_uniform`** : Le timing constant est préservé via l'exécution systématique d'Argon2id (sur hash stocké ou `DUMMY_HASH`) avec retour `false` quand `stored_hash.is_none()`.
3. **Rétro-compatibilité** : Hash existant au format PHC Argon2id (Cal.rs/Lyxal) → continue à être vérifiable. Test `test_backward_compatibility_with_historical_calrs_argon2_hash` validé.

**Résultat tests booking auth** : 20/20 ✅

---

## 8. Migration HMAC-SHA256 — `lyxal_booking`

| Fichier | Avant Phase 3 | Après Phase 3 |
| :--- | :--- | :--- |
| [`meeting.rs`](file:///c:/Users/HP/Desktop/Lyxal_OS/lyxal_booking/engine/src/web/meeting.rs) | `hmac` + `sha2` crates directes | `lyxal_crypto::sign_hmac_sha256_hex` |

**Compatibilité** : byte-for-byte compatible. Le format de sortie hexadécimal minuscules est identique.

---

## 9. Audit Stockage de Secrets

| Vecteur | Statut |
| :--- | :--- |
| Clés cryptographiques en variables d'environnement | `EnvironmentKeyProvider` — secrets non persistés en clair sur disque |
| Clés cryptographiques en fichiers | `FileKeyProvider` — lecture unique au boot, zeroize en mémoire |
| Clés en mémoire | `EncryptionKey` → `ZeroizeOnDrop`, non-clonable, non-sérialisable, `Debug = [REDACTED]` |
| Secrets déchiffrés en mémoire | `SecretBytes` / `SecretString` → `Zeroizing<Vec<u8>>` / `Zeroizing<String>` |
| Persistance de plaintext sur disque | Aucune persistance — chiffrement systématique avant stockage |

---

## 10. Tests Fixtures Statiques `enc:v1`

> 📜 Fichier de test : [`tests/envelope_v1_fixtures.rs`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_crypto/tests/envelope_v1_fixtures.rs)

| Test | Description | Statut |
| :--- | :--- | :--- |
| `test_static_known_enc_v1_envelope_fixture_decryption` | Déchiffrement d'une enveloppe figée avec clé + contexte connus → vérification du plaintext attendu | ✅ |
| `test_static_known_enc_v1_envelope_empty_plaintext_fixture` | Enveloppe figée avec plaintext vide (28 octets min) → déchiffrement correct | ✅ |
| `test_aad_canonical_representation_fixture` | Vérification du format canonique AAD `lyxal:v1` length-prefixed | ✅ |

---

## 11. Tests Rotation — Cycle E2E Complet

> 📜 Fichier de test : [`tests/rotation_lifecycle.rs`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_crypto/tests/rotation_lifecycle.rs)

**Scénario validé** :
1. Chiffrement avec clé `v1` (clé active) → enveloppe `enc:v1:v1:…`
2. Ajout clé `v2` + promotion en clé active
3. Déchiffrement de l'enveloppe `v1` → toujours OK (résolution multi-clés)
4. Ré-encryption → nouvelle enveloppe `enc:v1:v2:…` (rotation effective)
5. Retrait de la clé `v1` du resolver
6. Déchiffrement de la nouvelle enveloppe `v2` → OK
7. Tentative de déchiffrement de l'ancienne enveloppe `v1` → `CryptoError::KeyNotFound` (erreur contrôlée, pas de panic)

| Test | Statut |
| :--- | :--- |
| `test_end_to_end_key_rotation_and_retirement_lifecycle` | ✅ |
| `test_rotation_error_handling_unknown_or_missing_keys` | ✅ |

---

## 12. Robustesse Randomisée

> 📜 Fichier de test : [`tests/fuzz_robustness.rs`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_crypto/tests/fuzz_robustness.rs)

**Type** : Randomized Robustness Testing (≠ Coverage-guided Fuzzing).

| Test | Mutations | Description | Statut |
| :--- | :--- | :--- | :--- |
| `test_randomized_envelope_parsing_and_decryption_robustness` | 1000+ | Flips de bits, troncatures, décodages invalides, nonces corrompus → jamais de panic | ✅ |
| `test_randomized_password_verification_robustness` | 1000+ | Strings aléatoires, octets bruts, hashes corrompus → jamais de panic | ✅ |

---

## 13. Coverage-Guided Fuzzing

**Statut** : `NOT AVAILABLE`

`cargo-fuzz` requiert une configuration nightly + libFuzzer non disponible dans cet environnement. Le randomized robustness testing couvre le périmètre atteignable.

---

## 14. Sécurité Supply Chain

| Outil | Statut | Observation |
| :--- | :--- | :--- |
| `cargo audit` | `NOT AVAILABLE` | Non installé dans l'environnement |
| `cargo deny` | `NOT AVAILABLE` | Non installé dans l'environnement |

**Dépendances du crate** (aucune dépendance douteuse ou non-RustCrypto identifiée) :

| Crate | Version | Provenance | Rôle |
| :--- | :--- | :--- | :--- |
| `aes-gcm` | `0.10` | RustCrypto | AES-256-GCM AEAD |
| `sha2` | `0.10` | RustCrypto | SHA-256 |
| `blake3` | `1.5` | BLAKE3 team (officiel) | BLAKE3 |
| `argon2` | `0.5` | RustCrypto | Argon2id |
| `hmac` | `0.12` | RustCrypto | HMAC |
| `hkdf` | `0.12` | RustCrypto | HKDF |
| `rand_core` | `0.6` | RustCrypto | CSPRNG (`OsRng`) |
| `zeroize` | `1.8` | RustCrypto | Effacement mémoire |
| `base64` | `0.22` | Maintenu activement | Encodage Base64 |
| `hex` | `0.4` | Maintenu activement | Encodage hexadécimal |
| `thiserror` | `2.0` | dtolnay | Macros d'erreur |

---

## 15. Risques Résiduels

| Risque | Sévérité | Mitigation |
| :--- | :--- | :--- |
| Pas de cargo audit/deny en CI | Moyenne | Installer dans la pipeline CI lors de la mise en production |
| Pas de fuzzing coverage-guided | Faible | Randomized robustness couvre le périmètre. Ajouter `cargo-fuzz` en nightly ultérieurement |
| Ed25519 / X25519 hors scope | N/A | Décision CTO — pas de besoin produit actuel |
| Pas de KMS / HSM | Faible | Architecture prête (`KeyResolver` trait) pour intégration future si besoin |

---

## 16. Politique de Sécurité

> 📜 Document de référence : [`SECURITY.md`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_crypto/SECURITY.md)

**Interdictions formelles** :
- `unsafe` interdit dans le crate.
- `panic!` / `unwrap()` / `expect()` interdits sur des données non contrôlées.
- `rand::thread_rng()` interdit — CSPRNG système uniquement.
- Aucune clé en dur, aucun secret dans le code source.
- Aucune sérialisation de `EncryptionKey`.

---

## 17. Résultats de Validation Finale

| Vérification | Résultat |
| :--- | :--- |
| `cargo test -p lyxal_crypto` | **51/51 PASS** |
| `cargo clippy -p lyxal_crypto --all-targets --all-features -- -D warnings` | **0 warning, 0 erreur** |
| `cargo check --manifest-path lyxal_booking/engine/Cargo.toml` | **EXIT 0** |
| `cargo test --manifest-path lyxal_booking/engine/Cargo.toml --lib auth` | **20/20 PASS** |
| Recherche `thread_rng` / `rand::` / `random()` dans `lyxal_crypto/` | **0 occurrence** |
| Recherche `rand` dans `Cargo.toml` de `lyxal_crypto` | **Absent (supprimé)** — seul `rand_core` est conservé |

---

# ✅ SYNTHÈSE FINALE

```
BUILD:                     ✅ PASS (lyxal_crypto + lyxal_booking)
CRYPTO TESTS:              ✅ 51/51 PASS
RUNTIME TESTS:             ✅ 120+ (vérifié Phase 2)
BOOKING:                   ✅ 20/20 PASS (auth migré)
WORKSPACE:                 ✅ cargo check OK
API FREEZE:                ✅ API_CONTRACT.md — 30 STABLE / 4 MIGRATION-ONLY / 2 INTERNAL-CANDIDATE
ENVELOPE V1:               ✅ ENVELOPE_FORMAT_V1.md — DÉFINITIVEMENT FIGÉ
AAD V1:                    ✅ lyxal:v1 length-prefixed — DÉFINITIVEMENT FIGÉ
ROTATION:                  ✅ E2E v1→v2→re-encrypt→retrait v1→KeyNotFound contrôlé
PASSWORD MIGRATION:        ✅ lyxal_booking/auth.rs → lyxal_crypto::password — rétro-compatible
HMAC MIGRATION:            ✅ lyxal_booking/meeting.rs → lyxal_crypto::sign_hmac_sha256_hex — byte-for-byte
SECRET STORAGE:            ✅ Zeroize + OsRng + non-clonable + non-sérialisable
RANDOMIZED ROBUSTNESS:     ✅ 2000+ mutations — 0 panic
COVERAGE-GUIDED FUZZING:   ⚠️  NOT AVAILABLE (nightly + libFuzzer requis)
CARGO AUDIT:               ⚠️  NOT AVAILABLE (non installé)
CARGO DENY:                ⚠️  NOT AVAILABLE (non installé)
REMAINING RISKS:           CI tooling (audit/deny/fuzz) — sévérité faible à moyenne

CORE FREEZE:               LYXAL_CRYPTO CORE FREEZE, STATUS: STABLE
```
