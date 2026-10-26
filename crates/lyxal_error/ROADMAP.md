# 🗺️ Feuille de Route Officielle — Module `lyxal_error`

Ce document définit la roadmap officielle en 3 phases du module **`lyxal_error`**, ainsi que l'application de la **Méthodologie Standard Lyxal OS** (Fonctionnel ➔ Observabilité & UI ➔ Événementiel & IA).

---

## 🏗️ La Méthodologie Standard Lyxal OS en 3 Phases

Chaque module de la suite Lyxal OS (`lyxal_booking`, `lyxal_error`, `lyxal_notification`, `lyxal_scheduler`) évolue selon 3 phases universelles :

```text
┌───────────────────────────┐      ┌───────────────────────────┐      ┌───────────────────────────┐
│     V1 — FONCTIONNEL      │ ───► │     V2 — OBSERVABILITÉ    │ ───► │    V3 — ÉVÉNEMENTIEL &    │
│  Tables + CRUD + Moteur   │      │  Stats + Dashboard + UI   │      │  Bus lyxal_event + IA     │
└───────────────────────────┘      └───────────────────────────┘      └───────────────────────────┘
```

---

## 🟢 PHASE V1 — Moteur Fonctionnel (TERMINÉE ✅)

**Objectif** : Gérer la définition, la résolution, la traduction et la journalisation des erreurs de manière universelle et fortement typée.

### 1.1. Modèle de Données & Tables SurrealDB
- ✅ `error_definition` : Catalogue canonique des codes d'erreurs master data.
- ✅ `error_occurrence` : Journal technique *append-only* d'occurrences.
- ✅ `error_external_mapping` : Règles de correspondance d'erreurs externes (Google, CalDAV, SMTP, Stripe).

### 1.2. Moteur & Services SurrealQL
- ✅ `fn::result_ok($data)` : Enveloppe de succès universelle (`{ ok: true, data: ..., error: null }`).
- ✅ `fn::error_result($code, $lang, $details)` : Enveloppe d'échec universelle (`{ ok: false, data: null, error: ... }`).
- ✅ `fn::error_resolve($code, $lang, $details)` : Moteur de résolution & traduction avec repli linguistique (`default_language`).
- ✅ `fn::error_log(...)` : Ingestion immuable d'occurrences réelles.
- ✅ `fn::error_map_external(...)` : Traducteur de codes fournisseurs externes (`exact`, `prefix`, `contains`, `http_status`).

### 1.3. Intégration Rust (`lyxal_error`)
- ✅ Crate Rust typé : `LyxalResult<T>`, `LyxalError`, `LyxalCallError`.
- ✅ Convertisseur automatique Axum `IntoResponse` (HTTP `400`, `409`, `422`, `500`).

---

## 🟡 PHASE V2 — Observabilité & Console Graphique UI 📊 (En cours / Prochaine étape)

**Objectif** : Fournir une visibilité complète sur le comportement des erreurs via des statistiques en temps réel et une interface utilisateur dédiée (UI Web Console).

### 2.1. Nouvelle Table d'Agrégation : `error_statistics`
Maintenue automatiquement pour éviter les requêtes coûteuses `SELECT count()` sur des millions de lignes d'occurrences.

```surrealql
DEFINE TABLE IF NOT EXISTS error_statistics TYPE NORMAL SCHEMAFULL;
```

**Champs principaux** :
- `code` : Code d'erreur canonique
- `module` : Module source (`booking`, `auth`, `notification`)
- `total_count` : Compteur global d'occurrences
- `today_count` / `week_count` / `month_count` : Compteurs temporels
- `first_seen` / `last_seen` : Horodatages d'apparition
- `last_actor` / `last_source` : Dernières entités concernées

### 2.2. Nouvelles Fonctions SurrealQL d'Observabilité
- `fn::error_statistics_get($code)` : Extraction des métriques pour un code d'erreur.
- `fn::error_statistics_list($module, $timeframe)` : Classement et métriques agrégées.
- `fn::error_statistics_reset($code)` : Réinitialisation des compteurs d'observabilité.

### 2.3. Interface Graphique UI Web Console (`lyxal_error_ui`) 🎨
Console d'administration et de supervision pour les équipes support et administrateurs système :
- **Tableau de bord Synthétique** :
  - Graphiques de tendances d'erreurs par heure/jour/semaine.
  - Classement **Top 10 des erreurs** les plus récurrentes.
  - Répartition par module (`booking`, `auth`, `notification`, `scheduler`).
  - Taux d'erreurs par statut HTTP (`4xx` vs `5xx`).
- **Explorateur d'Occurrences (Live Stream)** :
  - Inspection en temps réel des erreurs survenues avec filtres par `trace_id`, `module`, `severity`.
  - Visualisation détaillée du `context` JSON nettoyé.
- **Gestionnaire du Catalogue Canonique & Traducteur** :
  - Interface d'édition WYSIWYG pour ajouter/modifier les traductions `fr`/`en` et la résolution suggérée sans toucher au code.
- **Éditeur de Mappings Externe** :
  - Configuration visuelle des règles de conversion pour Google OAuth, CalDAV, Stripe, SMTP.

---

## 🔵 PHASE V3 — Événementiel, Automates & IA ⚡

**Objectif** : Intégrer totalement `lyxal_error` dans l'écosystème réactif Lyxal OS (avec `lyxal_event`, `lyxal_notification`, `lyxal_scheduler`).

### 3.1. Pub/Sub d'Événements SurrealDB (`DEFINE EVENT`)
Alimentation automatique de la file d'attente d'événements :
```surrealql
DEFINE EVENT error_occurrence_created ON TABLE error_occurrence
WHEN $event = "CREATE"
THEN {
    -- 1. Mise à jour de la table d'agrégation d'observabilité (UPSERT error_statistics)
    -- 2. Publication vers l'outbox d'événements si sévérité = "critical"
    IF $after.severity == "critical" {
        CREATE event_outbox CONTENT {
            module: "error",
            event: "error.critical",
            payload: $after
        };
    };
};
```

### 3.2. Événements Canoniques Publiés
- `error.occurred` : Nouvelle occurrence enregistrée.
- `error.critical` : Erreur critique nécessitant une alerte immédiate.
- `error.definition.created` / `updated` / `disabled` : Modifications du catalogue.

### 3.3. Automations Inter-Modules & Analyse par IA
- **Seuil d'Alerte Automatique** : Déclenchement d'une alerte si `AUTH_LOGIN_FAILED` survient >100 fois en 2 minutes via `lyxal_notification`.
- **Analyse Diagnostique par IA** : Recommandation automatique de correctifs et détection d'anomalies de régression applicative.

---

## 📋 Tableau Synthétique de la Roadmap

| Phase | Nom | Modules & Tables | Fonctionnalités Clés | Interface Graphique UI |
| :---: | :--- | :--- | :--- | :--- |
| **V1** | **Moteur Canonique** | `error_definition`<br>`error_occurrence`<br>`error_external_mapping` | • Ingestion *append-only*<br>• Résolution & Traduction<br>• Mapping externe<br>• Crate Rust `LyxalResult<T>` | API / CLI Admin |
| **V2** | **Observabilité** | `error_statistics`<br>*(Nouvelle table)* | • Compteurs temps réel<br>• Top 10 des erreurs<br>• Métriques par module/heure | **Web Console UI**<br>*(Dashboard, Live Stream, Éditeur Traduction)* |
| **V3** | **Événementiel & IA** | `event_outbox`<br>*(Bus `lyxal_event`)* | • `DEFINE EVENT` SurrealDB<br>• Alerting automatique<br>• Orchestration `lyxal_notification`<br>• Diagnostic par IA | Monitoring Événementiel & Vues IA |


# Lyxal Error
## Roadmap — Fonctions SurrealQL restantes

> Version cible : 1.1
> Statut : Roadmap
> Objectif : compléter le module Lyxal Error sans remettre en cause l'architecture actuelle.

---

# État actuel

Le module possède déjà :

## Définitions

- error_definition
- error_external_mapping
- error_occurrence

## CRUD

### Error Definition

- error_definition_create
- error_definition_get
- error_definition_update
- error_definition_disable
- error_definition_list

### External Mapping

- error_mapping_create
- error_mapping_get
- error_mapping_update
- error_mapping_disable
- error_mapping_list

### Occurrences

- error_occurrence_create
- error_occurrence_get
- error_occurrence_list
- error_occurrence_purge_before

## Runtime

- error_get
- error_resolve
- error_log
- error_result
- result_ok
- error_map_external

---

# Roadmap restante

---

# LOT 1 — Recherche

Permettre la recherche rapide dans le catalogue.

- error_search
- error_search_code
- error_search_label
- error_search_category
- error_search_module
- error_search_severity
- error_search_http_status
- error_search_retryable
- error_search_keyword
- error_search_documentation

---

# LOT 2 — Statistiques

Analyse des erreurs produites.

- error_stats
- error_count
- error_top
- error_frequency
- error_trend
- error_by_module
- error_by_category
- error_by_severity
- error_by_http_status
- error_dashboard

---

# LOT 3 — Analytics

Vision historique.

- error_daily
- error_weekly
- error_monthly
- error_yearly
- error_timeline
- error_heatmap
- error_first_seen
- error_last_seen
- error_growth
- error_regression

---

# LOT 4 — Documentation

Exploitation du catalogue.

- error_documentation
- error_reference
- error_examples
- error_export_json
- error_export_markdown
- error_export_csv
- error_export_html
- error_import_json
- error_import_csv
- error_generate_docs

---

# LOT 5 — Validation

Validation interne du catalogue.

- error_validate_definition
- error_validate_mapping
- error_validate_occurrence
- error_validate_http_status
- error_validate_category
- error_validate_severity
- error_validate_retryable
- error_validate_documentation
- error_validate_reference
- error_validate_unique_code

---

# LOT 6 — Administration

Administration du catalogue.

- error_enable
- error_delete
- error_clone
- error_copy
- error_archive
- error_restore
- error_reorder
- error_merge
- error_split
- error_replace

---

# LOT 7 — Maintenance

Nettoyage.

- error_cleanup
- error_cleanup_occurrences
- error_cleanup_duplicates
- error_cleanup_orphans
- error_cleanup_unused
- error_reindex
- error_compact
- error_repair
- error_integrity
- error_health

---

# LOT 8 — Monitoring

Monitoring temps réel.

- error_recent
- error_live
- error_stream
- error_alert
- error_alert_threshold
- error_alert_module
- error_alert_category
- error_alert_severity
- error_alert_frequency
- error_alert_summary

---

# LOT 9 — API

Fonctions de haut niveau.

- error_exists
- error_has_mapping
- error_has_documentation
- error_is_retryable
- error_is_enabled
- error_http_status
- error_category
- error_severity
- error_label
- error_description

---

# LOT 10 — Introspection

Inspection complète.

- error_info
- error_schema
- error_dependencies
- error_usage
- error_consumers
- error_providers
- error_statistics
- error_metadata
- error_contract
- error_debug

---

# Priorité

## Priorité Haute

- Recherche
- Validation
- API

Ces fonctions seront utilisées partout dans Lyxal OS.

---

## Priorité Moyenne

- Statistiques
- Analytics
- Monitoring

Utilisées par le Back Office.

---

## Priorité Basse

- Documentation
- Administration
- Maintenance
- Introspection

Fonctions destinées principalement aux administrateurs.

---

# Estimation

- 10 lots
- 100 nouvelles fonctions
- 100 fichiers de tests

Le module atteindrait alors environ **120 à 130 fonctions SurrealQL**, ce qui en ferait le moteur central de gestion des erreurs de l'ensemble de Lyxal OS.