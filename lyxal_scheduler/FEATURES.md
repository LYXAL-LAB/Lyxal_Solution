# 🚀 Features & Architecture Multi-Tenant — Lyxal Scheduler

Ce document présente l'ensemble des fonctionnalités de **Lyxal Scheduler** ainsi que le fonctionnement détaillé de la gestion **Multi-Tenant**.

---

## 🏢 1. Architecture Multi-Tenant

Le multi-tenancy dans Lyxal Scheduler est conçu pour répondre aux exigences les plus strictes d'isolation et de sécurité. Deux approches sont prises en charge :

### A. Isolation Native par Namespace SurrealDB (Recommandée & Par Défaut)
SurrealDB gère la séparation multi-tenant de façon native via la hiérarchie **`NAMESPACE` / `DATABASE`** :
- **Principe** : Chaque client ou organisation dispose de son propre Namespace (ex: `tenant_client_a`, `tenant_client_b`).
- **Isolation Totale** : Les données, les clés API, les accès (`DEFINE ACCESS`), les fonctions et les exécutions de tâches sont physiquement et logiquement étanches au niveau du moteur SurrealDB.
- **Sécurité** : 0% de risque de fuite de données inter-tenants (*Cross-Tenant Data Leak*).

### B. Isolation par Colonne Discriminante (`tenant_id`)
Pour un modèle SaaS partagé au sein d'une seule et même base de données :
- **Principe** : Ajout d'un champ `tenant_id` sur les tables (`scheduler_job_definition`, `scheduler_trigger`, etc.).
- **Filtrage** : Les requêtes et endpoints SurrealQL (`DEFINE API`) filtrent les données via la clause `WHERE tenant_id = $tenant`.

---

## ⚡ 2. Fonctionnalités Principales

### 📅 Planification & Déclencheurs (Triggers)
- **Expressions CRON** : Prise en charge complète des syntaxes Cron standard.
- **Intervalles Fixes & Tâches Différées** : Planification à une date/heure précise (`not_before` / `not_after`).
- **Gestion des Timezones** : Prise en charge native des fuseaux horaires (UTC et fuseaux régionaux).
- **Abri de Calendrier d'Exceptions** : Suspension automatique des tâches lors des jours fériés ou périodes d'arrêt via `scheduler_calendar` sans modifier la règle Cron.

### 🛡️ Résilience & Tolérance aux Pannes
- **Gestion des Retries** : Tentatives de rejeu configurables avec backoff (`max_retries`).
- **Timeouts d'Exécution** : Interruption des tâches bloquées ou en dépassement de délai (`timeout`).
- **Dead-Letter Queue (DLQ)** : Isolation automatique des tâches échouées pour analyse post-mortem et rejeu manuel.

### 🔄 Moteur d'Exécution & Workers
- **Distributed Lease Locking** : Verrouillage distribué garantissant l'exécution unique d'une tâche (*Exactly-Once / At-Most-Once*).
- **Heartbeat & Statut des Runners** : Suivi de présence et de santé des travailleurs distants.
- **Streaming Temps Réel (`LIVE SELECT`)** : Réactivité immédiate du moteur Rust sans polling lourd.

### 🔐 Sécurité & Droits d'Accès
- **SurrealDB Native `DEFINE ACCESS`** : Authentification des administrateurs (Argon2) et des clés API (SHA-256).
- **Tokens Bearer Workers** : Vérification automatique des autorisations des travailleurs distants.
- **Traçabilité & Audit Log** : Journalisation d'audit de sécurité et historique d'exécution complet (`scheduler_audit_log`, `scheduler_execution_log`).

### 🤖 Compatibilité IA & Agentic
- **Model Context Protocol (MCP)** : Support natif du protocole MCP pour permettre aux agents IA d'interagir directement avec le Scheduler.
