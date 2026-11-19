# Feuille de route — `lyxal_runtime`

Évolutions prévues du moteur d'exécution. L'état actuel (manifeste, installation rejouable,
migrations sous bail, reprise guidée d'une migration interrompue, cycle de vie, workers
supervisés, santé, présence des nœuds, réconciliation) et ses limites sont décrits dans le [`README.md`](README.md)
(§7). Aucune étape ne démarre sans ordre du CTO et
`implementation_plan.md` validé (`.agents/AGENTS.md` §3).

| Étape | Thème | Dépendances |
| :--- | :--- | :--- |
| 1 | Retrait d'un module et de ses données | — |
| 2 | Coordination du cycle de vie entre nœuds | — |
| 3 | Plusieurs hôtes : suites | `apps/lyxal-groupware` |

---

## 1. Retrait d'un module et de ses données

La cible `Absent` arrête un module sans supprimer ses données. La désinstallation complète n'existe
pas.

Critères d'acceptation :

- [ ] retrait explicite, distinct de l'arrêt, refusé si un module installé en dépend ;
- [ ] suppression des ressources déclarées par le manifeste (tables, fonctions, événements,
      définitions d'erreurs) et de la release ;
- [ ] tests : retrait, refus pour dépendance, rejeu sans erreur.

## 2. Coordination du cycle de vie entre nœuds

La santé, le démarrage et l'arrêt sont locaux au nœud ; seuls l'installation, les migrations et
le socle sont coordonnés par baux. La présence des nœuds (`runtime_node` : hôte, modules, dernier
battement) est déjà publiée en base.

Critères d'acceptation :

- [ ] état de santé et de démarrage de chaque nœud agrégé par module (à partir de
      `runtime_node`, `runtime_health` et `runtime_worker`) ;
- [ ] arrêt ou redémarrage d'un module demandé pour tous les nœuds ;
- [ ] tests à deux nœuds (perte d'un nœud, reprise).

## 3. Plusieurs hôtes : suites

Plusieurs hôtes partagent déjà une base (identité d'hôte, présence, hook `install` unique,
chef des événements par hôte, réservation stricte des tâches `handler`). Points laissés hors du
correctif par le CTO (décision H9), à reprendre chacun par son propre plan :

- [ ] deux modules d'un **même** hôte qui écoutent le même type d'événement (un handler par type
      et par processus) : à lever avant le premier cas dans `lyxal-groupware`
      (`crates/lyxal_event/ROADMAP.md`) ;
- [ ] filtre `instance_id` du moteur d'événements : il ne sert pas à séparer les hôtes, son rôle
      reste à décider (`crates/lyxal_event/ROADMAP.md`) ;
- [ ] files du planificateur réservées à un hôte (`crates/lyxal_scheduler/ROADMAP.md`) ;
- [ ] exécuteur du planificateur créé à chaud pour une file apparue après le démarrage
      (`crates/lyxal_scheduler/ROADMAP.md`) ;
- [ ] création de `apps/lyxal-groupware` (lot 3 du programme courrier, agendas et contacts,
      `implementation_plan.md` à la racine).
