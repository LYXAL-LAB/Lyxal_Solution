# Audit de reprise — `lyxal_catalogue`

Audit en lecture seule (skill `lyxal-audit`), réalisé sur `main` après la clôture de
`lyxal-server` (#54 à #58).

## 1. Périmètre et position dans le graphe

* **Module** : `crates/lyxal_catalogue`, **SurrealQL uniquement** (pas de crate Rust). 13 tables
  (`schema/`), 24 fonctions (`functions/`), 6 fichiers d'erreurs (`error/`), 5 fichiers de seeds,
  8 fichiers de tests `.surql` et un script PowerShell, environ 9 600 lignes de SurrealQL.
* **Niveau** : module métier (`AGENTS.md` §6). Manifeste : dépend de `lyxal_core` et
  `lyxal_base`.
* **Consommateur** : `lyxal_pipeline_ingestion` appelle `fn::catalogue_item_create` et
  `fn::catalogue_item_update` pour publier vers le catalogue maître, **sans déclarer la
  dépendance** dans son manifeste. Le catalogue n'est pas hébergé par `lyxal-server`.

Fichiers lus intégralement ou par extraits ciblés : `manifest.toml`, `schema/*`,
`functions/item/*`, `functions/item/catalogue_validate_gtin.surql`, `error/*`,
`seeds/*`, `tests/run_cto_security_suite.ps1`, `README.md`, `CHANGELOG.md`, `ROADMAP.md`,
`implementation_plan.md` ; côté ingestion : `src/publisher/controlled_publisher.rs`,
`src/normalization/gtin.rs`.

## 2. Synthèse et verdict

**NON CONFORME (P1 bloquants).**

Le catalogue a un schéma riche et protégé (13 tables `TYPE NORMAL SCHEMAFULL` avec permissions,
gardes d'intégrité par `DEFINE EVENT`, isolation par `tenant_id`, contrat JWT documenté) et
s'installe depuis son manifeste. Mais :

1. ses entrées ne passent jamais par `lyxal_core` : nettoyage et contrôles écrits localement,
   conversions qui lèvent une erreur brute sur une donnée invalide ;
2. ses seeds et définitions d'erreurs ne sont **pas rejouables** : une installation interrompue
   ne peut pas reprendre (vérifié : deuxième installation en échec sur l'index unique des codes) ;
3. six codes d'erreur sont émis sans définition, et les définitions existent en double ;
4. il n'a **aucun test exécuté par la CI** (suite PowerShell contre SurrealDB 3.2.0) ;
5. l'appel de l'ingestion vers `fn::catalogue_item_create` ne peut pas réussir : les champs
   envoyés ne sont pas ceux du contrat.

## 3. Écarts constatés

| ID | Sév. | Règle | Fichier & lignes | Preuve | Correction recommandée |
| :- | :- | :--- | :--- | :--- | :--- |
| C-01 | P1 | §5.5 (seeds rejouables) | `seeds/*.surql` (169 `CREATE` nus) | Aucune protection `record::exists` / `INSERT IGNORE`. Installation rejouée : `Database index error_definition_code_unique already contains 'CATALOGUE_ITEM_NOT_FOUND'`. `pilote_btp_habitat.surql` contient en plus 2 `UPSERT` (interdits). | `IF !record::exists(...) THEN ( CREATE ... ) END;` partout, identifiants déterministes (`error_definition:<CODE>`). |
| C-02 | P1 | §5.7.8 (entrées par `lyxal_core`) | `functions/**` (24 fonctions, 0 appel `fn::validation_*` / `fn::sanitize_*`) | Nettoyage local (`string::trim`, `string::uppercase`) et défauts recopiés champ par champ ; conversions `<record<catalogue_type>> $params.type` qui lèvent une erreur SurrealDB brute au lieu de `CATALOGUE_*` (ex. `catalogue_item_create.surql:8-10`). | Moteur `fn::validation_object_execute` puis `fn::sanitize_object_execute`, erreur `CATALOGUE_INVALID_PARAMETERS` avec le détail par champ. |
| C-03 | P1 | §5.5 (codes définis) | `functions/item/*` | Codes émis sans définition : `CATALOGUE_ITEM_CODE_IMMUTABLE`, `CATALOGUE_ITEM_NATURE_IMMUTABLE`, `CATALOGUE_ITEM_TYPE_IMMUTABLE`, `CATALOGUE_ITEM_SYNC_CANNOT_CREATE_MASTER`, `CATALOGUE_ITEM_SYNC_CANNOT_OVERWRITE_LOCAL_CUSTOMIZATION`, `CATALOGUE_ITEM_SYNC_CANNOT_REACTIVATE_DISABLED`. | Définitions ajoutées ; test qui vérifie que chaque code émis est défini. |
| C-04 | P1 | §5.1, §5.8.1 | `error/**` (46 définitions) ; `seeds/error_definitions.surql` (68) ; `manifest.toml` | Les définitions de `error/` ne sont pas déclarées dans le manifeste et recopient une partie de `seeds/error_definitions.surql` (déclaré en `seeds`, pas en `error_definitions`). Dépendance `lyxal_error` (`fn::error_result`) non déclarée. Seeds `btp_lot1_commercial.surql` et `pilote_btp_habitat.surql` non déclarés. | Une seule source : `error/<thème>/*.surql`, déclarés en `error_definitions` ; dépendance `lyxal_error` ; seeds non déclarés traités en Q3. |
| C-05 | P1 | §5.3 (`$params: object`), §5.7.5-5.7.7 (primitive générique) | `functions/item/catalogue_validate_gtin.surql:8` ; `lyxal_pipeline_ingestion/src/normalization/gtin.rs:36` | Fonction publique positionnelle `fn::catalogue_validate_gtin($gtin: string)` renvoyant un booléen. La clé GS1 modulo 10 est une règle générique, écrite une fois en SurrealQL ici et une fois en Rust dans l'ingestion ; `lyxal_core` n'a que `fn::validation_luhn`. | Q1 : primitive `fn::validation_gtin` dans `lyxal_core` (extension soumise au CTO, §5.7.7), utilisée par le catalogue ; fonction locale supprimée. |
| C-06 | P1 | Tests | `tests/*.surql`, `tests/run_cto_security_suite.ps1` | Suite PowerShell contre SurrealDB 3.2.0, jamais exécutée par la CI (la CI ne fait que valider la syntaxe). Aucune preuve automatisée des permissions, de l'isolation par tenant, des gardes anti-cycle. | Q4 : tests au format du banc `lyxal_core` (`*.test.surql`, assertions) exécutés par la CI contre SurrealDB 3.3.4. |
| C-07 | P1 | §1 (contrats publics), §5.8.1 | `lyxal_pipeline_ingestion/src/publisher/controlled_publisher.rs:233-243` ; `lyxal_pipeline_ingestion/manifest.toml` | L'ingestion envoie `gtin`, `type_item`, `unite`, sans `code` ; le contrat attend `code_barre`, `type` (`record<catalogue_type>`), `unite_reference` et `code`. La publication échoue donc toujours. La dépendance `lyxal_catalogue` n'est pas déclarée. | Contrat de `fn::catalogue_item_create` / `_update` documenté ici ; mise en conformité de l'appelant à la reprise de l'ingestion. |
| C-08 | P2 | §0.2, §0.3.3, §0.3.4 | `CHANGELOG.md`, `ROADMAP.md`, `implementation_plan.md` (rapport d'exécution du 2026-10-23), `README.md` ; `manifest.toml` (`version = "1.0.0"`) | Documents historiques, version jamais livrée, liens `file:///c:/Users/...`. | Suppression ; `README.md` à l'état actuel ; version `0.1.0`. |
| C-09 | P2 | §1 (`COMMENT`) | `functions/variante/catalogue_variante_set_attributs.surql`, `functions/composition/catalogue_composition_publish.surql` | Fonctions publiques sans `COMMENT`. | `COMMENT` ajouté. |
| C-10 | P2 | Hébergement | `apps/lyxal-server/build.rs` | Le catalogue n'est pas installé par le serveur. | Inscription dans `build.rs` (`ManifestModule`), test de démarrage et de rejeu. |

## 4. Correspondance des appels (DTO ↔ `$params`)

Pas de DTO Rust dans le module. Seul appelant : la publication de l'ingestion vers
`fn::catalogue_item_create`.

| Champ | Ingestion envoie | Catalogue lit | Statut |
| :--- | :--- | :--- | :--- |
| référence fabricant | `reference_fabricant` | `reference_fabricant` | conforme |
| fabricant, marque, libellé | `fabricant`, `marque`, `libelle` | idem | conformes |
| conditionnement | `conditionnement` | `conditionnement` | conforme |
| tenant | `tenant_id` (null) | `tenant_id` | conforme |
| code-barres | `gtin` | `code_barre` | **incompatible** |
| type | `type_item` (texte `PRODUIT`…) | `type` (`record<catalogue_type>`) | **incompatible** |
| unité | `unite` | `unite_reference` (`record<base_unite>`) | **incompatible** |
| code article | — | `code` (requis) | **absent côté appelant** |
| autres (`nature_reference`, `master_id`, `is_custom`, `categories`…) | — | lus avec défaut | non transmis |

## 5. Preuves d'exécution et points non vérifiés

* **Exécuté** :
  * installation depuis le manifeste par `lyxal_runtime` (noyau, `lyxal_base`, catalogue) sur
    base embarquée : **réussie** ;
  * deuxième installation (reprise) : **échec** sur `seeds/error_definitions.surql` (C-01) ;
  * `surreal validate` (CI) : réussi.
* **Contrôles statiques** : signatures, `THROW`, appels `lyxal_core`, codes émis contre codes
  définis, idempotence des seeds, permissions des tables, comparaison avec l'appel de
  l'ingestion.
* **Non vérifié** : comportement des permissions et des gardes (aucun test exécuté, C-06) ; les
  43 `THROW` des gardes `DEFINE EVENT` (intégrité du schéma, motif accepté ailleurs) n'ont pas
  été revus un par un.

## 6. Éléments conformes

* Aucune `fn::result_error` ; 23 fonctions sur 24 en `$params: object` ; retour
  `fn::result_ok` / `fn::error_result`.
* 13 tables `TYPE NORMAL SCHEMAFULL` avec permissions explicites ; isolation des articles privés
  par `tenant_id` ; contrat JWT documenté (`docs/JWT_TRUST_CONTRACT.md`).
* Gardes anti-cycle (catégories, compositions, relations) ; aucune construction SurrealQL 2.x.
* Préfixe `CATALOGUE_` respecté ; fonctions sous 300 lignes (la plus longue : 228).

## 7. Plan correctif

Voir `implementation_plan.md` : quatre décisions, puis les lots.
