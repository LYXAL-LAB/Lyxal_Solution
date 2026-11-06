# Audit de reprise — `lyxal_base`

Audit en lecture seule (skill `lyxal-audit`), réalisé sur `main` après la clôture de
`lyxal_pipeline_ingestion` (#65 à #71).

## 1. Périmètre et position dans le graphe

* **Module** : `crates/lyxal_base`, **SurrealQL uniquement** (pas de crate Rust). 2 tables
  (`schema/`), 10 fonctions (`functions/`), 23 définitions d'erreurs et 2 fichiers de seeds
  (`seeds/`), environ 1 900 lignes de SurrealQL. Aucun test, aucun `README.md`, aucune
  `ROADMAP.md`.
* **Niveau** : référentiel transversal (`AGENTS.md` §6). Manifeste : dépend de `lyxal_core` et
  `lyxal_error`. Hébergé par `apps/lyxal-server` (`build.rs`, `ManifestModule`).
* **Consommateurs** (aucun n'appelle `fn::base_*`) :
  * `lyxal_catalogue` : 4 champs `record<base_unite>` (`catalogue_item.unite_reference`,
    `catalogue_item.conditionnement.type_unite`, `catalogue_composition_ligne`,
    `catalogue_attribut.unite`) ; lit `base_unite.enabled` pour refuser une unité inactive ;
  * `lyxal_pipeline_ingestion` : `fn::ingestion_resolve_unit` lit `base_unite.code` ; la
    publication écrit `base_unite:<CODE>` dans le conditionnement des articles.

Fichiers lus intégralement : `manifest.toml`, `schema/*`, `functions/**`, `seeds/*`,
`implementation_plan.md` ; côté consommateurs : `lyxal_catalogue/schema/02_catalogue_item.surql`,
`lyxal_pipeline_ingestion/src/normalization/units.rs`,
`lyxal_pipeline_ingestion/seeds/03_initial_aliases.surql`,
`lyxal_pipeline_ingestion/tests/it/integration_phase4_alignment.rs`.

## 2. Synthèse et verdict

**NON CONFORME (P0 et P1 bloquants).**

Le module s'installe depuis son manifeste, ses seeds sont rejouables (`IF !record::exists`),
ses tables sont protégées (lecture pour tous, écriture réservée à l'administration) et chaque
code émis est défini. Mais, vérifié sur un serveur SurrealDB 3.3.4 :

1. les fonctions de mise à jour et de suppression acceptent un identifiant **de n'importe quelle
   table** : `fn::base_unite_type_delete({ id: error_definition:BASE_PAGINATION_INVALID })`
   supprime la définition d'erreur et répond `ok` ;
2. une écriture refusée par les permissions est annoncée comme un succès (`ok: true`,
   `data: null`) ;
3. une unité référencée par un article du catalogue peut être supprimée : la référence reste
   pendante ;
4. les entrées ne passent jamais par `lyxal_core` ; plusieurs entrées invalides lèvent une
   erreur SurrealDB brute ou renvoient un résultat faux sans erreur ;
5. le module n'a **aucun test**.

## 3. Écarts constatés

| ID | Sév. | Règle | Fichier & lignes | Preuve | Correction recommandée |
| :- | :- | :--- | :--- | :--- | :--- |
| B-01 | P0 | Intégrité des données, §5.7.8 | `functions/unite_type/unite_type_delete.surql:19-29`, `unite_type_update.surql:21-31`, `unite/unite_delete.surql:18-28`, `unite/unite_update.surql:22-32`, `unite/unite_get.surql:16-27`, `unite_type/unite_type_get.surql:14-21` | Un identifiant natif est pris tel quel, sans contrôle de table. Sonde 3.3.4 : `fn::base_unite_type_delete({ id: error_definition:BASE_PAGINATION_INVALID })` → `{ ok: true, data: { deleted: true } }`, puis `record::exists(...)` = `false`. `update` fusionne (`MERGE`) dans l'enregistrement d'une autre table ; `get` renvoie un enregistrement d'une autre table. | Règle `record` du Core avec `expected_table` (`base_unite` / `base_unite_type`) ; identifiants transmis en texte, comme au catalogue. |
| B-02 | P1 | §11.4 (écritures filtrées) | `unite_type_create.surql:44`, `unite_type_update.surql:59`, `unite_type_delete.surql:58`, `unite_create.surql:84`, `unite_update.surql:121`, `unite_delete.surql:46` | Sonde sous un jeton d'utilisateur : `fn::base_unite_type_create(...)` → `{ ok: true, data: null }`, rien n'est écrit ; idem pour `update`. Aucun code `BASE_WRITE_FORBIDDEN`. | Résultat de chaque écriture vérifié (`DELETE ... RETURN BEFORE`) ; `BASE_WRITE_FORBIDDEN` ; tests sous une identité non autorisée. |
| B-03 | P1 | Intégrité référentielle | `unite/unite_delete.surql:45-46` ; `schema/base_unite.surql:64-68` ; `lyxal_catalogue/schema/02_catalogue_item.surql:78-81` et `:173-175` | Le commentaire annonce une suppression « non référencée » ; aucun contrôle n'est fait (`BASE_UNITE_IN_USE` est défini mais jamais émis). Les champs `REFERENCE` sont en `ON DELETE IGNORE` par défaut : sonde 3.3.4, la suppression de la cible laisse la référence en place. `catalogue_item.conditionnement.type_unite` n'a même pas `REFERENCE` (les 3 autres champs du catalogue l'ont, sans `ON DELETE`). `unite_type_delete` ne compte que les unités de `base_unite`. | Q1 : références entrantes comptées de façon générique (`<~?`, vérifié en 3.3.4) → `BASE_UNITE_IN_USE` / `BASE_UNITE_TYPE_IN_USE` ; `REFERENCE ON DELETE REJECT` sur tous les champs qui pointent vers `lyxal_base`. |
| B-04 | P1 | §5.7.8 (entrées par `lyxal_core`) | `functions/**` (10 fonctions, 0 appel `fn::validation_*` / `fn::sanitize_*`) | Contrôles et nettoyage locaux (`string::trim`, `string::uppercase`, `string::is_alphanum`, bornes de longueur), recopiés dans 6 fonctions. Sondes : `language: 42` → erreur brute `string::trim()` ; `enabled: "oui"` → erreur brute `Could not cast into bool` ; `fn::base_unite_list({ type: "base_unite_type:LONGUEUR" })` → 0 résultat sans erreur (4 attendus) ; `fn::base_unite_get({ id: "base_unite:M" })` → `data` = la chaîne elle-même. Champs inconnus acceptés en silence. | Moteur `fn::validation_object_execute` puis `fn::sanitize_object_execute` (`unknown_keys: "reject"`), erreur `BASE_INVALID_PARAMETERS` avec le détail par champ. |
| B-05 | P1 | Tests (§13) | `crates/lyxal_base/` (aucun dossier `tests/`) | Aucun test : ni permissions, ni règles de hiérarchie (unité active sur type inactif), ni protection du socle système. | Banc SurrealQL `tests/*.test.surql` exécuté par la CI (`scripts/ci/test_lyxal_modules.py`), chaque fonction appelée. |
| B-06 | P2 | §5.5 (`error/<thème>/`) | `seeds/error_definitions.surql` (23 définitions, déclaré en `error_definitions`) | Définitions rangées dans `seeds/` au lieu de `error/<thème>/`. 12 codes par champ (`*_CODE_REQUIRED`, `*_LIBELLE_INVALID`, `BASE_PAGINATION_INVALID`…) deviennent inutiles avec le rapport par champ du Core. | `error/{parametres,permissions,unite_type,unite}/` ; codes par champ remplacés par `BASE_INVALID_PARAMETERS`. |
| B-07 | P2 | §5.1 (un seul endroit) | `schema/*.surql` (`VALUE string::uppercase(string::trim($value))`) ; fonctions | Le nettoyage est fait deux fois : dans la fonction et dans le `VALUE` du schéma. Les libellés sont stockés en majuscules (`MÈTRE CARRÉ`), y compris les libellés saisis. `created_at` / `updated_at` sont passés à la main alors que le schéma les calcule. | Nettoyage par le Core dans la fonction ; le schéma garde ses `ASSERT` (intégrité) ; casse des libellés : Q2. |
| B-08 | P2 | Couverture du référentiel | `seeds/unite_initial.surql` (21 unités) ; `lyxal_pipeline_ingestion/src/normalization/units.rs:6-31` ; `lyxal_catalogue/schema/02_catalogue_item.surql:175` | 11 codes canoniques de l'ingestion n'existent pas dans `base_unite` : conditionnements `ROUL`, `SAC`, `PAL`, `BTE`, `CART` ; grandeurs `KWH`, `W`, `BAR`, `M3H` ; `G` et `LTR` (le référentiel a `GR` et `L`). Le catalogue cite `base_unite:ROUL` en exemple. Un article vendu au rouleau ne peut pas être publié. | Q3. |
| B-09 | P2 | §1 (contrats publics) | `lyxal_pipeline_ingestion/tests/it/integration_phase4_alignment.rs:163-167` | Un test d'un module consommateur écrit directement dans `base_unite` (`UPSERT`, champ `symbole` hors schéma, `abreviation` et `type` absents) sans vérifier le résultat de la requête. | Création par `fn::base_unite_create`, résultat vérifié. |
| B-10 | P2 | §0.2, §0.3.4 | `implementation_plan.md` (« V4 (Final) … validée pour mise en production ») ; `docs/01-architecture/AUDIT_SURREALDB_RELATION_TABLES.md:11,45,373,384` | Plan déjà exécuté ; `lyxal_base` présenté comme « V1.0 », liens `file:///c:/Users/...`. Pas de `README.md` ni de `ROADMAP.md`. | Plan remplacé par celui-ci, supprimé à la clôture ; `README.md` et `ROADMAP.md` créés ; liens corrigés. |

## 4. Correspondance des appels

Pas de DTO Rust et aucun appelant de `fn::base_*` dans le dépôt. Les consommateurs utilisent
directement les tables : `base_unite` et `base_unite_type` (champs `code`, `enabled`, `type`)
forment donc un **contrat public de fait**, à documenter dans le `README.md`.

| Consommateur | Usage | Statut |
| :--- | :--- | :--- |
| `lyxal_catalogue` | `record<base_unite>` sur 4 champs ; contrôle `enabled` | conforme ; `REFERENCE` absent sur `conditionnement.type_unite`, `ON DELETE` absent partout (B-03) |
| `lyxal_pipeline_ingestion` (`fn::ingestion_resolve_unit`) | lecture de `base_unite.code` | conforme |
| `lyxal_pipeline_ingestion` (publication) | `base_unite:<CODE>` construit depuis l'unité normalisée | 11 codes absents (B-08) |

## 5. Preuves d'exécution et points non vérifiés

* **Exécuté** (serveur SurrealDB 3.3.4 jetable, module installé depuis son manifeste par le banc
  `scripts/ci/test_lyxal_modules.py`, sonde temporaire non conservée) :
  * suppression d'un enregistrement d'une autre table (B-01) ;
  * écritures sous une identité non autorisée annoncées comme réussies (B-02) ;
  * entrées invalides : erreurs brutes et liste vide à tort (B-04) ;
  * références entrantes : `SELECT VALUE <~? FROM ONLY <cible>` liste toutes les références
    déclarées `REFERENCE`, quelle que soit la table ; la suppression de la cible laisse la
    référence pendante (B-03).
* **Contrôles statiques** : manifeste contre fichiers, signatures, codes émis contre codes
  définis (22 émis, 23 définis, `BASE_UNITE_IN_USE` jamais émis), idempotence des seeds,
  permissions des tables, constructions 2.x, longueur des fonctions, consommateurs.
* **Non vérifié** : `REFERENCE ON DELETE REJECT` sur un champ imbriqué
  (`conditionnement.type_unite`) — à prouver au lot correspondant.

## 6. Éléments conformes

* Aucune `fn::result_error` ; 10 fonctions en `$params: object`, retour `fn::result_ok` /
  `fn::error_result`, `COMMENT` présents ; la plus longue fait 125 lignes.
* Manifeste conforme (version `0.1.0`, chaque fichier existe, aucun fichier oublié).
* Seeds et définitions d'erreurs rejouables (`IF !record::exists(...) THEN ( CREATE ... ) END`),
  identifiants déterministes ; préfixe `BASE_` respecté.
* 2 tables `TYPE NORMAL SCHEMAFULL` ; lecture pour tous, écriture réservée à l'administration
  (session root ou système), comme les référentiels du catalogue ; socle système protégé
  (`is_system`, `READONLY`).
* Règles de hiérarchie présentes : pas d'unité active sur un type inactif ; liste « nouveaux
  documents » filtrée sur l'unité et son type.
* Aucune construction SurrealQL 2.x.

## 7. Plan correctif

Voir `implementation_plan.md` : trois décisions, puis les lots.
