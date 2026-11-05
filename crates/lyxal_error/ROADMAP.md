# Feuille de route — `lyxal_error`

Évolutions prévues du module. L'état actuel (tables `error_definition`, `error_occurrence`,
`error_external_mapping`, fonctions de service et CRUD, crate Rust) est décrit dans le
[`README.md`](README.md). Chaque étape fait l'objet d'un `implementation_plan.md` validé par le
CTO avant tout développement (`.agents/AGENTS.md` §3) et suit la méthode en 3 phases (§9).

---

## Phase V2 — Observabilité et console

Objectif : rendre visible le comportement des erreurs par des statistiques à jour et une console
dédiée.

### Table d'agrégation `error_statistics`

Maintenue au fil des occurrences, pour éviter de compter des millions de lignes
d'`error_occurrence` :

* `code`, `module` ;
* `total_count`, `today_count`, `week_count`, `month_count` ;
* `first_seen`, `last_seen`, `last_actor`, `last_source`.

### Fonctions d'observabilité (`$params: object`)

* `fn::error_statistics_get` : métriques d'un code ;
* `fn::error_statistics_list` : classement par module et période ;
* `fn::error_statistics_reset` : remise à zéro des compteurs d'un code.

### Console d'administration (Surrealist, charte §15)

* tableau de bord : tendances par heure, jour, semaine ; dix erreurs les plus fréquentes ;
  répartition par module ; part des statuts `4xx` et `5xx` ;
* explorateur des occurrences en direct, filtré par `trace_id`, `module`, `severity`, avec le
  contexte nettoyé ;
* édition des définitions et de leurs traductions (`fr`, `en`) sans toucher au code ;
* édition des correspondances d'erreurs externes (Google OAuth, CalDAV, Stripe, SMTP).

---

## Phase V3 — Événements, automatismes et IA

Objectif : intégrer `lyxal_error` au bus `lyxal_event` et aux modules `lyxal_notification` et
`lyxal_scheduler`.

* `DEFINE EVENT` sur `error_occurrence` (création) : mise à jour d'`error_statistics` et, pour
  une sévérité `critical`, publication par `fn::event_publish` (résultat vérifié, §5.6.1).
* Événements publiés : `error.occurred`, `error.critical`, `error.definition.created`,
  `error.definition.updated`, `error.definition.disabled`.
* Seuils d'alerte (ex. `AUTH_LOGIN_FAILED` plus de 100 fois en 2 minutes) notifiés par
  `lyxal_notification`.
* Diagnostic assisté par IA : correctifs suggérés, détection de régressions.

---

## Fonctions SurrealQL envisagées, par lot

Toutes en `fn::error_<action>($params: object)`, avec tests au banc. Une fonction qui recouvre
une primitive de `lyxal_core` réutilise le Core (§5.7).

| Priorité | Lot | Fonctions |
| :--- | :--- | :--- |
| Haute | Recherche | `error_search` (code, libellé, catégorie, module, sévérité, statut HTTP, caractère réessayable, mot-clé, documentation) |
| Haute | Validation du catalogue | contrôle d'une définition, d'une correspondance, d'une occurrence, de l'unicité des codes et des références |
| Haute | API de haut niveau | `error_exists`, `error_has_mapping`, `error_is_retryable`, `error_is_enabled`, `error_http_status`, `error_category`, `error_severity`, `error_label` |
| Moyenne | Statistiques | `error_stats`, `error_count`, `error_top`, `error_frequency`, `error_trend`, répartitions par module, catégorie, sévérité, statut HTTP |
| Moyenne | Analyses historiques | séries journalières, hebdomadaires, mensuelles ; chronologie ; première et dernière apparition ; croissance ; régressions |
| Moyenne | Surveillance | erreurs récentes, flux en direct, alertes par seuil, module, catégorie, sévérité, fréquence |
| Basse | Documentation | référence, exemples, exports et imports (JSON, CSV, Markdown, HTML), génération de documentation |
| Basse | Administration | réactivation, clonage, archivage et restauration, fusion et remplacement de définitions |
| Basse | Maintenance | nettoyage des occurrences, des doublons et des orphelins ; contrôle d'intégrité ; santé |
| Basse | Introspection | schéma, dépendances, usages, modules consommateurs et producteurs, métadonnées |
