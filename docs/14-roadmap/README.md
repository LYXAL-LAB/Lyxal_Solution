# 🗺️ Feuilles de Route (Roadmaps) — Lyxal OS

Ce dossier regroupe les feuilles de route stratégiques et d'intégration transversales de la plateforme Lyxal OS.

## 📌 Documents Disponibles

1. **Intégration Transversale UI** :
   - [`ROADMAP_LYXAL_SPACE.md`](./ROADMAP_LYXAL_SPACE.md) — Intégration de `lyxal_catalogue` et `lyxal_pipeline_ingestion` dans la console unifiée LYXAL SPACE (Étapes A, B, C, D).

2. **Feuilles de Route des Modules** :
   - [`ROADMAP_NOYAU.md`](./ROADMAP_NOYAU.md) — Ordre de création des crates du noyau technique à créer (programme courrier, agendas et contacts : `lyxal_mail_proto`, `lyxal_mail`, `lyxal_dav`, `lyxal_calendar`, `lyxal_contacts`, hôte `lyxal-groupware`).
   - [`crates/lyxal_mail_proto/ROADMAP.md`](../../crates/lyxal_mail_proto/ROADMAP.md) — Syntaxes du courrier (à créer) : lots du programme, essais réels.
   - [`crates/lyxal_mail/ROADMAP.md`](../../crates/lyxal_mail/ROADMAP.md) — Serveur de courrier (à créer) : lots du programme, chiffrement des boîtes (niveaux A, B, C), webmail et alias à venir, essais réels.
   - [`crates/lyxal_dav/ROADMAP.md`](../../crates/lyxal_dav/ROADMAP.md) — Socle WebDAV, iCalendar et vCard (à créer) : lots du programme, essais réels.
   - [`crates/lyxal_calendar/ROADMAP.md`](../../crates/lyxal_calendar/ROADMAP.md) — Agendas et CalDAV (à créer) : lots du programme, essais réels.
   - [`crates/lyxal_contacts/ROADMAP.md`](../../crates/lyxal_contacts/ROADMAP.md) — Contacts et CardDAV (à créer) : lots du programme, essais réels.
   - [`crates/lyxal_core/ROADMAP.md`](../../crates/lyxal_core/ROADMAP.md) — Bibliothèque standard SurrealQL (aucune étape prévue).
   - [`crates/lyxal_crypto/ROADMAP.md`](../../crates/lyxal_crypto/ROADMAP.md) — Audit de sécurité externe avant la première mise en production.
   - [`crates/lyxal_surreal/ROADMAP.md`](../../crates/lyxal_surreal/ROADMAP.md) — Transport SurrealDB (aucune étape prévue).
   - [`crates/lyxal_runtime/ROADMAP.md`](../../crates/lyxal_runtime/ROADMAP.md) — Reprise des migrations, retrait d'un module, coordination entre nœuds.
   - [`apps/lyxal-server/ROADMAP.md`](../../apps/lyxal-server/ROADMAP.md) — Authentification des clients, API des modules, hébergement des crates du noyau.
   - [`crates/lyxal_error/ROADMAP.md`](../../crates/lyxal_error/ROADMAP.md) — Observabilité, console, événements et fonctions à venir du moteur d'erreurs.
   - [`crates/lyxal_event/ROADMAP.md`](../../crates/lyxal_event/ROADMAP.md) — Métriques, exploitation de la dead letter, réglage automatique du moteur d'événements.
   - [`crates/lyxal_base/ROADMAP.md`](../../crates/lyxal_base/ROADMAP.md) — Référentiels de base (aucune étape prévue).
   - [`crates/lyxal_catalogue/ROADMAP.md`](../../crates/lyxal_catalogue/ROADMAP.md) — Substitutions, recherche avancée, historisation, catalogue intelligent.
   - [`crates/lyxal_pipeline_ingestion/ROADMAP.md`](../../crates/lyxal_pipeline_ingestion/ROADMAP.md) — Évolutions prévues du pipeline d'ingestion.

3. **Socle Technique** :
   - [`SURREALDB_4.md`](./SURREALDB_4.md) — Passage à SurrealDB 4.0 : reporté, conditions pour le rouvrir, travail restant.

4. **Audits d'Architecture & Décisions Structurantes** :
   - [`docs/01-architecture/AUDIT_SURREALDB_RELATION_TABLES.md`](../01-architecture/AUDIT_SURREALDB_RELATION_TABLES.md) — Audit exhaustif des tables relationnelles SurrealDB (`TYPE NORMAL` vs `TYPE RELATION`).
