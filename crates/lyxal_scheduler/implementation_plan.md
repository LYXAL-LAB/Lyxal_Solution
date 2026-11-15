# Plan d'implémentation — `lyxal_scheduler`, lot 5 : clôture

Dernier lot du programme `lyxal_scheduler` (`implementation_plan.md` à la racine). Il corrige les
écarts de l'audit de clôture (skill `lyxal-audit`, lecture seule, essais contre un serveur
SurrealDB 3.3.4) et termine la documentation. Aucune ligne de code avant la validation du CTO
(`.agents/AGENTS.md` §3).

## 1. Résultat de l'audit

Verdict : **non conforme** — 2 écarts P0, 5 P1, 7 P2. Contrôles passés sans écart : manifeste,
SurrealQL (validation 3.3.4, codes d'erreur, seeds), concordance des 42 couples `XxxParams` ↔
`$params`, Rust (aucune tâche libre, aucun `unwrap`, `panic!` ni `raw_query`, jeton de bail
masqué), isolation entre organisations, bail d'exécution, publication différée atomique,
décalage aléatoire, élagage, compteurs de places ; banc 214 assertions et 71 tests Rust verts.

| N° | Gravité | Écart | Correction |
| :- | :- | :--- | :--- |
| **A1** | P0 | Une personne qui n'a que `scheduler.run.manage` peut **créer elle-même** une exécution `origin: retry` d'une tâche protégée, avec ses propres arguments, en écrivant directement dans `scheduler_run` : le système l'exécute | Champ `retry_of` obligatoire pour une relance ; la garde de création vérifie que l'exécution d'origine existe, est `dead` ou `cancelled`, et porte la même tâche, les mêmes arguments et la même organisation ; permission de la tâche exigée (Y1) |
| **A2** | P0 | Création directe d'un rejeu de période (`scheduler_backfill`) sans la permission propre de la tâche : le moteur crée ensuite les exécutions | La garde et les permissions de la table exigent la permission de la tâche de la planification |
| **A3** | P1 | Reprise d'une planification et relance d'une exécution sans la permission propre de la tâche (contraire à T2) | Permission de la tâche exigée pour la reprise et la relance ; la pause, l'annulation et la suppression restent possibles sans elle (Y1) |
| **A4** | P1 | Le rejeu et les échéances ne respectent pas la limite d'exécutions en attente ; une règle cron à la seconde écrite directement en SurrealQL n'est pas refusée par le moteur (U1 contrôlé seulement à l'écriture par Rust) | Limite `max_pending_runs` appliquée par `schedule_fire` et `backfill_fire` (dates au-delà ignorées et comptées) ; le moteur contrôle U1 à chaque calcul et passe la planification à `invalid` ; README corrigé |
| **A5** | P1 | Les fonctions du moteur ne vérifient pas le bail `leader` : un nœud qui l'a perdu au milieu d'un tour peut encore écrire (les doublons restent impossibles) | Garde de génération : les fonctions du moteur reçoivent `{ node, generation }` et refusent (`SCHEDULER_LEADER_FENCED`) si le bail courant n'est plus le leur, comme `lyxal_event` ; bail relu entre deux lots d'un rejeu (Y2) |
| **A6** | P1 | Le contrôle « cible du même module » repose sur un préfixe de nom : `lyxal_pipeline` pourrait viser `pipeline_ingestion_*`, un module inexistant `lyxal_utils` les fonctions `utils_*` du Core | La déclaration exige que le module soit installé (release du runtime) et que la cible commence par le nom complet du module suivi d'un séparateur, en refusant tout nom qui est aussi le préfixe d'un autre module installé (Y3) |
| **A7** | P1 | Annulation possible par écriture directe avec le seul droit d'écriture des planifications, alors que la fonction exige `scheduler.run.manage` | La garde réserve `cancelled` et `cancel_requested` à `scheduler.run.manage` |
| A8 | P2 | `type::record` ignore ce qui suit un espace : la forme texte d'une exécution n'est pas strictement unique (aucune injection) | `fn::scheduler_run_ref` refuse si l'identifiant relu ne redonne pas exactement la chaîne reçue ; limite de la règle `surql_record_string` signalée au Core (Y4) |
| A9 | P2 | `POST /runs` rend 201 pour une exécution déjà existante | 200 quand `duplicate` est vrai |
| A10 | P2 | `no-store` absent des 404 sur une adresse inconnue du planificateur | Couche posée aussi sur la réponse de repli |
| A11 | P2 | La sonde signale « handler manquant » sur un nœud quand un autre nœud l'a | Signalé seulement si aucun nœud actif ne l'a inscrit (registre des handlers par nœud tenu par l'exécuteur) ; sinon simple information |
| A12 | P2 | Noms de fonctions gardés en mémoire (`Box::leak`, 4 096 au plus) faute d'un `call_fn` à nom dynamique | Selon Y5 |
| A13 | P2 | Réglages d'installation lisibles sans permission ; commentaires citant des gardes inexistantes ; une planification `invalid` peut être remise `active` sans règles corrigées | Lecture des réglages réservée au droit de lecture ; commentaires corrigés ; `invalid → active` seulement avec de nouvelles règles |
| A14 | P2 | `RECHERCHE_SOURCES.md` décrit encore l'ancien dossier supprimé | Remplacé par `MODELE_SOURCES.md` (§3) |

## 2. Décisions soumises au CTO

| N° | Question | Proposition |
| :- | :--- | :--- |
| **Y1** | Permission propre d'une tâche | Exigée pour **tout ce qui fait exécuter** la tâche : création, modification, reprise, déclenchement, rejeu, exécution différée et relance. Pas pour ce qui l'arrête : pause, annulation, suppression. |
| **Y2** | Garde du bail du planificateur | Ajoutée (A5), sur le modèle de `lyxal_event` : nouveau code `SCHEDULER_LEADER_FENCED`. |
| **Y3** | Cible d'une tâche | Le module déclarant doit être installé ; un nom de module qui est le début d'un autre nom de module installé ne peut pas viser les fonctions de cet autre module. |
| **Y4** | Règle `surql_record_string` du Core | Signaler au CTO qu'elle accepte une chaîne suivie d'un espace et de texte ; correction dans le Core **hors de ce programme**, sur décision du CTO. Le module se protège lui-même (A8). |
| **Y5** | `call_fn` à nom dynamique | Élargir `LyxalSurrealCall::call_fn` de `&'static str` à `&str` dans `lyxal_surreal` (rupture coordonnée sans effet sur les appelants, qui passent tous des noms fixes) et supprimer le contournement du moteur. Sinon, garder le contournement borné. |

## 3. Documentation

* `MODELE_SOURCES.md` remplace `RECHERCHE_SOURCES.md` : modèles retenus et licences, règle de
  changement d'heure, choix `croner` / `jiff`, moyens contre la double exécution, sources,
  décisions du CTO S1 à S8, T1 à T5, U1 à U5, W1 à W5, X1 à X4, Y1 à Y5 ; l'étude de l'ancien
  dossier est retirée (historique).
* `README.md` : état final (droits Y1, garde du bail, limites) ; section **Exploitation** :
  réglages (`LYXAL__SCHEDULER__WORKERS`), surveillance (sonde, événements `scheduler.run.dead`),
  file en pause, reprise après panne, rejeu d'une période, conservation de l'historique.
* `ROADMAP.md` : programme V1 retiré ; après V1 (débounce, throttle, DAG, déclencheurs sur
  événement, `terminate_other`, RRULE, tableau de bord Surrealist, bascule des workers des autres
  modules, délais de `lyxal_notification`).
* `.agents/AGENTS.md` §6, `docs/14-roadmap/ROADMAP_NOYAU.md` (`lyxal_scheduler` livré ; prochain
  crate selon la feuille de route), plan racine supprimé.

## 4. Tests

* Banc SurrealQL : un essai par écart (A1, A2, A3, A4, A6, A7, A8, A13), écrit d'abord en échec,
  repris des sondes de l'audit.
* Rust : garde du bail (deux planificateurs, bail perdu entre deux lots d'un rejeu), U1 refusé par
  le moteur, limite d'attente, sonde (A11), et selon Y5 l'exécuteur `function` sans contournement.
* Hôte : 200 pour un doublon, `no-store` sur un 404.
* Contrôle complet : `scripts/ci/ci_local.sh`.

## 5. Checklist (§13)

* Droits : chaque chemin qui fait exécuter une tâche exige sa permission, y compris par écriture
  directe dans les tables.
* Moteur : aucune écriture d'un nœud qui a perdu le bail.
* Zéro dette : plans exécutés et étude historique supprimés ; rupture coordonnée des fonctions du
  moteur (`{ node, generation }`) répercutée sur tous les appelants.
