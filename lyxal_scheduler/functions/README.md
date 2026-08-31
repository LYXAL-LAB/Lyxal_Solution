# 🛠️ Bibliothèque des Fonctions SurrealQL — Lyxal Scheduler

> **Référence** : `fn::scheduler::*`  
> **Source** : Involutivement extrait des 12 Traits du Store Croniq (`crates/croniq-store/src/traits.rs`)  
> **Emplacement des schémas** : `lyxal_scheduler/functions/`

Ce dossier contient l'ensemble des **fonctions SurrealQL natives (`DEFINE FUNCTION fn::scheduler::...`)** qui implémentent les opérations atomiques du moteur de planification Croniq directement dans SurrealDB.

---

## 📌 Catalogue des Fonctions par Domaine

### 1. ⚙️ Runtime Jobs (`JobStore`)
| Fonction SurrealQL | Rôle dans Croniq |
|--------------------|------------------|
| `fn::scheduler::job_state_get($job_key)` | Lit l'état runtime d'un job |
| `fn::scheduler::job_state_upsert($state)` | Crée ou met à jour l'état runtime d'un job |
| `fn::scheduler::job_state_list()` | Liste tous les états runtime |
| `fn::scheduler::job_state_delete($job_key)` | Supprime l'état d'un job |

### 2. 📋 Définitions de Jobs (`JobDefinitionStore`)
| Fonction SurrealQL | Rôle dans Croniq |
|--------------------|------------------|
| `fn::scheduler::job_def_create($job_def)` | Crée une définition de job |
| `fn::scheduler::job_def_get($job_key)` | Lit la définition d'un job |
| `fn::scheduler::job_def_list()` | Liste toutes les définitions |
| `fn::scheduler::job_def_delete($job_key)` | Supprime une définition |

### 3. 🚀 Exécutions & Tick (`ExecutionStore`)
| Fonction SurrealQL | Rôle dans Croniq |
|--------------------|------------------|
| `fn::scheduler::execution_create($execution)` | Crée une nouvelle exécution en file (`queued`) |
| `fn::scheduler::execution_create_and_advance_job($execution, $job_state)` | **Transaction atomique** : crée l'exécution ET fait avancer `next_fire_at` du job |
| `fn::scheduler::execution_get($id)` | Récupère une exécution par son UUID |
| `fn::scheduler::execution_claim($id, $runner_id, $now)` | Réserve une tâche en attente pour un runner |
| `fn::scheduler::execution_complete($id, $runner_id, $state, $duration_ms, $error, $dead_reason, $now)` | **Compare-And-Swap (fencing)** : marque l'exécution terminée |
| `fn::scheduler::execution_find_queued($capabilities, $limit)` | Recherche les tâches `queued` compatibles avec un runner |
| `fn::scheduler::execution_list_claimed_older_than($cutoff, $limit)` | Recherche les tâches bloquées/abandonnées pour le Watchdog SLA |
| `fn::scheduler::execution_find_by_idempotency($job_key, $idempotency_key, $window_start)` | Vérifie la déduplication événementielle |
| `fn::scheduler::execution_requeue_abandoned($runner_id, $now)` | Remet en file les tâches d'un runner mort |
| `fn::scheduler::execution_requeue_if_claimed($id, $now)` | Remet en `queued` une exécution toujours en `claimed` (CAS Watchdog) |
| `fn::scheduler::execution_cancel($id, $now)` | Annule une exécution |
| `fn::scheduler::execution_count_in_states($job_key, $states)` | Limiteur de concurrence par job (`max_concurrent`) |
| `fn::scheduler::execution_prune_older_than($cutoff, $limit)` | Purge chronologique des anciennes exécutions |
| `fn::scheduler::execution_prune_keep_last($job_key, $keep_last, $limit)` | Purge par quota max par job (`keep_last`) |

### 4. 👷 Runners (`RunnerStore`)
| Fonction SurrealQL | Rôle dans Croniq |
|--------------------|------------------|
| `fn::scheduler::runner_upsert($runner)` | Enregistre ou rafraîchit un runner |
| `fn::scheduler::runner_get($runner_id)` | Récupère un runner |
| `fn::scheduler::runner_list()` | Liste tous les runners enregistrés |
| `fn::scheduler::runner_remove($runner_id)` | Désenregistre un runner |
| `fn::scheduler::runner_update_poll($runner_id, $inflight, $now)` | Heartbeat du runner + mise à jour des tâches `inflight` |

### 5. 💀 Dead Letter Queue (`DeadLetterStore`)
| Fonction SurrealQL | Rôle dans Croniq |
|--------------------|------------------|
| `fn::scheduler::dead_letter_add($dl)` | Ajoute une tâche en Dead Letter |
| `fn::scheduler::dead_letter_complete_as_dead($execution_id, $runner_id, $duration_ms, $error, $dl, $now)` | **Transaction atomique** : ferme l'exécution en `dead` ET crée la Dead Letter |
| `fn::scheduler::dead_letter_replay($dead_letter_id, $execution)` | **Transaction atomique** : supprime la Dead Letter ET crée la nouvelle exécution de rejeu |
| `fn::scheduler::dead_letter_get($id)` | Récupère une Dead Letter |
| `fn::scheduler::dead_letter_list($filter)` | Liste les Dead Letters filtrées |
| `fn::scheduler::dead_letter_remove($id)` | Supprime une Dead Letter |
| `fn::scheduler::dead_letter_remove_bulk($ids)` | Supprime un lot de Dead Letters |
| `fn::scheduler::dead_letter_clear($job_key)` | Vide la DLQ pour un job ou totalement |
| `fn::scheduler::dead_letter_purge_expired($now)` | Purge automatique des Dead Letters expirées par le Watchdog |

### 6. ⏰ Déclencheurs (`TriggerDefinitionStore`)
| Fonction SurrealQL | Rôle dans Croniq |
|--------------------|------------------|
| `fn::scheduler::trigger_create($trigger)` | Crée un déclencheur |
| `fn::scheduler::trigger_get($trigger_id)` | Récupère un déclencheur |
| `fn::scheduler::trigger_list($job_key)` | Liste les déclencheurs (globaux ou par job) |
| `fn::scheduler::trigger_delete($trigger_id)` | Supprime un déclencheur |
| `fn::scheduler::trigger_update($trigger)` | Met à jour un déclencheur API |

### 7. 📅 Calendriers (`CalendarDefinitionStore`)
| Fonction SurrealQL | Rôle dans Croniq |
|--------------------|------------------|
| `fn::scheduler::calendar_create($cal)` | Crée un calendrier métier |
| `fn::scheduler::calendar_get($calendar_id)` | Récupère un calendrier |
| `fn::scheduler::calendar_list()` | Liste tous les calendriers |
| `fn::scheduler::calendar_delete($calendar_id)` | Supprime un calendrier |

### 8. 📜 Logs d'Exécution (`ExecutionLogStore`)
| Fonction SurrealQL | Rôle dans Croniq |
|--------------------|------------------|
| `fn::scheduler::log_append($entry)` | Ajoute une ligne de log |
| `fn::scheduler::log_append_batch($entries)` | **Transaction atomique** : insère un lot de lignes avec séquence monotone `seq` |
| `fn::scheduler::log_read($execution_id, $limit)` | Lit les logs ordonnés d'une exécution |

### 9. 🔄 Adoption DSL (`DslAdoptionStore`)
| Fonction SurrealQL | Rôle dans Croniq |
|--------------------|------------------|
| `fn::scheduler::dsl_adoption_insert($resource_type, $resource_key, $by)` | Marque une ressource DSL comme adoptée par l'API |
| `fn::scheduler::dsl_adoption_delete($resource_type, $resource_key)` | Restaure la version DSL d'une ressource |
| `fn::scheduler::dsl_adoption_is_adopted($resource_type, $resource_key)` | Teste si une ressource est adoptée |
| `fn::scheduler::dsl_adoption_list($resource_type)` | Liste les adoptions par type |

### 10. 🛡️ Maintenance (`MaintenanceStore`)
| Fonction SurrealQL | Rôle dans Croniq |
|--------------------|------------------|
| `fn::scheduler::maintenance_get()` | Lit l'état global du switch de maintenance |
| `fn::scheduler::maintenance_set($manual_active, $note, $by)` | Active/désactive le mode maintenance |

### 11. 📡 Alertes & Surcharges (`AlertStore`)
| Fonction SurrealQL | Rôle dans Croniq |
|--------------------|------------------|
| `fn::scheduler::alert_record_delivery($delivery)` | Enregistre une livraison d'alerte |
| `fn::scheduler::alert_list_deliveries($filter)` | Liste l'historique des alertes |
| `fn::scheduler::alert_last_fire_at($rule_name, $job_key)` | Retrouve le dernier tir d'alerte pour le throttle |
| `fn::scheduler::alert_override_upsert($override)` | Pose une surcharge d'alerte (snooze) |
| `fn::scheduler::alert_override_list()` | Liste les surcharges d'alertes |
| `fn::scheduler::alert_override_delete($rule_name)` | Supprime une surcharge d'alerte |
| `fn::scheduler::alert_override_delete_expired($now)` | Purge les surcharges expirées par le Watchdog |
