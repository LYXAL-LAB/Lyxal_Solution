> [!NOTE]
> **À traiter lors de la reprise de `lyxal_booking` — ancienne API `lyxal_crypto` (reprise `lyxal_crypto`)**
>
> `lyxal_booking/engine` (hors workspace, non compilé par la CI) appelle une API de `lyxal_crypto` supprimée avant la première production. À remplacer par l'API actuelle (`crates/lyxal_crypto/API_CONTRACT.md`) :
> * `CryptoEngine::encrypt_secret` / `decrypt_secret` → `CryptoEngine::seal(&SecretBytes, &SecretContext)` / `open(&EncryptedEnvelope, &SecretContext)`, avec `EncryptedEnvelope::encode` / `parse` pour le stockage ;
> * `EncryptionKey::from_bytes` → `EncryptionKey::import(SecretBytes)` ;
> * `lyxal_crypto::cipher::{encrypt_aes_gcm, decrypt_aes_gcm}` → module privé, plus accessible : passer par `CryptoEngine` ;
> * `lyxal_crypto::Zeroizing`, `SecretString::from` → `SecretBytes::new` / `SecretString::new` (renvoient un `Result`).
>
> Fichiers concernés : `engine/src/crypto_helpers.rs`, `oauth2_caldav.rs`, `services/oauth.rs`, `services/integrations.rs`, `web/captcha.rs`, `web/csp.rs`, `web/meeting.rs`, `email/config.rs`, `email/tests.rs`, `caldav/mod.rs`, `utils/cli.rs`. Le plan Cal.rs ci-dessous s'appuie sur `lyxal_crypto::cipher::decrypt_aes_gcm`, devenu privé : il est à revoir. `enc:v1` n'est plus lu (aucune migration automatique).
>
> Même reprise, transport (`lyxal_surreal`) : `engine/src/db.rs` définit son propre `RootCredentials` et sa connexion. À remplacer par `lyxal_surreal::create_surreal_client(SurrealConnectOptions)` (mot de passe en `SecretString`, contrôles §11.2, délai, namespace et base).

> [!NOTE]
> **À traiter lors de la reprise de `lyxal_booking` — rupture de contrat `lyxal_error` (reprise `lyxal_error`, lot 3, décision CTO Q6)**
>
> `lyxal_error::LyxalCallError::BusinessCode` et `LyxalCallError::business_code(...)` n'existent plus. `lyxal_booking/engine` (hors workspace, non compilé par la CI) les utilise encore :
> * `engine/src/auth.rs:93` construit une erreur avec `LyxalCallError::business_code(...)` ;
> * `engine/src/auth.rs:634` filtre `LyxalSurrealError::Call(LyxalCallError::BusinessCode { details, .. })`.
>
> À la reprise : une erreur métier se construit côté SurrealQL avec `fn::error_result("BOOKING_...", $language, $details)` et se lit côté Rust comme `LyxalCallError::Business(LyxalError)` (`is_business_code` ne teste plus que cette variante). `LyxalCallError::InvalidContract` répond désormais avec le code `ERROR_INVALID_FUNCTION_RESPONSE`.

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
