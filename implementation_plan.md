# Plan d'implémentation — ordre stable des listes

Inventaire du 18 novembre 2026 (lecture seule) : 93 listes relues. Aucune ne perd de ligne (les
trois paginations par curseur comparent une clé unique). Mais **15 listes paginées** (`limit` +
`start`) et **8 listes tronquées** (`limit` seul) trient sur une clé qui n'est pas unique (une
date, un libellé, une priorité) : deux lignes de même valeur peuvent changer de page d'un appel à
l'autre, ou une ligne peut apparaître deux fois et une autre manquer dans un parcours page par
page. Ce plan donne à chacune un ordre total. Aucune ligne de code avant la validation du CTO
(`.agents/AGENTS.md` §3).

## 1. Décisions du CTO

À valider par le CTO.

| N° | Question | Proposition |
| :- | :--- | :--- |
| **V1** | Listes paginées (15) | Le tri de chaque liste se termine par une **clé unique**, dans le même sens que le tri principal : l'identifiant de la ligne, ou la clé métier unique quand elle existe et se lit mieux (code d'un article, lot puis numéro de ligne d'une ligne importée). Listes : `fn::scheduler_run_list`, `fn::ingestion_staged_list`, `fn::ingestion_quarantine_list`, `fn::ingestion_manifest_list`, `fn::error_mapping_list`, `fn::error_occurrence_list`, `fn::catalogue_item_list`, `fn::notification_run_list`, `fn::notification_suppression_list`, `fn::secrets_share_list`, `fn::secrets_request_list`, `fn::secrets_grant_list`, `fn::auth_identity_list`, `fn::auth_organization_member_list`, `fn::storage_object_list` (état `deleted`). Le contenu renvoyé ne change pas : seul l'ordre entre lignes à égalité devient fixe. |
| **V2** | Listes tronquées (8) | Même règle : `fn::event_dead_letter_list`, `fn::runtime_event_list` (nœud puis séquence), `fn::secrets_rotation_get`, `fn::scheduler_schedule_view` (dernières exécutions), `fn::scheduler_calendar_get` (planifications), `fn::auth_session_list`, `fn::auth_application_list`, `fn::notification_category_delete` (détail d'erreur, déjà trié par clé : vérifié). |
| **V3** | Liste des articles du catalogue | Elle trie sur le libellé du référentiel alors qu'elle affiche le **libellé personnalisé** de l'organisation : l'ordre affiché peut sembler faux. **Proposition** : trier sur le libellé affiché (personnalisé s'il existe, sinon celui du référentiel), puis sur le code de l'article. |
| **V4** | Traitements par paquets des workers (37) | **Non modifiés** : files, purges et relances traitent toutes les lignes sélectionnées ; l'ordre « les plus anciens d'abord » y est une préférence, pas un résultat montré à quelqu'un. |
| **V5** | Règle pour la suite | Ajout au skill `lyxal-surrealdb` (et au contrôle 3 du skill `lyxal-audit`, en P1) : toute liste renvoyée à un appelant avec `LIMIT` trie sur une clé totale. Chaque liste corrigée reçoit un test avec deux lignes à égalité, lues sur deux pages. |

Aucun contrat public ne change (paramètres, champs renvoyés, codes d'erreur) ; aucun
`XxxParams` Rust touché ; aucune fonction du Core ajoutée. Un index n'est ajouté que si le tri
complété ne peut plus utiliser l'index existant sur une table qui peut devenir grande
(`error_occurrence`, `scheduler_run`, `notification_run`) : chaque ajout est listé dans la
demande de fusion.

## 2. Travaux

Une seule demande de fusion ; modules touchés : `lyxal_scheduler`, `lyxal_pipeline_ingestion`,
`lyxal_error`, `lyxal_catalogue`, `lyxal_notification`, `lyxal_secrets`, `lyxal_auth`,
`lyxal_storage`, `lyxal_event`, `lyxal_runtime`, et les deux skills.

## 3. Tests

* Par liste corrigée : deux lignes à égalité sur la clé de tri principale, lues page par page
  (`limit: 1`), sans doublon ni manque, même ordre à chaque appel.
* `fn::catalogue_item_list` : ordre sur le libellé personnalisé (V3).
* Bancs existants inchangés dans leurs attentes ; `scripts/ci/ci_local.sh` complet avant la
  demande de fusion.

## 4. Checklist (§13)

* SurrealQL : `surreal validate` 3.3.4 ; `COMMENT` des fonctions mis à jour (ordre décrit).
* Zéro dette : aucun alias ; READMEs à jour là où l'ordre d'une liste est décrit ; ce plan
  supprimé une fois exécuté.
* Aucun besoin Core ni cryptographique.
