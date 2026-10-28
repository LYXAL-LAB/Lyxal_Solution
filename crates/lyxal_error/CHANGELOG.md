# 📜 Changelog — `lyxal_error`

Toutes les modifications notables apportées au module `lyxal_error` sont consignées dans ce document.
Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/) et ce projet adhère à [Semantic Versioning](https://semver.org/lang/fr/).

---

## [0.1.0] - 2026-10-28 — Qualification Production-Ready & Standardisation AGENTS.md

### 🏛️ Architecture & Alignement Charte Lyxal OS
- **Standardisation du contrat universel d'erreur** :
  - Consécration officielle et exclusive de `fn::error_result($code, $language, $details)`.
  - Élimination stricte et interdiction formelle de toute référence ou alias à `fn::result_error`.
  - Préservation intégrale et immuable des contrats Rust publics `LyxalResult<T>`, `LyxalError` et `LyxalCallError`.
  - Format universel `{ ok, data, error }` garanti sur 100 % des fonctions publiques.
- **Découplage & Isolation métier absolue** :
  - Élimination totale de tous les codes métiers externes (`BOOKING_*`) des tables, seeds et fonctions de `lyxal_error`.
  - Master data officiel recentré exclusivement sur les 6 codes fondamentaux du domaine d'erreur :
    `CORE_ERROR_DEFINITION_NOT_FOUND`, `ERROR_PARAM_REQUIRED`, `ERROR_DEFINITION_NOT_FOUND`,
    `ERROR_DEFINITION_ALREADY_EXISTS`, `ERROR_MAPPING_NOT_FOUND`, `ERROR_OCCURRENCE_NOT_FOUND`.

### ⚙️ Normalisation SurrealQL
- **Conformité des signatures et directives** :
  - Standardisation de toutes les fonctions CRUD et de gestion sur la signature canonique `$params: object`.
  - Application systématique de la directive `DEFINE FUNCTION OVERWRITE`.
  - Primitives universelles `fn::result_ok($data)` et `fn::error_result($code, $language, $details)` préservées et conformes.
- **Modernisation SurrealDB 2.x** :
  - Remplacement des syntaxes regex obsolètes `~ r"..."` par la fonction native `string::matches($value, "...")`.
  - Remplacement de `VALUE $before OR time::now()` par `DEFAULT time::now() READONLY`.
  - Conversion explicite des identifiants `Thing` en `<string>` pour garantir la désérialisation JSON native.
  - Résolution des scopes lexicaux dans les boucles SurrealQL (`FOR`) avec retour direct par court-circuit.
- **Traitement des erreurs silencieuses** :
  - `fn::error_log` : validation stricte des paramètres obligatoires (`code`, `source_module`) retournant `ERROR_PARAM_REQUIRED` au lieu de `NONE`.
  - `fn::error_map_external` : validation formelle de `provider` et `external_code`, et distinction nette entre absence de mapping (`fn::result_ok(NONE)`) et paramètre invalide.

### 📦 Intégration Runtime & Migrations
- **Manifeste officiel (`manifest.toml`)** :
  - Contrat Runtime déclarant les 3 tables de schéma, la migration initiale, les 20 fonctions SurrealQL, le master data d'erreurs et les seeds de correspondances externes.
  - Zéro fichier orphelin (`test_no_orphan_surql_files` validé).
- **Migration initiale idempotente (`migrations/0001_initial_schema.surql`)** :
  - Enregistrement d'état d'idempotence dans `schema_migration:['lyxal_error', '0001_initial_schema']`.

### 🧪 Tests & Assurance Qualité
- **Couverture de tests complète (20 tests automatisés, 100 % passants)** :
  - `tests/contracts_tests.rs` (10 tests) : validation des contrats Rust `LyxalResult<T>`, rejet des états incohérents (`ok: true` avec `error`, `ok: false` sans `error`), propagation des erreurs métier, sérialisation typée.
  - `tests/manifest_tests.rs` (2 tests) : intégrité du manifeste, complétude et exhaustivité des ressources SurQL sans fichiers orphelins.
  - `tests/surreal_integration_tests.rs` (5 tests d'intégration en mémoire SurrealDB) :
    1. `test_surreal_bootstrap_and_migration_idempotence` : chargement complet des schémas, fonctions, seeds et réapplication idempotente.
    2. `test_surreal_primitives_result_ok_and_error_result` : validation des enveloppes `{ ok, data, error }`, traductions et repli linguistique.
    3. `test_surreal_error_definition_lifecycle` : cycle de vie CRUD complet (création, détection doublon, mise à jour, désactivation logique, filtrage `enabled_only`).
    4. `test_surreal_error_mapping_and_resolution` : résolution des codes externes fournisseurs (exact, préfixe, statut HTTP) et gestion des paramètres manquants.
    5. `test_surreal_error_occurrence_logging_and_purging` : journalisation immuable des occurrences et purge par date d'antériorité.
- **Validation statique** :
  - `cargo check -p lyxal_error` : 0 erreur.
  - `cargo clippy -p lyxal_error --all-targets` : 0 warning.
