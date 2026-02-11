# Blueprint : Extension Kernel SurrealDB
Ce document détaille le pattern d'implémentation utilisé pour le Scheduler, servant de modèle pour toute future primitive native (ex: native webhooks, agents, etc.) intégrée au cœur de SurrealDB.

## Architecture "Kernel First"

L'intégration repose sur quatre piliers fondamentaux garantissant performance, persistance et cohérence distribuée.

### 1. Déclaration & Parser (AST)
Toute primitive commence par une syntaxe SQL officielle.
- **Parser** : Ajout des mots-clés dans `keywords_split.rs` et implémentation du parsing dans `syn/parser/stmt/define.rs`.
- **AST** : Définition de la structure dans `sql/statements/define/scheduler.rs` et conversion vers le type `expr` pour l'exécution.
- **Validation** : Validation à la compilation (syntaxe) et à l'exécution (permissions, existence).

### 2. Persistance & KVS (Kernel Storage)
Le stockage n'est pas une simple table utilisateur, mais une structure gérée par le noyau.
- **Clés Systèmes** : Utilisation de préfixes dédiés dans le KVS (ex: `!sd` pour scheduler definition) via `crates/core/src/key/database/sd.rs`.
- **Bootstrap Automatique** : La primitive est responsable de son propre schéma. La fonction `ensure_bootstrap` dans `sql/scheduler_bootstrap.rs` garantit que les tables système et les index sont créés/mis à jour dès la première utilisation.
- **Versioning** : Utilisation d'une clé de version (`/ns/db/!sv/schema_version`) pour gérer les migrations automatiques sans intervention humaine.

### 3. Bus d'Événements (SystemEvent)
Pour éviter le polling et garantir la réactivité en cluster.
- **Emission** : Le `Transaction::commit` dans `crates/core/src/kvs/tx.rs` émet un `SystemEvent` après chaque modification réussie du catalogue.
- **Propagation** : Le `Datastore` propage ces événements via un canal `broadcast` (Tokio).
- **Réaction** : Les services serveurs s'abonnent à ce canal pour réagir en temps réel (ex: monter/démonter une instance de scheduler).

### 4. Service Serveur (Execution Engine)
Le moteur d'exécution réside dans `crates/server`.
- **Event-Driven** : Pas de boucle de scan inutile. Le service attend des `SystemEvent` pour gérer son état interne.
- **Haute Disponibilité (Leases)** : Utilisation d'un mécanisme de verrouillage distribué (Lease) dans le KVS pour garantir qu'un job n'est exécuté que sur un seul nœud à la fois.
- **Isolation** : Utilisation de `CancellationToken` pour gérer le shutdown gracieux (mode Drain) sans corrompre les tâches en cours.

## Flux de données Type

1. `DEFINE SCHEDULER ...` → Parser → AST → Transaction KVS.
2. `Transaction::commit` → Emission `SystemEvent::SchedulerDefined`.
3. `SchedulerService` (Server) → Reçoit l'event → Enregistre l'instance.
4. `SchedulerService Loop` → Tente d'acquérir un `Lease` sur les jobs éligibles.
5. `SurrealJobExecutor` → Exécute l'action via le `Datastore` interne avec isolation et permissions (`run_as`).

## Standard d'Implémentation (Checklist)

- [ ] Syntaxe SQL native (pas de scripts manuels).
- [ ] Bootstrap automatique et versionné du schéma.
- [ ] Zéro polling côté serveur (Bus d'événements).
- [ ] Support distribué via Leases KVS.
- [ ] Observabilité (OTLP Metrics, Live Events, Structured Logs).
- [ ] Shutdown gracieux (Drain mode).
- [ ] Pas de dépendances externes critiques.

