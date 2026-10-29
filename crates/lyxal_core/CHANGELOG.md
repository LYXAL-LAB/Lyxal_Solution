# Changelog — `lyxal_core`

Toutes les modifications notables de la bibliothèque standard SurrealQL **`lyxal_core`** sont documentées dans ce fichier.

---

## [1.0.0] — 2026-10-29

### Vue d'ensemble
Première version stable consolidée et certifiée compatible **SurrealDB 3.2.0** sur le binaire réel `surreal.exe` v3.2.0 :
- **Validation statique (`surreal validate`)** : `799 / 799` fonctions `OK` et `799 / 799` fichiers de tests `OK` (`1 598 / 1 598`).
- **Import dynamique (`surreal import`)** : `799 / 799` fonctions chargées en base avec `0` erreur.
- **Exécution dynamique des 799 fichiers de tests (`2 557` instructions)** : `1 585` résultats `OK`, `963` `THROW "<CODE>"` métier attendus (tests négatifs), `9` rejets négatifs documentés `encoding::json::decode()`, et **`0` erreur moteur inattendue**.
- **Assertions de valeurs explicites** : `123 / 123` assertions vérifiées sur `surreal.exe` v3.2.0 (`81` sur Lots 1–3 + `42` sur Lot 4).

### Ajouté
- **Contrat Runtime (`manifest.toml`)** : Ajout du manifeste déclaratif (`manifest_version = 1`, `id = "lyxal_core"`, `version = "1.0.0"`, `capabilities = ["database"]`) référençant les **799 fichiers `.surql`** sous `[resources] functions`.
- **Restauration de `fn::validation_bytes`** (`functions/validations/functions/bytes.surql`) : Implémentation complète conforme aux 40 scénarios de tests (`bytes::len`, bornes `min_length`/`max_length`, validation de type et de champ).

### Modifié & Corrigé (Compatibilité SurrealDB 3.2.0 — Lots 1 à 4)
- **Réécriture en SurrealQL pur 3.2.0 (Lot 2)** :
  - `fn::utils_to_hex` & `fn::utils_from_hex` : conversion binaire $\leftrightarrow$ hexadécimale sans dépendance aux fonctions inexistantes `encoding::hex::*` ni `bytes::from_int`.
  - `fn::utils_encode_uri` & `fn::utils_decode_uri` : encodage/décodage conforme RFC 3986 §2.3 avec validation stricte des séquences UTF-8 multi-octets et rejet des séquences `%XX` malformées (`UTILS_INVALID_URI_ENCODING`).
  - `fn::utils_number_format` : remplacement de `string::pad` par `string::slice` + `string::concat` + `string::repeat`, prise en charge de `$precision == 0` et suppression du zéro négatif `"-0,00"` sans multiplication flottante susceptible de déborder `i64::MAX`.
  - `fn::utils_date_add_months` & `fn::utils_date_end_of_month` : remplacement de `time::from::parts` (supprimé en SurrealDB 3.2.0) par une construction ISO-8601 `<datetime>string::concat(...)` avec plafonnement des fins de mois (28/29/30/31 et années bissextiles).
- **Alignement Cryptographique sur `lyxal_crypto` (Lots 1 & 4 — Arbitrage CTO 1)** :
  - `fn::security_cipher_info`, `fn::security_encrypt`, `fn::security_encrypt_file`, `fn::security_decrypt` : alignement strict sur le moteur officiel `lyxal_crypto` (`authenticated_ciphers: ["aes-256-gcm"]`, `key_derivation: ["hkdf-sha256"]`, `key_wrap: ["aes-256-gcm"]`).
  - `fn::security_hmac_info`, `fn::security_hmac_sign`, `fn::security_hmac_verify` : alignement strict sur `["hmac-sha256"]` et `signer: "lyxal_crypto"`.
  - `fn::security_key_derive`, `fn::security_key_generate`, `fn::security_key_wrap`, `fn::security_key_unwrap` : alignement strict sur `["hkdf-sha256"]` et `["aes-256-gcm"]` (`key_bytes: 32`).
  - `fn::security_signature_info`, `fn::security_signature_sign`, `fn::security_signature_verify`, `fn::security_token_sign` : désactivation explicite des signatures asymétriques hors-scope (`supported_algorithms: []`, `status: "disabled_until_cto_approval"`, `THROW "SECURITY_UNSUPPORTED_SIGNATURE_ALGORITHM"`), et restriction de `token_sign` à `["hmac-sha256"]`.
  - `fn::security_hash_argon2`, `fn::security_hash_verify`, `fn::security_hash_string` : interdiction de tout pseudo-hachage Argon2 en SurrealQL pur ; levée explicite de `SECURITY_NATIVE_PASSWORD_HASH_REQUIRED` / `SECURITY_NATIVE_PASSWORD_VERIFY_REQUIRED` vers `lyxal_crypto::password::{hash_password, verify_password}`.
- **Migration syntaxique SurrealDB 3.2.0 (Lot 3 — 352 fonctions)** :
  - Migration de `option<any>` vers `any` sur **318 fonctions** (`NONE` et `NULL` nativement supportés par `any` en SurrealDB 3.2.0) et nettoyage des en-têtes documentaires.
  - Remplacement de `array::contains($a, $b)` par l'opérateur natif `(($a) CONTAINS ($b))` sur **69 fonctions**.
  - Normalisation des séquences d'échappement regex/chaînes (`\\s`, `\\.`, `\\p{L}`, `\\x00`, `\\\\`) sur **46 fonctions** et suppression de la backreference `\2` non supportée par le moteur `regex` Rust dans `fn::sanitize_strip_dangerous_attributes`.
  - Remplacement de l'opérateur `=` ambigu en tête de bloc par `==` dans `fn::security_hash_verify` et `fn::validation_compare`.
- **Corrections d'exécution runtime SurrealDB 3.2.0 (Lot 4 — 21 fonctions, `80 -> 0` erreur moteur)** :
  - Migration de `array::reduce($arr, $fn, $init)` (signature 2 arguments en 3.2.0) vers `array::fold($arr, $init, $fn)` sur **7 fonctions** (`fn::validation_luhn`, `fn::validation_pipeline_execute`, `fn::sanitize_object_pipeline`, `fn::validation_benchmark_duration_stats`, `fn::validation_benchmark_report`, `fn::validation_optimizer_pipeline_cost`, `fn::validation_optimizer_remove_duplicate_steps`).
  - Remplacement de `array::sort::asc($arr, $field)` / `array::sort::desc($arr, $field)` (signature 1 argument en 3.2.0) par un tri stable par clé (`array::fold` + `array::filter`, gestion explicite de `[]` et des clés `NONE`/`NULL` en fin de tableau) sur **7 fonctions** (`fn::utils_collection_sort_by`, `fn::sanitize_debug_slowest`, `fn::security_debug_slowest`, `fn::validation_debug_slowest_traces`, `fn::sanitize_optimizer_order`, `fn::security_optimizer_order`, `fn::validation_optimizer_order_pipeline`).
  - Remplacement de `math::min`/`math::max` sur `array<duration>` et calcul sans soustraction négative de `duration` sur **6 fonctions** (`fn::validation_benchmark_duration_stats`, `fn::sanitize_benchmark_stats`, `fn::security_benchmark_stats`, `fn::validation_benchmark_compare`, `fn::sanitize_benchmark_compare`, `fn::security_benchmark_compare`).
  - Corrections unitaires 3.2.0 : `math::log($x, 2f)` dans `fn::security_secret_entropy`, `encoding::base64::encode(<bytes>...)` dans `fn::sanitize_pipeline_cache_key`, variable protégée `$token` renommée `$raw_token` dans `fn::validation_bearer_token`, `<array>(0..array::len($value))` dans `fn::validation_tuple_types`, et validation `$duration <= 0s` dans `fn::validation_benchmark_sample`.
  - Documentation explicite des limites lexicales non-XSS sur `fn::sanitize_html` et `fn::sanitize_strip_dangerous_attributes`.

### Nettoyé
- **Parité 1:1 des Tests (`799 fonctions` / `799 fichiers de tests`)** : Fusion sans perte et suppression des 3 doublons dans `functions/validations/test/` (`array_length.surql`, `array_unique.surql`, `object.surql` fusionnés dans leurs homologues `.test.surql`).

