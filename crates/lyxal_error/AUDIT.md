# Audit de reprise — `lyxal_error`

> Document de reprise (régime pré-production, `.agents/AGENTS.md` §0), supprimé en fin de reprise.
> Audit en lecture seule réalisé avec la skill `lyxal-audit`, sur l'état de `main` au 2026-11-02.

## 1. Périmètre et position dans le graphe

| Élément | Constat |
| :--- | :--- |
| Module | `lyxal_error`, version `0.1.0` (`manifest.toml` et `Cargo.toml`) |
| Niveau | Noyau technique (fondation du contrat d'erreur). Dépend de `lyxal_core` (manifeste) ; aucune dépendance Rust vers `lyxal_surreal` ni `lyxal_runtime` (conforme au Contrôle 2) |
| Dépendants | Rust : `lyxal_surreal`, `lyxal_runtime`, `lyxal_event`, `lyxal_pipeline_ingestion`, et `lyxal_booking/engine`, qui est **hors workspace** et donc non compilé par la CI. SurrealQL : `fn::result_ok` et `fn::error_result` sont appelées par `lyxal_core`, `lyxal_base` et `lyxal_catalogue`. Aucune autre fonction `fn::error_*` n'est appelée hors du module |
| SurrealQL | 3 schémas, 1 migration, 20 fonctions, 2 fichiers de définitions d'erreurs, 1 fichier de seeds |
| Rust | `src/lib.rs`, `result.rs` (`LyxalResult<T>`), `error.rs` (`LyxalError`, `LyxalCallError`, `IntoResponse` axum), `types.rs` (15 DTO `*Params`) |
| Tests | 3 tests unitaires et 18 tests d'intégration (moteur embarqué `mem://`) |
| Documents | `README.md`, `CHANGELOG.md`, `LYXAL_ERROR_CLOSURE_CTO_REPORT.md`, `ROADMAP.md`, `SCHEMA_DOCUMENTATION.md`, `features.md`, `history.txt`, ainsi qu'un `Cargo.lock` propre au crate |

## 2. Synthèse et verdict

**NON CONFORME (P1)** : aucun écart P0, mais plusieurs écarts P1.

* Les schémas sont solides : `SCHEMAFULL`, contraintes `ASSERT`, `PERMISSIONS NONE` sur les tables, `COMMENT` partout, index uniques. Le contrat universel `{ ok, data, error }` est respecté.
* Les fonctions, en revanche, valident leurs entrées à la main. Une valeur invalide n'est pas renvoyée sous forme d'erreur structurée : elle remonte en **erreur brute du moteur**.
* Un mode de correspondance prévu par le schéma n'est pas implémenté.
* La journalisation échoue dès qu'on lui transmet un enregistrement source.
* Le module conserve des alias de compatibilité et des documents historiques.

## 3. Écarts constatés

Toutes les preuves marquées « serveur » ont été obtenues sur un serveur SurrealDB **3.3.4** réel, avec `lyxal_core`, les schémas, les fonctions, les définitions d'erreurs et les seeds chargés.

| ID | Sév. | Règle | Fichier | Preuve | Correction |
| :--- | :--- | :--- | :--- | :--- | :--- |
| E-01 | P1 | §5.7.8, §11.4 | toutes les fonctions `functions/**` | Les entrées sont validées par des `string::len(string::trim(...))` locaux. Une valeur hors liste (catégorie, sévérité, mode de correspondance, environnement) remonte en erreur brute du moteur. Serveur : `error_definition_create({ category: "inconnue" })` → `Found 'inconnue' for field category…` ; `error_log({ environment: "prod" })` → même type d'erreur | Valider chaque entrée avec `fn::validation_object_execute` et renvoyer une erreur `ERROR_*` construite à partir de `by_field` |
| E-02 | P1 | §11.4 | `error_mapping_create.surql`, `error_occurrence_purge_before.surql` | Serveur : un doublon de mapping lève l'erreur d'index brute `Database index error_external_mapping_unique already contains…` ; une date invalide lève `Could not cast into datetime…` | Contrôle préalable et codes `ERROR_MAPPING_ALREADY_EXISTS` / validation de la date par le Core |
| E-03 | P1 | contrat fonctionnel | `schema/error_external_mapping.surql`, `functions/service/error_map_external.surql` | Le schéma autorise le mode `regex`, mais `fn::error_map_external` ne le traite pas. Serveur : un mapping `regex` `^5\d\d` ne reconnaît pas `550` (`data: null`) | Implémenter `regex` (motif contrôlé à la création par `fn::validation_regex`) ou le retirer du schéma |
| E-04 | P1 | DTO ↔ SurrealQL | `src/types.rs` (`ErrorLogParams`), `functions/service/error_log.surql` | `source` et `actor` sont des `Option<String>` côté Rust ; le schéma attend `option<record>`. Serveur : `error_log({ source: "booking:abc" })` → `Expected none \| record but found 'booking:abc'` | Typer en `RecordId` (ré-exporté par `surrealdb-types`) |
| E-05 | P1 | §5.3, Contrôle 2.3 | `functions/service/error_get.surql` | Signature `$params: any` : accepte une chaîne ou un objet. Renvoie la donnée brute ou `NONE`, sans `fn::result_ok` ni `fn::error_result`. Ce n'est pas l'une des 3 fonctions positionnelles autorisées | Supprimer la fonction : `fn::error_definition_get` couvre la consultation, et la lecture interne se fait par requête dans `error_resolve` et `error_log` |
| E-06 | P1 | §5.3, §11.4 | `functions/service/error_resolve.surql` | `THROW "Parameter 'code' is required"` : un message libre au lieu d'un code. Serveur : `error_resolve(NONE, …)` → `An error occurred: Parameter 'code' is required` | `THROW "CORE_INVALID_ARGUMENT"` (argument de programmation, comme les primitives du Core) |
| E-07 | P1 | §5.5 | `functions/definition/error_definition_create.surql` | Le préfixe du code n'est pas contrôlé par rapport au module. Serveur : `{ code: "AUTH_SOMETHING", module: "booking" }` est accepté. Quand le module est absent, il est déduit du code sans le signaler | Exiger `module` et vérifier `code` = `UPPER(module)_…` ; nouveau code d'erreur |
| E-08 | P1 | intégrité | `functions/mapping/error_mapping_update.surql` | La définition cible n'est pas vérifiée. Serveur : `definition_id: "N_EXISTE_PAS"` produit un mapping pointant vers `error_definition:N_EXISTE_PAS`, qui n'existe pas | Vérifier l'existence (comme à la création) → `ERROR_DEFINITION_NOT_FOUND` |
| E-09 | P1 | Rust, frontière fondation/métier | `src/error.rs` (`IntoResponse`) | `LyxalCallError::BusinessCode` répond toujours `401 Authentication failed`, quel que soit le code : c'est la sémantique d'authentification de `lyxal_booking` logée dans la fondation. `InvalidContract` émet `CORE_INVALID_FUNCTION_RESPONSE`, préfixe de `lyxal_core`, sans définition master data | Statut et libellé génériques, ou suppression de la variante (décision Q6) ; code `ERROR_INVALID_FUNCTION_RESPONSE` défini en master data |
| E-10 | P1 | DTO ↔ SurrealQL | `src/types.rs`, `functions/**` | Voir le tableau §4 : champs absents côté Rust (`service`, `request_id`, `fingerprint`), champ ignoré par SurrealQL (`external_code` à la mise à jour), date passée en `String` | Aligner les DTO sur le contrat canonique |
| E-11 | P2 | §0.2 (alias) | 10 fonctions | Alias de compatibilité : `code ?? id ?? code_or_id`, `mapping_id ?? id`, `matcher ?? match_type`, `definition_id ?? target_code ?? definition`, `enabled ?? active`, `before_date ?? before`, `external_http_status ?? http_status` | Un seul nom par paramètre, DTO alignés |
| E-12 | P2 | §5.1 | `functions/occurrence/error_occurrence_create.surql` | Raccourci pur de `fn::error_log` | Supprimer (une responsabilité = un endroit) |
| E-13 | P2 | §0.2 (code mort), §5.5 | `error/error_definitions.surql` | `CORE_ERROR_DEFINITION_NOT_FOUND` n'est utilisé par aucune fonction et porte le préfixe de `lyxal_core` | Supprimer |
| E-14 | P2 | qualité | `functions/mapping/*` (4), `error_occurrence_get.surql`, `error_occurrence_purge_before.surql` | Encodage cassé (« Ã© ») dans les en-têtes et dans les `COMMENT`, donc visible en base | Réécrire en UTF-8 |
| E-15 | P2 | §0.2 (documents historiques) | racine du module | `CHANGELOG.md`, `LYXAL_ERROR_CLOSURE_CTO_REPORT.md`, `ROADMAP.md`, `features.md`, `SCHEMA_DOCUMENTATION.md`, `history.txt` (copie d'anciennes versions du code), `Cargo.lock` local (le crate est membre du workspace) ; `README.md` mentionne SurrealDB 3.2.0 | Supprimer ; README réécrit à l'état actuel |
| E-16 | P2 | §0.3.2 | `migrations/0001_initial_schema.surql` | Migration vide (un simple `RETURN`), au nom non canonique ; `lyxal_core` et `lyxal_event` n'en ont pas | Supprimer la migration et l'entrée du manifeste |
| E-17 | P2 | qualité | `functions/**` | Aucune fonction ne déclare de `PERMISSIONS` (défaut implicite) | `PERMISSIONS FULL` explicite, comme dans `lyxal_core` |
| E-18 | P2 | robustesse | `error_definition_list`, `error_mapping_list`, `error_occurrence_list` | `limit` non borné (serveur : `limit: 1000000` accepté) ; `error_occurrence_list` n'a pas de pagination (`start`) | Bornes validées par le Core (ex. 1 à 500) et `start` |
| E-19 | P2 | seeds | `seeds/error_mappings.surql` | Mappings de démonstration : un 404 HTTP générique est associé à `ERROR_DEFINITION_NOT_FOUND`, ce qui n'a pas de sens | Supprimer les seeds de démonstration |
| E-20 | P2 | complétude | `functions/service/error_log.surql` | Les champs `request_id` et `fingerprint` du schéma ne sont jamais renseignés | Les accepter (validés) |

## 4. Correspondance DTO Rust ↔ SurrealQL

| Fonction | Struct | Conformes | Absents côté Rust | Supplémentaires côté Rust | Incompatibles |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `error_definition_create` | `ErrorDefinitionCreateParams` | tous | — | — | — |
| `error_definition_get` / `_disable` | `…GetParams` / `…DisableParams` | `code`, `language` | — | — | — (alias `id`, `code_or_id` côté SurrealQL) |
| `error_definition_list` | `ErrorDefinitionListParams` | tous | — | — | — |
| `error_definition_update` | `ErrorDefinitionUpdateParams` | tous | — | `active` (doublon de `enabled`) | — |
| `error_mapping_create` | `ErrorMappingCreateParams` | `provider`, `service`, `external_code`, `priority`, `description`, `retryable_override`, `language` | — | `http_status` (doublon de `external_http_status`) | `match_type`, `target_code` : acceptés seulement grâce aux alias |
| `error_mapping_get` / `_disable` | `…GetParams` / `…DisableParams` | tous | — | — | — |
| `error_mapping_list` | `ErrorMappingListParams` | tous | — | — | — |
| `error_mapping_update` | `ErrorMappingUpdateParams` | `mapping_id`, `service`, `priority`, `description`, `retryable_override`, `enabled`, `language` | — | `external_code` (ignoré), `http_status`, `active` | `match_type`, `target_code` (alias) |
| `error_log` | `ErrorLogParams` | `code`, `source_module`, `operation`, `technical_message`, `context`, `trace_id`, `correlation_id`, `environment`, `severity`, `language` | `request_id`, `fingerprint` (schéma) | — | `source`, `actor` : `String` au lieu de `record` (E-04) |
| `error_occurrence_get` | `ErrorOccurrenceGetParams` | tous | — | — | — |
| `error_occurrence_list` | `ErrorOccurrenceListParams` | tous | `start` (inexistant) | — | — |
| `error_occurrence_purge_before` | `ErrorOccurrencePurgeParams` | `language` | — | — | `before_date` : `String` au lieu de `Datetime` |
| `error_map_external` | `ErrorMapExternalParams` | `provider`, `external_code`, `http_status`, `language` | `service` | — | — |

Les 15 DTO ne sont utilisés nulle part hors des tests du module. Aucun type `*Result` ne type les données renvoyées.

## 5. Points non vérifiés faute de preuves

* `lyxal_booking/engine` (hors workspace) n'est pas compilé par la CI. Sa dépendance à `LyxalCallError::BusinessCode` n'est donc pas vérifiée.
* Les permissions de session (utilisateur d'enregistrement face aux tables `PERMISSIONS NONE`) n'ont pas été testées : les tests et les sondes tournent en utilisateur racine.
* Le comportement du chargement par le `SchemaImporter` du runtime n'a pas été rejoué ici. Les sondes ont chargé le SurrealQL par requêtes directes (les seeds ne passent pas par `OPTION IMPORT`, qui ignore les valeurs `DEFAULT`).

## 6. Éléments conformes et preuves

* `cargo test -p lyxal_error` : 21 tests réussis (3 unitaires, 18 d'intégration sur le moteur embarqué `mem://`), code retour 0.
* Aucune construction interdite en 3.3.4 (`option<any>`, `array::contains(`, `type::thing(`, `type::is::`, `LET $token`) ; aucun `result_error` ; aucune fonction de plus de 300 lignes.
* Le manifeste correspond exactement aux 27 fichiers `.surql` (test `manifest_tests` vert).
* Les seeds et définitions d'erreurs sont idempotents (`IF !record::exists(…)`). Tous les codes passés à `fn::error_result` ont leur définition.
* Rust : aucun `panic!`, `unwrap()` ni `expect()` hors tests ; aucun import crypto ; `into_result` rejette les états incohérents.

## 7. Plan correctif

Voir `implementation_plan.md` (soumis au CTO).
