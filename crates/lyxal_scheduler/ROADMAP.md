# Feuille de route — `lyxal_scheduler`

Évolutions à venir. L'état actuel est décrit par le [`README.md`](README.md) ; le programme et
ses décisions (S1 à S8) par le plan racine [`implementation_plan.md`](../../implementation_plan.md),
les modèles par [`RECHERCHE_SOURCES.md`](RECHERCHE_SOURCES.md). Chaque lot a son propre plan
détaillé, validé par le CTO avant toute ligne de code (`.agents/AGENTS.md` §3).

## Lots de la V1

| Lot | Contenu | Touche |
| :- | :--- | :--- |
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
