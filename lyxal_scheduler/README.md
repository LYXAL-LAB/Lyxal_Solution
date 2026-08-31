# ⏱️ Lyxal Scheduler — Moteur de Planification Temporelle

> **Statut** : Document de Conception / Initialisation  
> **Inspiration** : Modèle découplé inspiré de [Croniq](https://github.com/nuetzliches/croniq)  
> **Philosophie** : Exécuter des tâches asynchrones et périodiques (Cron) sans jamais bloquer ou surcharger le moteur de transaction de SurrealDB.

---

## 1. Vision et Rôle du Scheduler

Dans l'écosystème Lyxal, le **Lyxal Scheduler** est le chef d'orchestre temporel. Il permet de planifier des requêtes SurrealQL ou des appels réseau externes à intervalles réguliers (tâches récurrentes type Cron) ou à un instant précis (tâches différées).

Pour éviter les ralentissements réseau ou les blocages de transactions dans la base de données principale, le scheduler fonctionne sur une **architecture Sidecar découplée**.

---

## 2. Architecture Inspirée de Croniq

Le Scheduler Lyxal sépare la **définition** de la tâche, son **ordonnancement** (quand l'exécuter) et son **exécution** (comment l'exécuter).

```
┌─────────────────────────────────┐
│      SURREALDB (Standard)       │
├─────────────────────────────────┤
│                                 │
│  • Table: scheduler_jobs        │◄──── (Source de vérité)
│  • Table: scheduler_executions  │
│                                 │
└────────────────┬────────────────┘
                 │
                 │ 1. Le Scheduler surveille la DB
                 ▼
┌─────────────────────────────────┐
│     LYXAL SCHEDULER (Rust)      │ (Le Sidecar)
├─────────────────────────────────┤
│                                 │
│  • Croniq-based Engine          │
│  • State Machine & Timers       │
│                                 │
└────────────────┬────────────────┘
                 │
                 │ 2. Distribue la tâche au Runner
                 ▼
┌─────────────────────────────────┐
│     LYXAL RUNNER (Exécuteur)    │
├─────────────────────────────────┤
│                                 │
│  • Exécute la requête SurrealQL │
│  • Ou appelle Lyxal Bridge API  │
│                                 │
└─────────────────────────────────┘
```

### Les 3 Piliers du Système :

1. **Le Stockage (SurrealDB) :** 
   Toutes les données (schedules, logs d'exécutions) sont stockées dans SurrealQL. Nous adaptons la crate `croniq-store` de Croniq pour en faire une implémentation native pour SurrealDB.
2. **Le Serveur de Planification (Rust) :** 
   Un démon léger en Rust qui utilise le moteur de calcul de calendrier de Croniq (`croniq-scheduler`). Il détermine à la milliseconde près quand une tâche doit se lancer.
3. **Le Runner Lyxal :**
   Un agent d'exécution qui reçoit la tâche du planificateur. Si la tâche consiste à exécuter du SurrealQL ou un flux Lyxal Bridge, c'est le runner qui effectue l'appel réseau ou la requête et écrit le résultat dans SurrealDB.

---

## 3. Schéma des Tables (SurrealQL)

Le scheduler repose sur deux tables principales définies dans SurrealDB :

### A. Table `scheduler_jobs` (Les tâches définies)
```sql
DEFINE TABLE scheduler_jobs SCHEMALESS;

-- Exemple de structure de document dans cette table :
-- {
--     id: scheduler_jobs:backup_database,
--     name: "Sauvegarde de la DB",
--     cron: "0 2 * * *",             -- Tous les jours à 2h du matin
--     next_run: "2026-07-22T02:00:00Z",
--     action_type: "surrealql",      -- ou "bridge_call"
--     action_payload: "INSERT INTO backups ...",
--     status: "active",              -- active, paused
--     retry_policy: {
--         max_attempts: 3,
--         backoff_seconds: 300
--     }
-- }
```

### B. Table `scheduler_executions` (Historique et logs)
```sql
DEFINE TABLE scheduler_executions SCHEMALESS;

-- Exemple de structure de document dans cette table :
-- {
--     id: scheduler_executions:uo9z28f...,
--     job_id: scheduler_jobs:backup_database,
--     started_at: "2026-07-22T02:00:00Z",
--     finished_at: "2026-07-22T02:01:05Z",
--     status: "success",             -- success, failed, running
--     attempt: 1,
--     output: "Backup created successfully.",
--     error: null
-- }
```

---

## 4. Bénéfices pour Lyxal

* **Indépendance vis-à-vis de n8n :** Lyxal gère ses propres tâches récurrentes de manière native et sécurisée.
* **Résilience réseau :** Si le réseau externe est en panne au moment d'exécuter un appel planifié, le scheduler gère les retries automatiquement sans figer la base de données.
* **Haute Disponibilité (Clustering) :** En utilisant un mécanisme de verrouillage (locking) dans SurrealDB via notre store, plusieurs instances du scheduler peuvent tourner en même temps sans jamais doubler l'exécution d'une tâche.

---

## 6. Documentation & Références

* 🌐 [Référence des APIs & Endpoints HTTP/REST](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_scheduler/croniq_api_reference.md)
* 📋 [Cartographie des Tables & Schémas SurrealQL](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_scheduler/croniq_tables_reference.md)
* ⚡ [Fonctions SurrealQL Stochastiques (`fn::scheduler::*`)](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_scheduler/functions/README.md)
