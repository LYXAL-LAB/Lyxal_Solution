# 📋 Implementation Plan — Assainissement Final des Helpers Cal.rs

## Contexte & Objectif
Supprimer définitivement l'ensemble des 4 helpers historiques Cal.rs (`decode_calrs_legacy_hex`, `CryptoEngine::decrypt_calrs_aes_base64`, `migrate_calrs_aes_base64`, `migrate_legacy_calrs_hex`) de `crates/lyxal_crypto`.
Déplacer et ré-encapsuler ces mécanismes de compatibilité historique au sein de `lyxal_booking` (`crypto_helpers.rs`), en réutilisant exclusivement la primitive générique pure `lyxal_crypto::cipher::decrypt_aes_gcm`.

---

## 1. Modifications `crates/lyxal_crypto`

1. **`crates/lyxal_crypto/src/lib.rs`** :
   - Supprimer `decode_calrs_legacy_hex`.
   - Supprimer `CryptoEngine::decrypt_calrs_aes_base64`.
   - Supprimer `CryptoEngine::migrate_calrs_aes_base64`.
   - Supprimer `CryptoEngine::migrate_legacy_calrs_hex`.
   - Supprimer l'import inutilisé de `base64::engine::general_purpose::STANDARD`.
2. **`crates/lyxal_crypto/tests/fuzz_robustness.rs`** :
   - Retirer l'import et l'appel à `decode_calrs_legacy_hex`.
3. **`crates/lyxal_crypto/tests/migration.rs`** :
   - Supprimer le fichier de tests spécifique à Cal.rs.
4. **`crates/lyxal_crypto/API_CONTRACT.md`** :
   - Supprimer les 4 helpers de la documentation d'API du crate.
5. **`crates/lyxal_crypto/Cargo.lock`** :
   - Supprimer ce lockfile local orphelin via `git rm`.

---

## 2. Modifications `lyxal_booking`

1. **`lyxal_booking/engine/src/crypto_helpers.rs`** :
   - Implémenter les adaptateurs de compatibilité historique :
     - `decode_legacy_calrs_hex(stored_hex: &str) -> Result<SecretBytes, CryptoError>`
     - `decrypt_legacy_calrs_aes_base64(legacy_key: &EncryptionKey, stored_b64: &str) -> Result<SecretBytes, CryptoError>` (délégué à `lyxal_crypto::cipher::decrypt_aes_gcm`)
     - `migrate_legacy_calrs_aes_base64(crypto: &BookingCryptoEngine, legacy_key: &EncryptionKey, stored_b64: &str, context: &SecretContext) -> Result<String, CryptoError>`
     - `migrate_legacy_calrs_hex(crypto: &BookingCryptoEngine, stored_hex: &str, context: &SecretContext) -> Result<String, CryptoError>`
   - Mettre à jour `decrypt_caldav_password` et `decrypt_google_client_secret`.
   - Intégrer les tests unitaires de non-régression de migration héritée.
2. **`lyxal_booking/engine/src/web/meeting.rs`** :
   - Remplacer les appels directs à `lyxal_crypto` par `crate::crypto_helpers`.
3. **`lyxal_booking/engine/src/web/captcha.rs`** :
   - Remplacer les appels directs à `lyxal_crypto` par `crate::crypto_helpers`.
4. **`lyxal_booking/engine/src/oauth2_caldav.rs`** :
   - Remplacer les 4 appels à `crypto.migrate_calrs_aes_base64` par `crate::crypto_helpers::migrate_legacy_calrs_aes_base64`.
5. **`lyxal_booking/engine/src/email/config.rs`** & **`tests.rs`** :
   - Remplacer l'appel à `crypto.migrate_calrs_aes_base64` par `crate::crypto_helpers::migrate_legacy_calrs_aes_base64`.

---

## 3. Plan de Validation

- `cargo check -p lyxal_crypto`
- `cargo test -p lyxal_crypto`
- `cargo clippy -p lyxal_crypto --all-targets -- -D warnings`
- `cargo check --manifest-path lyxal_booking/engine/Cargo.toml`
- `cargo test --manifest-path lyxal_booking/engine/Cargo.toml`
- Vérification de l'absence totale de référence résiduelle à `decrypt_calrs_aes_base64`, `migrate_calrs_aes_base64`, `migrate_legacy_calrs_hex`, `decode_calrs_legacy_hex`.
