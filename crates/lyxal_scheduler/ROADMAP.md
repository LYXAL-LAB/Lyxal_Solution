# Feuille de route — `lyxal_scheduler`

Évolutions à venir, après la V1 (programme terminé, lots 1 à 5). L'état actuel est décrit par le
[`README.md`](README.md) ; les modèles, les sources et les décisions du CTO par
[`MODELE_SOURCES.md`](MODELE_SOURCES.md). Chaque évolution a son propre plan, validé par le CTO
avant toute ligne de code (`.agents/AGENTS.md` §3).

## Après la V1

* Débounce, throttle et limite de débit (modèle Inngest).
* Workflows et dépendances entre tâches (DAG) ; lots.
* Déclencheurs sur événement.
* Politique de chevauchement `terminate_other`.
* Règles RRULE.
* Tableau de bord Surrealist sur les `fn::scheduler_*`.
