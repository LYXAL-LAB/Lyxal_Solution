# lyxal_scheduler

Moteur de scheduler générique basé sur des expressions cron (phase 1 standalone).  
Bloc 1 implémenté : cœur scheduler mono-executor, retry/backoff, DLQ, history.  
Bloc 2 implémenté : WorkerPool multi-workers + dispatcher, exécution parallèle avec timeouts.
Bloc 3 implémenté : isolation par instance via InstanceManager et pools dédiés.
Bloc 5 implémenté : adaptateur SurrealDB optionnel (feature surreal).
Bloc 6.2 (script SurrealQL) : voir `surrealdb-3.0.0-alpha.16/surrealdb-3.0.0-alpha.16/scheduler_control.surql` pour la surface schedule::* et le schéma scheduler::*.  

