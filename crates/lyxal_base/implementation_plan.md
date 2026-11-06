# Plan d'implémentation — reprise de `lyxal_base`

Suite de `AUDIT.md`. **Q1 à Q3 validées par le CTO** : Q1-A, Q2-A, Q3-A sans alias (codes du référentiel corrigés, voir ci-dessous).

> Ce fichier remplace l'ancien `implementation_plan.md` du module (« Plan V4 (Final) »), déjà
> exécuté, document historique supprimé par cette reprise (§0.2).

## 1. Décisions demandées

| # | Question | Options | Recommandation |
| :- | :--- | :--- | :--- |
| Q1 | Suppression d'une unité ou d'un type référencé (B-03) ? | **A.** Suppression conservée pour une entrée non système et **non référencée** : `lyxal_base` compte les références entrantes de façon générique (`<~?`, sans connaître les modules consommateurs) → `BASE_UNITE_IN_USE` / `BASE_UNITE_TYPE_IN_USE` ; en garantie, tous les champs qui pointent vers `lyxal_base` passent en `REFERENCE ON DELETE REJECT` (`base_unite.type` et les 4 champs du catalogue, dans le même changement). **B.** Plus de suppression physique : désactivation seulement, `fn::base_*_delete` supprimées. | **A** : une unité créée par erreur et jamais utilisée doit pouvoir disparaître ; une unité utilisée est protégée deux fois (message clair, puis refus par la base). Le module ne référence aucun consommateur. |
| Q2 | Casse des libellés (B-07) ? | **A.** Libellé conservé tel que saisi, espaces retirés (`Mètre carré`) ; codes toujours en majuscules ; seeds réécrits en casse normale. **B.** Libellés en majuscules, comme aujourd'hui (`MÈTRE CARRÉ`). | **A** : un libellé est un texte d'affichage (devis, factures, console) ; la majuscule est une présentation, pas une donnée. |
| Q3 | Unités absentes du référentiel (B-08) ? | **A.** Ajout aux seeds système : type `CONDITIONNEMENT` (`ROUL`, `SAC`, `PAL`, `BTE`, `CART`), types `ENERGIE` (`KWH`), `PUISSANCE` (`W`), `PRESSION` (`BAR`), `DEBIT` (`M3H`). ~~`G` et `LTR` restent des alias de `GR` et `L`~~ → **décision CTO : aucun alias ; un seed qui ne suit pas la norme est corrigé** : `GR` devient `G` (symbole SI du gramme) et `L` devient `LTR` (code UN/CEFACT du litre, `L` seul étant ambigu). **B.** Conditionnements seulement. **C.** Rien : à traiter dans la ROADMAP de l'ingestion. | **A** : chaque code canonique de l'ingestion existe alors dans le référentiel ; les articles vendus au rouleau, au sac ou à la palette deviennent publiables. |

## 2. Contrat cible (si Q1-A à Q3-A)

### SurrealQL

* 10 fonctions publiques inchangées dans leur nom, sauf :
  * entrées validées par `fn::validation_object_execute` puis nettoyées par
    `fn::sanitize_object_execute`, `unknown_keys: "reject"` ; donnée invalide →
    `BASE_INVALID_PARAMETERS` (`details.fields`), jamais d'erreur brute ;
  * identifiants transmis en texte et contrôlés par table (règle `record`,
    `expected_table: "base_unite"` / `"base_unite_type"`) : `id` de `get`, `update`, `delete`,
    `type` de `fn::base_unite_create`, `_update`, `_list`. Le raccourci par code nu
    (`type: "LONGUEUR"`) est supprimé : il reste `code` pour `get` ;
  * chaque écriture vérifiée → `BASE_WRITE_FORBIDDEN` ;
  * `delete` : refus si l'entrée est système (`*_IS_SYSTEM`) ou référencée (`*_IN_USE`, avec
    le nombre de références) ;
  * horodatages laissés au schéma ;
  * `fn::base_unite_get` renvoie en plus `usable` : unité **et** type actifs (règle
    « utilisable pour un nouveau document », à un seul endroit, partagée avec
    `fn::base_unite_list({ for_new_documents: true })`) (B-11).
* Rupture de contrat : aucun appelant de `fn::base_*` dans le dépôt.

### Schéma

* `base_unite.type` : `REFERENCE ON DELETE REJECT`.
* Le nettoyage (`VALUE string::uppercase(...)`) quitte le schéma pour la fonction ; les `ASSERT`
  restent. Code : majuscules, alphanumérique, 1 à 32 caractères ; libellé selon Q2.
* Catalogue (même changement, §0.3.1) : `REFERENCE ON DELETE REJECT` sur
  `catalogue_item.unite_reference`, `catalogue_item.conditionnement.type_unite`,
  `catalogue_composition_ligne.unite`, `catalogue_attribut.unite`.

### Erreurs (`error/<thème>/*.surql`)

* `error/parametres` : `BASE_INVALID_PARAMETERS`, `BASE_NO_UPDATABLE_FIELDS_PROVIDED`.
* `error/permissions` : `BASE_WRITE_FORBIDDEN`.
* `error/unite_type` : `BASE_UNITE_TYPE_NOT_FOUND`, `_ALREADY_EXISTS`, `_IS_SYSTEM`, `_IN_USE`.
* `error/unite` : `BASE_UNITE_NOT_FOUND`, `_ALREADY_EXISTS`, `_IS_SYSTEM`, `_IN_USE`,
  `BASE_UNITE_TYPE_INVALID` (type parent absent), `BASE_UNITE_TYPE_DISABLED`.
* Supprimés (remplacés par le détail par champ) : `BASE_PAGINATION_INVALID`,
  `BASE_UNITE_TYPE_CODE_REQUIRED`, `_CODE_INVALID`, `_LIBELLE_REQUIRED`, `_LIBELLE_INVALID`,
  `BASE_UNITE_CODE_REQUIRED`, `_CODE_INVALID`, `_LIBELLE_REQUIRED`, `_LIBELLE_INVALID`,
  `_ABREVIATION_REQUIRED`, `_ABREVIATION_INVALID`, `BASE_UNITE_TYPE_REQUIRED`.
* 13 définitions ; `seeds/error_definitions.surql` supprimé.

### Seeds

* Libellés selon Q2 ; unités et types ajoutés selon Q3 (`is_system: true`), rejouables.
* Codes corrigés (Q3, sans alias) : `base_unite:GR` → `base_unite:G`, `base_unite:L` → `base_unite:LTR`. Chaque code canonique de l'ingestion (`normalization/units.rs`) existe alors dans le référentiel ; un test le vérifie.

### `lyxal_core`

* Réutilisées : `fn::validation_object_execute`, `fn::sanitize_object_execute`, règles
  `required_string`, `string`, `record`, `boolean`, `integer`, `language_code`, `trim`,
  `uppercase`…
* Aucune extension du Core.

### Appelants à mettre à jour dans le même changement

* `lyxal_catalogue` : `REFERENCE ON DELETE REJECT` sur les 4 champs (lot 3).
* Lectures directes de `base_unite` remplacées par `fn::base_unite_get` (B-11, lot 3) :
  `fn::catalogue_item_create`, `_update`, `fn::catalogue_attribut_create`,
  `fn::catalogue_composition_add_line` (unité refusée si `usable` est faux : le type parent
  inactif est désormais pris en compte) ; `fn::ingestion_resolve_unit` (code inconnu →
  `INGESTION_UNIT_UNRESOLVED`, comme aujourd'hui). Tests de non-régression ajoutés dans les
  deux modules : aucune fonction hors `lyxal_base` ne lit `base_unite` ni `base_unite_type`.
* `lyxal_pipeline_ingestion/tests/it/integration_phase4_alignment.rs` : unité `LTR` remplacée
  par une création via `fn::base_unite_create`, résultat vérifié (B-09).

## 3. Tests

Banc SurrealQL (`tests/*.test.surql`, CI, SurrealDB 3.3.4), chaque fonction appelée :

* types et unités : création, lecture par identifiant et par code, liste (filtres, pagination,
  « nouveaux documents »), mise à jour, suppression ;
* hiérarchie : pas d'unité active sur un type inactif (création, mise à jour, réactivation) ;
* socle système : suppression refusée, désactivation possible ;
* références : unité utilisée par un enregistrement d'une table de test → `BASE_UNITE_IN_USE` ;
  suppression directe refusée par la base ;
* identifiant d'une autre table refusé (B-01) ; entrées invalides →
  `BASE_INVALID_PARAMETERS` ;
* écritures sous une identité non autorisée → `BASE_WRITE_FORBIDDEN`, rien d'écrit ;
* chaque code émis est défini ; installation rejouée sans doublon.

## 4. Lots

| Lot | Contenu |
| :- | :--- |
| 1 | **Entrées et écritures** (B-01, B-02, B-04, B-06, B-07) : 10 fonctions sur le moteur du Core, identifiants contrôlés par table, écritures vérifiées, erreurs dans `error/<thème>/`, libellés selon Q2 ; premiers tests du banc (paramètres, permissions). |
| 2 | **Référentiel** (B-08, Q3, B-09) : types et unités ajoutés aux seeds, dont `MM` (millimètre, produit par la normalisation de l'ingestion mais absent de sa liste `CANONICAL_UNITS`, complétée) ; `GR` → `G`, `L` → `LTR` ; test de l'ingestion : chaque code canonique existe dans `base_unite`, plus d'écriture directe dans `base_unite`. |
| 3 | **Intégrité et frontières** (B-03, Q1, B-11) : références entrantes, `REFERENCE ON DELETE REJECT` dans `lyxal_base` et le catalogue ; lectures directes du catalogue et de l'ingestion remplacées par `fn::base_unite_get`. |
| 4 | **Tests** (B-05) : banc complet. |
| 5 | **Clôture** (B-10) : `README.md` à l'état actuel (dont le format des identifiants), `ROADMAP.md`, suppression de `AUDIT.md` et de ce plan ; `docs/01-architecture/AUDIT_SURREALDB_RELATION_TABLES.md` et `AGENTS.md` alignés. |

Chaque lot fait l'objet d'une PR, fusionnée quand la CI est verte.
