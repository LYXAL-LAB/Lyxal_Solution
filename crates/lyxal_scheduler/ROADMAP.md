# Feuille de route — `lyxal_scheduler`

Évolutions à venir. L'état actuel est décrit par le [`README.md`](README.md) ; le programme et
ses décisions (S1 à S8) par le plan racine [`implementation_plan.md`](../../implementation_plan.md),
les modèles par [`RECHERCHE_SOURCES.md`](RECHERCHE_SOURCES.md). Chaque lot a son propre plan
détaillé, validé par le CTO avant toute ligne de code (`.agents/AGENTS.md` §3).

## Lots de la V1

| Lot | Contenu | Touche |
| :- | :--- | :--- |
| **3** | Moteur : bail du planificateur (`runtime_lease.kind = leader`, S4), échéances, rattrapage, chevauchement, rejeu de période, exécuteurs par file avec concurrence et équité, battement, reprise, délai maximal, annulation, tentatives, élagage ; application du décalage aléatoire (U5) à `available_at` ; `TaskHandler`, exécuteurs `function` et `event`, `SchedulerClient`, module, sonde de santé, hébergement par l'hôte | `lyxal_scheduler`, `lyxal_runtime`, `apps/lyxal-server` |
| **4** | Hôte : routes HTTP `/api/v1/scheduler/*` au nom de l'appelant (planifications, calendriers, exécutions, files, prévision, rejeu, déclenchement immédiat) | `apps/lyxal-server` |
| **5** | Clôture : audit `lyxal-audit`, procédures d'exploitation, documents, `RECHERCHE_SOURCES.md` réduit en `MODELE_SOURCES.md` | docs |

## Après la V1

* Débounce, throttle et limite de débit (modèle Inngest).
* Workflows et dépendances entre tâches (DAG) ; lots.
* Déclencheurs sur événement.
* Politique de chevauchement `terminate_other`.
* Règles RRULE.
* Tableau de bord Surrealist sur les `fn::scheduler_*`.
* Bascule des workers périodiques existants (`AuthPurgeWorker`, `NotificationPurgeWorker`,
  `StorageCleanupWorker`, `SecretsMaintenanceWorker`), chacun par son propre plan (S8).
* Délais longs de `lyxal_notification` (son lot V1-c).
