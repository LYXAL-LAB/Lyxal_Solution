# Changelog — `lyxal_core`

Toutes les modifications notables de la bibliothèque standard SurrealQL **`lyxal_core`** sont documentées dans ce fichier.

---

## [1.0.0] — 2026-10-29

### Vue d'ensemble
Première version stable consolidée et certifiée **100 % compatible SurrealDB 3.2.0** (`799 / 799` fonctions et `799 / 799` fichiers de tests validés statiquement et dynamiquement sur `surreal.exe` v3.2.0).

### Ajouté
- **Contrat Runtime (`manifest.toml`)** : Ajout du manifeste déclaratif (`manifest_version = 1`, `id = "lyxal_core"`, `version = "1.0.0"`, `capabilities = ["database"]`) référençant les **799 fichiers `.surql`** sous `[resources] functions`.
- **Restauration de `fn::validation_bytes`** (`functions/validations/functions/bytes.surql`) : Implémentation complète conforme aux 40 scénarios de tests (`bytes::len`, bornes `min_length`/`max_length`, validation de type et de champ).

### Modifié & Corrigé (Compatibilité SurrealDB 3.2.0)
- **Réécriture en SurrealQL pur 3.2.0 (Lot 2)** :
  - `fn::utils_to_hex` & `fn::utils_from_hex` : conversion binaire $\leftrightarrow$ hexadécimale sans dépendance aux fonctions inexistantes `encoding::hex::*` ni `bytes::from_int`.
  - `fn::utils_encode_uri` & `fn::utils_decode_uri` : encodage/décodage conforme RFC 3986 §2.3 avec validation stricte des séquences UTF-8 multi-octets et rejet des séquences `%XX` malformées (`UTILS_INVALID_URI_ENCODING`).
  - `fn::utils_number_format` : remplacement de `string::pad` par `string::slice` + `string::concat` + `string::repeat`, prise en charge de `$precision == 0` et suppression du zéro négatif `"-0,00"` sans multiplication flottante susceptible de déborder `i64::MAX`.
  - `fn::utils_date_add_months` & `fn::utils_date_end_of_month` : remplacement de `time::from::parts` (supprimé en SurrealDB 3.2.0) par une construction ISO-8601 `<datetime>string::concat(...)` avec plafonnement des fins de mois (28/29/30/31 et années bissextiles).
- **Alignement Cryptographique sur `lyxal_crypto` (Option A)** :
  - `fn::security_cipher_info`, `fn::security_encrypt`, `fn::security_encrypt_file`, `fn::security_decrypt` : alignement strict sur le moteur officiel `lyxal_crypto` (`authenticated_ciphers: ["aes-256-gcm"]`, `key_derivation: ["hkdf-sha256"]`, `key_wrap: ["aes-256-gcm"]`).
- **Migration syntaxique SurrealDB 3.2.0 (Lot 3 — 352 fonctions)** :
  - Migration de `option<any>` vers `any` sur **318 fonctions** (`NONE` et `NULL` nativement supportés par `any` en SurrealDB 3.2.0).
  - Remplacement de `array::contains($a, $b)` par l'opérateur natif `(($a) CONTAINS ($b))` sur **69 fonctions**.
  - Normalisation des séquences d'échappement regex/chaînes (`\\s`, `\\.`, `\\p{L}`, `\\x00`, `\\\\`) sur **46 fonctions** et suppression de la backreference `\2` non supportée par le moteur `regex` Rust dans `fn::sanitize_strip_dangerous_attributes`.
  - Remplacement de l'opérateur `=` ambigu en tête de bloc par `==` dans `fn::security_hash_verify` et `fn::validation_compare`.

### Nettoyé
- **Parité 1:1 des Tests (`799 fonctions` / `799 fichiers de tests`)** : Fusion sans perte et suppression des 3 doublons dans `functions/validations/test/` (`array_length.surql`, `array_unique.surql`, `object.surql` fusionnés dans leurs homologues `.test.surql`).
