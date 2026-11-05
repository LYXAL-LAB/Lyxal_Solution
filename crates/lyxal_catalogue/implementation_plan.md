# Plan d'implémentation — reprise de `lyxal_catalogue`

Suite de `AUDIT.md`. **Q1 à Q4 validées par le CTO** (option A pour chacune).

> Ce fichier remplace l'ancien `implementation_plan.md` du module (rapport d'exécution du
> 2026-10-23), document historique supprimé par cette reprise (§0.2).

## 1. Décisions demandées

| # | Question | Options | Recommandation |
| :- | :--- | :--- | :--- |
| Q1 | Validation GTIN (C-05) ? | **A.** Nouvelle primitive `fn::validation_gtin($value, $required)` dans `lyxal_core/validation` (GTIN-8/12/13/14, clé GS1 modulo 10, résultat `{ valid, value, code, details }`, règle `gtin` au catalogue du moteur), avec ses tests au banc `lyxal_core`. **B.** Garder une fonction propre au catalogue, mise en `$params: object`. | **A** : règle générique (aucune table ni état métier), déjà dupliquée entre le catalogue et l'ingestion ; extension du Core soumise à ta validation (§5.7.7). |
| Q2 | Validation des entrées (C-02) ? | **A.** Moteur `fn::validation_object_execute` + `fn::sanitize_object_execute` pour les 23 fonctions (toutes appelables par d'autres modules ou l'UI), champs inconnus refusés. **B.** Primitives champ par champ. | **A** : même règle que `lyxal_event` (option B du CTO : moteur pour les fonctions appelées de l'extérieur) ; aucune fonction du catalogue n'est interne à un moteur chaud. |
| Q3 | Seeds de démonstration `btp_lot1_commercial.surql` (64 articles) et `pilote_btp_habitat.surql` (25, avec `UPSERT`), non déclarés (C-04) ? | **A.** Déplacés en jeux de données de test (`tests/fixtures/`), jamais installés. **B.** Déclarés en seeds (installés partout, y compris en production). **C.** Supprimés. | **A** : ce sont des données de démonstration ; elles servent de jeux d'essai aux tests sans entrer dans une installation réelle. |
| Q4 | Tests (C-06) ? | **A.** Banc SurrealQL de `lyxal_core` étendu au catalogue (`tests/*.test.surql` au format assertions, exécutés par la CI contre SurrealDB 3.3.4, avec jetons simulés pour les rôles). **B.** Crate Rust de tests uniquement. **C.** Garder PowerShell. | **A** : module 100 % SurrealQL ; même outillage que `lyxal_core`, exécuté par la CI. |

## 2. Contrat cible (si Q1-A à Q4-A)

### SurrealQL

* 23 fonctions publiques inchangées dans leur nom et leurs champs, sauf :
  * validation et nettoyage par le moteur `lyxal_core` ; donnée invalide → `CATALOGUE_INVALID_PARAMETERS` (`details.fields`) au lieu d'une erreur de conversion brute ;
  * `fn::catalogue_validate_gtin` supprimée ; contrôle par la règle `gtin` du Core dans `fn::catalogue_item_create` / `_update` (code `CATALOGUE_ITEM_GTIN_INVALID`).
* Contrat de `fn::catalogue_item_create` documenté dans le README (champs requis : `code`,
  `type`, `libelle`, `unite_reference` ; champs optionnels listés), référence pour la mise en
  conformité de l'ingestion.

### Erreurs (`error/<thème>/*.surql`)

* Source unique : `error/` (fusion avec `seeds/error_definitions.surql`, supprimé), déclarée en
  `error_definitions`, forme `IF !record::exists(error_definition:<CODE>)`.
* Ajouts : `CATALOGUE_INVALID_PARAMETERS`, les 6 codes émis sans définition (C-03),
  `CATALOGUE_ITEM_GTIN_INVALID` si absent.
* Test : chaque code passé à `fn::error_result` dans `functions/` est défini dans `error/`.

### Manifeste

* `version = "0.1.0"` ; dépendances `lyxal_core`, `lyxal_error`, `lyxal_base` ;
  `error_definitions` déclaré ; seeds de référence seulement (`catalogue_type_initial`,
  `catalogue_relation_type_initial`), rejouables.

### `lyxal_core`

* Réutilisées : `fn::validation_object_execute`, `fn::sanitize_object_execute` et les règles des
  catalogues (`required_string`, `record_id`, `enum`, `trim`, `uppercase`…).
* **Nouvelle (Q1)** : `fn::validation_gtin` + règle `gtin`.

### Appelants à mettre à jour dans le même changement

* Aucun appelant de `fn::catalogue_validate_gtin` hors du module. La mise en conformité de la
  publication de l'ingestion (C-07) relève de sa reprise, qui suit ; elle s'appuiera sur le
  contrat documenté ici.

## 3. Tests

* Installation depuis le manifeste puis **rejeu** sans erreur ni doublon (test serveur
  `module_resources_are_replayable`, catalogue hébergé).
* Banc SurrealQL : création / mise à jour / suppression d'articles (maître par l'agent de
  synchronisation, privé par un `tenant_user`), isolation entre tenants, refus des rôles non
  autorisés, catégories et gardes anti-cycle, compositions et relations, variantes, entrées
  invalides → `CATALOGUE_INVALID_PARAMETERS`, GTIN invalide.
* Chaque code émis est défini.

## 4. Lots

| Lot | Contenu |
| :- | :--- |
| 1 ✅ | **Installation et master data** (C-01, C-03, C-04, C-08 en partie, C-10) : `error/<thème>/*.surql` source unique (68 définitions reprises de `seeds/error_definitions.surql`, supprimé, + 6 codes manquants), protégées par `record::exists` et déclarées en `error_definitions` ; seeds de référence rejouables ; seeds de démonstration déplacés dans `tests/fixtures/` (Q3) ; manifeste `0.1.0` avec dépendance `lyxal_error` ; catalogue hébergé par le serveur (`build.rs`) ; test serveur `every_emitted_error_code_is_defined` (tous les modules repris ; l'ingestion, dont 14 codes émis n'ont pas de définition, y entrera à sa reprise). |
| 2 ✅ | **Primitive GTIN** (Q1, C-05) : `fn::validation_gtin($value)` dans `lyxal_core/validations` (GTIN-8/12/13/14, clé GS1 modulo 10, espaces et tirets retirés), règle `gtin` du moteur (176 règles), 13 tests au banc ; `fn::catalogue_validate_gtin` supprimée, garde de schéma et fonctions `catalogue_item_create` / `_update` sur la primitive du Core. |
| 3 ✅ | **Entrées par le Core** (Q2, C-02) : 21 fonctions publiques sur `fn::validation_object_execute` puis `fn::sanitize_object_execute` (champs inconnus refusés), donnée invalide → `CATALOGUE_INVALID_PARAMETERS` (`details.fields`) ; identifiants transmis en chaîne (`"table:id"` ou `"id"`), nombres acceptés en entier, flottant ou décimal ; textes facultatifs vides lus comme absents. Les deux gardes anti-cycle récursives (`catalogue_composition_check_cycle`, `catalogue_relation_check_cycle`) restent internes, appelées par le module avec des identifiants déjà validés. 12 définitions d'erreurs devenues inutiles supprimées (`*_REQUIRED`, `*_TYPE_INVALID`, `CATALOGUE_ITEM_NATURE_INVALID`, `CATALOGUE_PAGINATION_INVALID`, `CATALOGUE_VARIANTE_DUPLICATE_COMBINAISON`). Rupture de contrat : `categorie_update.parent` vaut `null` pour détacher une catégorie. |
| 4 ✅ | **Tests** (Q4, C-06) : `scripts/ci/test_lyxal_modules.py` (étend le banc `lyxal_core`) installe chaque module depuis son manifeste dans une base neuve et exécute ses `tests/*.test.surql` en CI, sous des identités JWT simulées (accès `RECORD WITH JWT`) ; toute fonction publique doit être appelée par un test. 6 fichiers, 179 assertions : articles (rôles, isolation entre locataires, champs maîtres), catégories, attributs et variantes, compositions (chaîne de 8 niveaux, cycles, verrouillage), relations, paramètres. Défauts révélés et corrigés : `error_definition`, `base_unite`, `base_unite_type` illisibles sous identité utilisateur (lecture ouverte, décision CTO) ; écriture refusée par les permissions annoncée comme un succès (`CATALOGUE_WRITE_FORBIDDEN`) ; variante sans combinaison impossible à modifier (verrou d'empreinte) ; combinaison en doublon remontée en erreur d'index brute (`CATALOGUE_VARIANTE_DUPLICATE_COMBINAISON` rétabli, empreinte calculée par `fn::catalogue_variante_fingerprint` seule) ; composition vide publiable (comptage). |
| 5 | **Clôture** : `README.md` à l'état actuel (dont le contrat de publication), `COMMENT` manquants (C-09), suppression de `CHANGELOG.md`, `ROADMAP.md`, `AUDIT.md` et de ce plan ; `AGENTS.md` aligné. |

Chaque lot fait l'objet d'une PR, fusionnée quand la CI est verte.
