# Plan d'implémentation — audit externe, lot 4 (A02)

Quatrième lot de correction de l'audit externe
[`audit_externe/2026-11-07_audit_crates_cto_chatgpt_codex.md`](audit_externe/2026-11-07_audit_crates_cto_chatgpt_codex.md).
Constats vérifiés sur `main` (après #93) en lecture seule. Changement dans `lyxal_catalogue`
(SurrealQL seul) ; aucun appelant hors du module n'utilise les champs concernés (vérifié :
`lyxal_pipeline_ingestion` ne les transmet pas). Plan placé à la racine comme les lots
précédents, supprimé une fois exécuté. Principe déjà validé par le CTO le 7 novembre : table
séparée des personnalisations par couple (locataire, article maître).

**En attente de validation du CTO (Q1 à Q3).**

## 1. Constats

| ID | Constat | Preuve |
| :- | :--- | :--- |
| A02-a | Un `tenant_user` modifie l'**enregistrement partagé** d'un article maître : permission `update` sans condition de locataire (`is_custom = false AND master_id != NONE`). Dans une base commune, la personnalisation d'Alpha (`libelle_personnalise`, `code_interne_client`) est lue par Beta. | `schema/02_catalogue_item.surql:31-45`, `:230-238` ; README §3 |
| A02-b | Même défaut pour la disponibilité : `enabled` d'un article maître est modifiable par un locataire ; Alpha qui désactive un article le désactive pour **tous** les locataires. | `catalogue_item_update.surql:176`, `:236-244` |
| A02-c | Conséquence aggravante : la synchronisation maître ne peut plus jamais réactiver un article qu'un seul locataire a désactivé (`CATALOGUE_ITEM_SYNC_CANNOT_REACTIVATE_DISABLED`), et ne peut pas écrire les champs de personnalisation — un état local d'un locataire bloque le référentiel commun. | `catalogue_item_update.surql:198-212` ; garde `schema/02_catalogue_item.surql:443-454` |
| A02-d | Aucune isolation physique (base par locataire) n'est imposée ni vérifiée par l'hôte : la base partagée est le cas réel. | `apps/lyxal-server` (une base par instance, plusieurs `tenant_id` possibles) |

## 2. Décisions demandées

| # | Question | Options | Recommandation |
| :- | :--- | :--- | :--- |
| Q1 | Champs de personnalisation sur `catalogue_item` | **A.** Ils quittent `catalogue_item` : `libelle_personnalise` et `code_interne_client` n'existent plus que dans la table de personnalisation (article maître) ; un article privé, qui appartient déjà à son locataire, se modifie directement (libellé, code). **B.** Les garder sur `catalogue_item` pour les articles privés et les dupliquer dans la table pour les maîtres. | **A** : un seul endroit par donnée (§5.1) ; sur un article privé, un « libellé personnalisé » à côté du libellé est un doublon. |
| Q2 | Disponibilité d'un article maître | **A.** `enabled` de `catalogue_item` devient **maître seul** (retrait au référentiel, par la synchronisation) ; chaque locataire a sa disponibilité propre dans sa personnalisation (`enabled`). Disponible pour un locataire = maître actif **et** non désactivé par lui. Les règles « la synchronisation ne réactive pas un article désactivé localement » et « ne touche pas aux personnalisations » deviennent sans objet et sont supprimées. **B.** Garder la désactivation locale sur l'enregistrement maître. | **A** : la désactivation d'Alpha ne touche plus Beta, et la synchronisation reste seule maître du référentiel commun. |
| Q3 | Lecture par un locataire | **A.** `fn::catalogue_item_get` et `fn::catalogue_item_list` renvoient, pour un article maître, `personnalisation` (celle du locataire de la session, ou `NONE`) et `disponible` (calculé) ; le filtre `enabled` de la liste porte sur cette disponibilité pour un locataire. **B.** Lecture des personnalisations par une fonction séparée seulement. | **A** : un seul appel pour afficher le catalogue tel que le voit le locataire ; aucune jointure côté interface. |

## 3. Contrat cible (si Q1-A, Q2-A, Q3-A)

### Schéma

* Nouvelle table `catalogue_item_personnalisation` (`schema/13_…`, `TYPE NORMAL SCHEMAFULL`) :
  `item` (`record<catalogue_item>`, `REFERENCE ON DELETE CASCADE`, `READONLY`), `tenant_id`
  (`READONLY`, pris de la session), `libelle_personnalise`, `code_interne_client`, `enabled`
  (défaut `true`), `created_at`, `updated_at` ; index unique (`item`, `tenant_id`).
* Permissions : un `tenant_user` lit, crée, modifie et supprime **ses** personnalisations
  (`tenant_id = $token.tenant_id`), et seulement sur un article maître ; l'agent de
  synchronisation n'y a aucun accès.
* `catalogue_item` : suppression de `libelle_personnalise` et `code_interne_client` ; la branche
  de permission `update` « locataire sur article maître » est retirée (un locataire ne modifie
  plus jamais un article maître) ; garde allégée des règles devenues sans objet.

### Fonctions

* **Nouvelle** `fn::catalogue_item_personnaliser($params)` : `item_id` (article maître),
  `libelle_personnalise`, `code_interne_client`, `enabled` (au moins un) ; crée ou met à jour la
  personnalisation du locataire de la session (`tenant_user` requis). Erreurs :
  `CATALOGUE_PERSONNALISATION_ITEM_NOT_MASTER` (article privé : se modifie directement),
  `CATALOGUE_ITEM_NOT_FOUND`, `CATALOGUE_ITEM_TENANT_REQUIRED`, `CATALOGUE_WRITE_FORBIDDEN`.
* **Nouvelle** `fn::catalogue_item_personnalisation_supprimer($params)` : `item_id` ; revient au
  référentiel (`CATALOGUE_PERSONNALISATION_NOT_FOUND` si aucune).
* `fn::catalogue_item_create` / `fn::catalogue_item_update` : paramètres
  `libelle_personnalise` et `code_interne_client` supprimés (rupture, aucun appelant hors
  tests) ; `enabled` d'un article maître réservé à la synchronisation.
* `fn::catalogue_item_get` / `fn::catalogue_item_list` : `personnalisation` et `disponible`
  (Q3-A).
* Entrées par `fn::validation_object_execute` / `fn::sanitize_object_execute` ; aucune fonction
  Core nouvelle. Nouveaux codes `CATALOGUE_PERSONNALISATION_*` (master data, fr/en) ; codes
  devenus sans objet (`CATALOGUE_ITEM_SYNC_CANNOT_OVERWRITE_LOCAL_CUSTOMIZATION`,
  `CATALOGUE_ITEM_SYNC_CANNOT_REACTIVATE_DISABLED`) supprimés.

### Documentation

* `README.md` (tables, permissions, fonctions, codes) ; jeu de démonstration
  `tests/fixtures/pilote_btp_habitat.surql` mis à jour.

## 4. Tests (banc SurrealQL, deux locataires)

| Cas | Preuve attendue |
| :- | :--- |
| Isolation | Alpha personnalise et désactive un article maître : Beta lit le libellé du référentiel, aucune personnalisation, `disponible = true` ; Alpha lit sa personnalisation et `disponible = false`. |
| Confidentialité | Beta ne lit, ne modifie ni ne supprime la personnalisation d'Alpha (filtrée, rien écrit). |
| Référentiel intact | Un locataire ne modifie plus aucun champ d'un article maître (`CATALOGUE_WRITE_FORBIDDEN`) ; la synchronisation met à jour et réactive l'article maître sans toucher aux personnalisations ; un article retiré par le maître est indisponible pour tous. |
| Article privé | Personnaliser un article privé → `CATALOGUE_PERSONNALISATION_ITEM_NOT_MASTER` ; il se modifie directement par son locataire. |
| Retour au référentiel | Suppression de la personnalisation : Alpha retrouve libellé et disponibilité du référentiel. |
| Liste | Filtre `enabled` d'un locataire = disponibilité effective. |
| Couverture | Chaque fonction publique `fn::catalogue_*` appelée par le banc. |

Contrôle complet : `scripts/ci/ci_local.sh`.

## 5. Checklist (§13)

* SurrealQL : `$params: object` ; écritures vérifiées (`CATALOGUE_WRITE_FORBIDDEN`) ;
  permissions par `tenant_id` de session ; codes préfixés `CATALOGUE_`, master data rejouable.
* Zéro dette : champs et règles devenus sans objet supprimés, aucun alias ; plan supprimé après
  exécution.

## 6. Lots suivants (rappel)

5 : A05 (création de `lyxal_parsing`, puis adaptateurs) · 6 : A07 puis A06.
