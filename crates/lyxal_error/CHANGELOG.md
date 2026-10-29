# 📜 Changelog — `lyxal_error`

Toutes les modifications notables apportées au module `lyxal_error` sont consignées dans ce document.
Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/) et ce projet adhère à [Semantic Versioning](https://semver.org/lang/fr/).

---

## [0.2.0] - 2026-10-29 — Conformité SurrealDB 3.2.0 & Réconciliation DTOs Rust

### 🏛️ Élimination de la Dette Technique SurrealDB 2.x
- **Rupture avec le SDK `surrealdb = "2.2"` obsolète** :
  - Suppression de la dépendance `surrealdb = { workspace = true }` dans `crates/lyxal_error/Cargo.toml`.
  - Élimination de tous les faux tests d'intégration en mémoire 2.x incompatibles avec le protocole réseau 3.2.0.
  - Mise en place d'un harnais d'intégration automatisé `Surreal320` pilotant directement le binaire officiel `surreal.exe 3.2.0` sous `mem://`.

### ⚙️ Migration de Syntaxe SurrealQL 3.2.0
- **Remplacement systématique de `type::thing(...)` par `type::record(...)`** :
  - Appliqué sur 9 fonctions : `error_definition_get`, `error_definition_update`, `error_definition_disable`, `error_mapping_create`, `error_mapping_get`, `error_mapping_update`, `error_mapping_disable`, `error_occurrence_get`, `error_get`.
- **Remplacement des fonctions de typage dépréciées `type::is::*` par `type::is_*`** :
  - `type::is::string` $\rightarrow$ `type::is_string`, `type::is::record` $\rightarrow$ `type::is_record`, `type::is::datetime` $\rightarrow$ `type::is_datetime`, `type::is::object` $\rightarrow$ `type::is_object`.
- **Validation syntaxique formelle** :
  - 100 % des 26 fichiers `.surql` du module validés avec succès sur `surreal.exe validate` (26/26 OK, 0 échec).

### 🔄 Réconciliation Contrats DTOs Rust ↔ Fonctions SurrealQL
- **Alignement DTOs Rust (`src/types.rs`)** :
  - `ErrorDefinitionCreateParams` : ajout des champs optionnels `module`, `domain`, `enabled` (avec alias `active`).
  - `ErrorDefinitionListParams` : ajout des filtres `module`, `domain`, `enabled_only`, et `severity`.
  - `ErrorDefinitionUpdateParams` : ajout du champ optionnel `enabled` (avec alias `active`).
  - `ErrorMappingCreateParams` & `ErrorMappingUpdateParams` : ajout de la tolérance bidirectionnelle Serde avec `#[serde(alias = "matcher")] pub match_type` et `#[serde(alias = "definition_id", alias = "definition")] pub target_code`, ainsi que `service`, `external_http_status`, `retryable_override`.
- **Alignement Fonctions SurrealQL** :
  - `fn::error_definition_create` & `fn::error_definition_update` : persistance et mise à jour complètes de `retryable`, `log_occurrence`, `documentation`, `metadata`, `enabled`.
  - `fn::error_definition_list` : ajout du filtrage effectif par `severity`.
  - `fn::error_mapping_create` & `fn::error_mapping_update` : lecture tolérante `$params.matcher ?? $params.match_type`, `$params.definition_id ?? $params.target_code`, et persistance de `service`, `external_http_status`, `description`, `retryable_override`.
  - `schema/error_external_mapping.surql` : déclaration explicite du champ SCHEMAFULL `description`.

### 🛡️ Idempotence des Seeds & Master Data
- `error/error_definitions.surql` : requêtes conditionnelles `IF !record::exists(...) AND array::len((SELECT ... WHERE code = ...)) == 0 THEN CREATE ... END;` pour les 6 codes fondamentaux.
- `seeds/error_mappings.surql` : vérification d'existence avant création de `error_external_mapping:http_gateway_400_exact` et `404_exact`.
- Idempotence absolue garantie même en cas de réapplications multiples.

### 🧪 Qualification Dynamique sur Binaire Réel SurrealDB 3.2.0
- **21 tests exécutés et réussis (100 % passants)** :
  - 3 tests unitaires internes (`src/lib.rs`).
  - 10 tests de contrats Rust & roundtrip DTOs (`tests/contracts_tests.rs`).
  - 2 tests d'intégrité de manifeste et non-orphelins (`tests/manifest_tests.rs`).
  - 6 tests d'intégration réels sur `surreal.exe 3.2.0` (`tests/surreal_integration_tests.rs`).
- `cargo clippy -p lyxal_error --all-targets` : 0 avertissement, 0 erreur.

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

### ⚙️ Normalisation SurrealQL & Audit Correctif
- **Conformité stricte des signatures CRUD ($params: object)** :
  - Standardisation de toutes les fonctions CRUD et de gestion sur la signature canonique `$params: object` :
    `error_definition_get`, `error_definition_disable`, `error_definition_list`,
    `error_mapping_get`, `error_mapping_disable`, `error_mapping_list`,
    `error_occurrence_get`, `error_occurrence_list`, `error_occurrence_purge_before`.
  - Élimination de tout `$params: any` sur les fonctions CRUD et de gestion.
  - Préservation justifiée de `fn::error_get` comme primitive interne de service de résolution rapide pour `fn::error_resolve`.
  - Primitives universelles `fn::result_ok($data)` et `fn::error_result($code, $language, $details)` préservées et conformes.
- **Modernisation SurrealDB 2.x & Robustesse** :
  - Remplacement des syntaxes regex obsolètes `~ r"..."` par la fonction native `string::matches($value, "...")`.
  - Remplacement de `VALUE $before OR time::now()` par `DEFAULT time::now() READONLY`.
  - Remplacement des extractions `string::slice` par un découpage robuste `string::replace($raw_str, "table:", "")` évitant les erreurs d'arité de slicing.
  - Conversion explicite des identifiants `Thing` en `<string>` dans les réponses et les détails d'erreur pour garantir une désérialisation JSON universelle côté Rust.
  - Résolution des scopes lexicaux dans les boucles SurrealQL (`FOR`) avec retour direct par court-circuit dès la première correspondance trouvée.
- **Traitement des erreurs silencieuses** :
  - `fn::error_log` : validation stricte des paramètres obligatoires (`code`, `source_module`) retournant `ERROR_PARAM_REQUIRED` au lieu de `NONE`.
  - `fn::error_map_external` : validation formelle de `provider` et `external_code`, avec retour explicite `fn::result_ok(NONE)` en cas d'absence de règle sans erreur artificielle.

### 📦 Intégration Runtime & Migrations
- **Manifeste officiel (`manifest.toml`)** :
  - Contrat Runtime déclarant les 3 tables de schéma, la migration initiale, les 20 fonctions SurrealQL, le master data d'erreurs et les seeds de correspondances externes.
  - Zéro fichier orphelin (`test_no_orphan_surql_files` validé).
- **Architecture Schémas vs Migrations** :
  - Clarification de la séparation stricte établie par `lyxal_runtime` :
    - Phase C (Schéma) : `SchemaImporter` applique les schémas déclaratifs idempotents (`schema/*.surql`).
    - Phase D (Migration) : `MigrationRunner` exécute les scripts de migration séquentiels versionnés (`migrations/*.surql`) et trace leur application dans le `RuntimeStore` (`system_migration`).
  - Migration initiale `0001_initial_schema.surql` alignée sur le standard canonique Runtime (retourne son statut sans injection manuelle redondante dans les tables système).

### 🧪 Tests & Assurance Qualité
- **Couverture de tests renforcée (21 tests automatisés, 100 % passants)** :
  - `tests/contracts_tests.rs` (10 tests) : validation des contrats Rust `LyxalResult<T>`, rejet des états incohérents, propagation des erreurs métier, sérialisation typée.
  - `tests/manifest_tests.rs` (2 tests) : intégrité du manifeste, exhaustivité des ressources SurQL sans fichiers orphelins.
  - `tests/surreal_integration_tests.rs` (6 tests d'intégration en mémoire SurrealDB 2.x) :
    1. `test_surreal_bootstrap_and_migration_idempotence` : réapplication répétée de la migration et préservation des données existantes.
    2. `test_surreal_primitives_result_ok_and_error_result` : validation des enveloppes `{ ok, data, error }`, traductions et repli linguistique.
    3. `test_surreal_error_definition_lifecycle` : cycle de vie CRUD complet avec `$params: object` (`{ code }`, `{ id }`, `{ code_or_id }`), validation des paramètres manquants, codes inexistants, désactivation logique et préservation physique des enregistrements.
    4. `test_surreal_error_mapping_and_resolution` : résolution des correspondances externes (exact, préfixe, statut HTTP), consultation/désactivation par objet, gestion des paramètres manquants et IDs inexistants.
    5. `test_surreal_error_occurrence_logging_and_purging` : journalisation immuable, consultation par objet ID, validation des paramètres manquants, purge par date d'antériorité.
    6. `test_surreal_edge_cases_and_contract_coherence` : exécution des fonctions de listage avec objet vide `{}`, tests de la primitive interne `error_get` avec code existant et inexistant.
- **Validation statique** :
  - `cargo check -p lyxal_error` : 0 erreur.
  - `cargo clippy -p lyxal_error --all-targets` : 0 warning.
  - `cargo check --workspace` : 0 régression.
