# Plan de reprise — `lyxal_error`

> Document de reprise (régime pré-production, `.agents/AGENTS.md` §0), supprimé une fois exécuté.
> **Statut : ⏳ soumis au CTO.** Aucune modification de code avant validation.
> Constats détaillés : `AUDIT.md` (identifiants E-01 à E-20).

## 1. Objectif

Faire sortir `lyxal_error` à l'état cible, comme `lyxal_core`, sans rien garder « pour compatibilité ».

* Ses entrées sont traitées par `lyxal_core` (§5.7.8), et toute erreur est structurée (§11.4).
* Ses contrats SurrealQL et Rust sont alignés, sans alias.
* Tous les appelants du dépôt sont mis à jour dans le même changement (§0.3).

## 2. Décisions demandées au CTO

| # | Question | Proposition |
| :- | :--- | :--- |
| Q1 | **Code d'erreur des entrées invalides.** Aujourd'hui, seul `ERROR_PARAM_REQUIRED` existe ; toute autre valeur invalide remonte en erreur brute (E-01). | Remplacer `ERROR_PARAM_REQUIRED` par **`ERROR_INVALID_INPUT`** (`http_status` 400), avec `details.fields` = `by_field` du rapport du Core (ex. `{ category: ["CORE_VALIDATION_NOT_ALLOWED"] }`). Un seul code couvre champ manquant, type, format et valeur hors liste. |
| Q2 | **`fn::error_get`** : signature `$params: any`, retour brut, aucun appelant hors du module (E-05). | **Supprimer.** `fn::error_definition_get` assure la consultation publique ; `error_resolve` et `error_log` lisent la définition par une requête interne. |
| Q3 | **`fn::error_occurrence_create`** : raccourci de `fn::error_log` (E-12). | **Supprimer** et garder `fn::error_log`, le nom de service utilisé par les modules. |
| Q4 | **Mode de correspondance `regex`** : prévu par le schéma, non implémenté (E-03). SurrealQL 3.3.4 ne sait pas vérifier qu'un motif est bien formé sans lever : `fn::validation_regex` teste une valeur contre un motif, elle ne valide pas le motif, et un motif invalide (`[`) lève une erreur brute du moteur. | **Retirer `regex` des modes autorisés** (il reste `exact`, `prefix`, `contains`, `http_status`). Un motif invalide ne pourra alors jamais faire échouer une résolution. Si un besoin réel de `regex` apparaît, il faudra une validation de syntaxe qui n'existe pas dans le Core : ce serait une demande d'extension (§5.7.7), probablement côté Rust, à soumettre séparément. |
| Q5 | **Préfixe des codes** (E-07). | Rendre `module` **obligatoire** et exiger que `code` commence par `UPPER(module)_`, sinon `ERROR_DEFINITION_CODE_PREFIX_MISMATCH`. Les codes `CORE_*` existants ont le module `core` et restent valides. |
| Q6 | **`LyxalCallError::BusinessCode`** : répond toujours 401 « Authentication failed » (E-09). Il est utilisé par `lyxal_pipeline_ingestion` et par `lyxal_booking/engine`, hors workspace. | **Supprimer la variante.** Le code Rust qui a besoin d'une erreur métier construit un `LyxalError` résolu par SurrealQL, comme les autres. Les deux appelants sont mis à jour dans la même PR : `lyxal_booking` relit sa logique d'authentification en Rust et n'est pas compilé par la CI (je vérifierai sa compilation à la main). |
| Q7 | **Seeds de démonstration** `seeds/error_mappings.surql` (E-19). | **Supprimer.** Aucun mapping n'est installé par défaut ; chaque module déclare les siens. |
| Q8 | **Migration vide** `0001_initial_schema.surql` (E-16). | **Supprimer**, comme `lyxal_core` et `lyxal_event` qui n'en ont pas. Les schémas sont appliqués par la phase schéma du runtime. |

## 3. Contrat cible

### 3.1. Fonctions SurrealQL (18 au lieu de 20)

* **Primitives positionnelles inchangées** (Contrôle 2.3) : `fn::result_ok($data)`, `fn::error_result($code, $language, $details)`, `fn::error_resolve($code, $language, $details)`. Seul changement : `error_resolve` lève `CORE_INVALID_ARGUMENT` (code fixe) si `$code` est absent (E-06).
* **Fonctions `$params: object`** : `error_log`, `error_map_external`, `error_definition_{create,get,list,update,disable}`, `error_mapping_{create,get,list,update,disable}`, `error_occurrence_{get,list,purge_before}`.
  * Un seul nom par paramètre, sans alias (E-11) : `code`, `mapping_id`, `occurrence_id`, `matcher`, `definition_code`, `enabled`, `before_date`, `external_http_status`.
  * Entrées validées par `fn::validation_object_execute`, avec les règles du catalogue du Core : `required_string`, `enum`, `integer`, `boolean`, `is_object`, `record`, `datetime`, `language_code`, `regex`, `snake_case_name`… puis nettoyées par `fn::sanitize_object_execute` (trim, casse). Une entrée invalide renvoie `fn::error_result("ERROR_INVALID_INPUT", …, { fields })` (Q1).
  * Bornes : `limit` de 1 à 500 (50 par défaut) et `start` ≥ 0 sur les trois listes ; `start` est ajouté à `error_occurrence_list` (E-18).
  * Conflits et intégrité :
    * mapping en double → `ERROR_MAPPING_ALREADY_EXISTS` (E-02) ;
    * définition cible inexistante à la création ou à la mise à jour → `ERROR_DEFINITION_NOT_FOUND` (E-08) ;
    * préfixe → Q5.
  * `error_log` accepte `source` et `actor` (enregistrements), `request_id` et `fingerprint` (E-04, E-20).
  * Le mode `regex` est retiré du schéma (Q4).
  * `PERMISSIONS FULL` explicite sur chaque fonction (E-17). `COMMENT` et en-têtes réécrits en UTF-8 (E-14).

### 3.2. Codes d'erreur (`error/error_definitions.surql`)

* **Conservés** : `ERROR_DEFINITION_NOT_FOUND`, `ERROR_DEFINITION_ALREADY_EXISTS`, `ERROR_MAPPING_NOT_FOUND`, `ERROR_OCCURRENCE_NOT_FOUND`.
* **Nouveaux** :
  * `ERROR_INVALID_INPUT` (remplace `ERROR_PARAM_REQUIRED`, Q1) ;
  * `ERROR_MAPPING_ALREADY_EXISTS` ;
  * `ERROR_DEFINITION_CODE_PREFIX_MISMATCH` (Q5) ;
  * `ERROR_INVALID_FUNCTION_RESPONSE` : réponse SurrealQL non conforme détectée côté Rust, il remplace `CORE_INVALID_FUNCTION_RESPONSE` (E-09).
* **Supprimés** : `ERROR_PARAM_REQUIRED`, `CORE_ERROR_DEFINITION_NOT_FOUND` (E-13).
* `error/core/core_definitions.surql` (codes `CORE_*` de `lyxal_core`) est inchangé.

### 3.3. Rust (`src/`)

* `LyxalResult<T>` et `LyxalError` sont inchangés.
* `LyxalCallError` perd `BusinessCode` (Q6). Pour `InvalidContract`, `IntoResponse` émet `ERROR_INVALID_FUNCTION_RESPONSE`.
* DTO `*Params` alignés sur le contrat canonique (E-10) :
  * renommages `match_type` → `matcher` et `target_code` → `definition_code` ;
  * suppression des doublons `active`, `http_status` (mapping) et `external_code` (mise à jour) ;
  * `service` ajouté à `ErrorMapExternalParams` ;
  * `request_id`, `fingerprint` et `RecordId` pour `source` et `actor` dans `ErrorLogParams` ;
  * `Datetime` pour `before_date`, `start` dans `ErrorOccurrenceListParams` ;
  * `ErrorLogParams` couvre `fn::error_log` ; `ErrorOccurrenceCreateParams` n'existe pas.
* **Nouveaux types de résultat** (§13, `XxxResult`), en structures nommées `SurrealValue` : `ErrorDefinition`, `ErrorMapping`, `ErrorOccurrence`, `ErrorExternalMatch` (résultat de `error_map_external`), `DisableResult`, `PurgeResult`.

### 3.4. Fichiers

* **Supprimés** :
  * `CHANGELOG.md`, `LYXAL_ERROR_CLOSURE_CTO_REPORT.md`, `ROADMAP.md`, `features.md`, `SCHEMA_DOCUMENTATION.md`, `history.txt` et le `Cargo.lock` local (E-15) ;
  * `migrations/` (Q8) et `seeds/` (Q7) ;
  * `functions/service/error_get.surql` (Q2) et `functions/occurrence/error_occurrence_create.surql` (Q3).
* **`README.md` réécrit** à l'état actuel : SurrealDB 3.3.4, contrat, fonctions, codes, types Rust. Le contenu utile de `SCHEMA_DOCUMENTATION.md` y est reporté.
* **`manifest.toml`** mis à jour (18 fonctions, sans migration ni seeds).

## 4. Fonctions `lyxal_core` réutilisées, nouvelles fonctions, besoins Core

* **Réutilisées** :
  * `fn::validation_object_execute` et `fn::sanitize_object_execute` (moteur unique) ;
  * règles `required_string`, `optional_string`, `enum`, `integer`, `boolean`, `is_object`, `record`, `datetime`, `language_code`, `regex`, `snake_case_name` et `identifier`. Ici, `regex` sert à vérifier un code d'erreur contre un motif fixe écrit par le développeur, jamais un motif saisi par un utilisateur.
* **Nouvelles fonctions** : aucune ; deux fonctions sont supprimées.
* **Besoin Core éventuel** : aucun avec la proposition Q4 (retrait de `regex`). Si vous préférez garder les correspondances par expression régulière, la validation de la syntaxe d'un motif est un besoin d'extension (§5.7.7) non couvert par le Core, à traiter avant ce lot. Aucune primitive ne sera ajoutée au Core sans votre accord.
* **Crypto** : aucun besoin.

## 5. Tests

* Les tests d'intégration Rust (moteur embarqué `mem://`) sont réécrits pour le contrat cible. Un cas est ajouté par écart corrigé :
  * valeur hors liste → `ERROR_INVALID_INPUT` avec `fields` ;
  * doublon de mapping ;
  * mode `regex` refusé (`ERROR_INVALID_INPUT`) ;
  * `source` sous forme d'enregistrement ;
  * préfixe ;
  * cible inexistante ;
  * bornes de `limit` ;
  * `error_resolve` sans code → `CORE_INVALID_ARGUMENT`.
* Les tests de contrat Rust couvrent les nouveaux types de résultat et l'absence de `BusinessCode`.
* `test_no_orphan_surql_files` et la validation du manifeste restent actifs.

## 6. Lots (une PR par lot, CI verte obligatoire)

Chaque changement de contrat est livré **avec** la mise à jour de tous ses appelants (SurrealQL, DTO Rust, modules dépendants) et de ses tests, dans la même PR (§0.3, point 1). Aucun lot ne laisse le workspace dans un état intermédiaire cassé.

| Lot | Contenu |
| :- | :--- |
| 1 | **Nettoyage sans changement de contrat** : suppression des documents historiques, de la migration vide, des seeds de démonstration et de `CORE_ERROR_DEFINITION_NOT_FOUND` (aucun appelant) ; encodage UTF-8 ; `PERMISSIONS FULL` explicite ; README à l'état actuel ; manifeste. |
| 2 | **Contrat SurrealQL et DTO Rust, ensemble** : validation par le Core et `ERROR_INVALID_INPUT` ; suppression des alias **et** renommage des DTO correspondants (`matcher`, `definition_code`…) ; suppression de `error_get` **avec** la réécriture de `error_resolve` et `error_log` qui l'appelaient ; suppression de `error_occurrence_create` ; conflits, intégrité, préfixe, retrait de `regex`, `error_log` complet, bornes ; types de résultat ; tests d'intégration et de contrat. |
| 3 | **`LyxalCallError`** : suppression de `BusinessCode` **avec** la mise à jour de `lyxal_pipeline_ingestion` et de `lyxal_booking/engine` (hors workspace, compilation vérifiée à la main) ; `ERROR_INVALID_FUNCTION_RESPONSE` ; tests. |
| 4 | **Clôture** : audit de contrôle (`lyxal-audit`, aucun écart P0/P1), suppression de `AUDIT.md` et de ce plan. |

## 7. Checklist §13 (extraits)

* [x] La responsabilité appartient au module (contrat d'erreur, catalogue, journal, correspondances).
* [x] `lyxal_core` vérifié ; aucune primitive dupliquée ; entrées traitées par le moteur unique (§5.7.8).
* [x] Signatures `$params: object` (hors les 3 primitives), retour `result_ok` / `error_result`, `COMMENT`, moins de 300 lignes.
* [x] DTO `*Params` et types de résultat définis ; aucun `panic!` ; aucun secret.
* [x] Codes `ERROR_*` identifiés, master data prévue, aucune erreur silencieuse.
* [x] Zéro dette : alias, code mort, documents historiques et migration vide supprimés ; version `0.1.0`.
* [ ] Validation explicite du CTO.
