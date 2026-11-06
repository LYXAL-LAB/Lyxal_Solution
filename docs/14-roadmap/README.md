# 🗺️ Feuilles de Route (Roadmaps) — Lyxal OS

Ce dossier regroupe les feuilles de route stratégiques et d'intégration transversales de la plateforme Lyxal OS.

## 📌 Documents Disponibles

1. **Intégration Transversale UI** :
   - [`ROADMAP_LYXAL_SPACE.md`](./ROADMAP_LYXAL_SPACE.md) — Intégration de `lyxal_catalogue` et `lyxal_pipeline_ingestion` dans la console unifiée LYXAL SPACE (Étapes A, B, C, D).

2. **Feuilles de Route des Modules** :
   - [`crates/lyxal_error/ROADMAP.md`](../../crates/lyxal_error/ROADMAP.md) — Observabilité, console, événements et fonctions à venir du moteur d'erreurs.
   - [`crates/lyxal_event/ROADMAP.md`](../../crates/lyxal_event/ROADMAP.md) — Métriques, exploitation de la dead letter, réglage automatique du moteur d'événements.
   - [`crates/lyxal_base/ROADMAP.md`](../../crates/lyxal_base/ROADMAP.md) — Conversions et libellés traduits des unités.
   - [`crates/lyxal_catalogue/ROADMAP.md`](../../crates/lyxal_catalogue/ROADMAP.md) — Substitutions, recherche avancée, historisation, catalogue intelligent.
   - [`crates/lyxal_pipeline_ingestion/ROADMAP.md`](../../crates/lyxal_pipeline_ingestion/ROADMAP.md) — Évolutions prévues du pipeline d'ingestion.

3. **Audits d'Architecture & Décisions Structurantes** :
   - [`docs/01-architecture/AUDIT_SURREALDB_RELATION_TABLES.md`](../01-architecture/AUDIT_SURREALDB_RELATION_TABLES.md) — Audit exhaustif des tables relationnelles SurrealDB (`TYPE NORMAL` vs `TYPE RELATION`).
