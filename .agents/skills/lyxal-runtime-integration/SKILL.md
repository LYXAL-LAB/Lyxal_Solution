---
name: lyxal-runtime-integration
description: >-
  Use this skill when implementing, reviewing, or auditing the integration of a Lyxal OS module with lyxal_runtime and lyxal_event, including LyxalModule lifecycle, LyxalWorker supervision, CancellationToken cooperation, EventConsumerModule and HandlerRegistry wiring, transactional outbox delivery, distributed leases, and ModuleHealthCheck probes.
---

# Lyxal OS — Intégration Runtime & Bus d'Événements (`lyxal-runtime-integration`)

> **Source normative** : Ce Skill applique les principes d'architecture définis dans [`.agents/AGENTS.md`](../../AGENTS.md) (§5.6 et §5.8) et [`.agents/rules/lyxal_standards_and_checklist.md`](../../rules/lyxal_standards_and_checklist.md) (§11 et §13), en les rattachant aux **contrats Rust réellement implémentés** dans [`crates/lyxal_runtime`](../../../crates/lyxal_runtime/src/lib.rs) et [`crates/lyxal_event`](../../../crates/lyxal_event/src/lib.rs).
> **Note sur les exemples documentaires** : Lorsque les exemples illustratifs de `AGENTS.md` §5.8 diffèrent légèrement des signatures compilées du dépôt, **les signatures réelles de `crates/lyxal_runtime` et `crates/lyxal_event` documentées ci-dessous font foi** pour la compilation et l'audit.

---

## Quand déclencher ce Skill

Activer ce Skill dès qu'une mission implique :
- L'implémentation ou la vérification de [`LyxalModule`](../../../crates/lyxal_runtime/src/module.rs), [`LyxalWorker`](../../../crates/lyxal_runtime/src/worker/definition.rs) ou [`ModuleHealthCheck`](../../../crates/lyxal_runtime/src/health/check.rs) dans un module ;
- Le câblage de producteurs ou consommateurs d'événements via [`lyxal_event`](../../../crates/lyxal_event/src/lib.rs) et [`EventConsumerModule`](../../../crates/lyxal_runtime/src/event_engine/registration.rs) ;
- La supervision de tâches de fond, la gestion des timeouts, l'annulation coopérative (`CancellationToken`) ou l'arrêt gracieux (`stop_module` / `stop_all`) ;
- L'utilisation des baux distribués de migration ou d'installation (`MigrationLeaseManager`, `InstallationLeaseManager`).

---

## Contrôles Obligatoires vs Recommandations

> **Distinction Normative** : Les règles marquées **[OBLIGATOIRE]** constituent des invariants d'exécution et de sécurité (tout écart est classé **P0** ou **P1**). Les points marqués **[RECOMMANDATION]** guident le dimensionnement opérationnel (**P2**).

---

### 1. Cycle de Vie des Modules (`LyxalModule` & `LifecycleManager`)

#### Contrats réels de référence
- Trait [`LyxalModule`](../../../crates/lyxal_runtime/src/module.rs) :
  - `fn descriptor(&self) -> &ModuleDescriptor` (construit via [`ModuleDescriptorBuilder`](../../../crates/lyxal_runtime/src/descriptor.rs)) ;
  - `fn id(&self) -> &ModuleId` (dérivé par défaut de `self.descriptor().id()`) ;
  - `async fn install(&self, ctx: &ModuleContext) -> Result<(), RuntimeError>` ;
  - `async fn start(&self, ctx: &ModuleContext) -> Result<(), RuntimeError>` ;
  - `async fn stop(&self, ctx: &ModuleContext) -> Result<(), RuntimeError>`.
- Contexte d'exécution [`ModuleContext`](../../../crates/lyxal_runtime/src/context.rs) : fournit `module_id()`, `config()`, `get_config(key)` et `data::<T>()` (état partagé typé injecté par l'hôte, ex. `Store` ou `Surreal<Any>`).
- Machine à états [`LifecycleManager`](../../../crates/lyxal_runtime/src/lifecycle.rs) :
  - Transitions strictes : `Registered` $\rightarrow$ `Installing` $\rightarrow$ `Installed` $\rightarrow$ `Starting` $\rightarrow$ `Running` $\rightarrow$ `Stopping` $\rightarrow$ `Stopped` (ou `Failed` en cas d'erreur/timeout).
  - Un module déjà en état `Installed`, `Running` ou `Stopped` ne peut être réinstallé que si `reinstall = true` est explicitement demandé.

#### Règles de contrôle
1. **[OBLIGATOIRE] Synchronisation `manifest.toml` $\leftrightarrow$ `ModuleDescriptor`** : L'`id`, la `version`, les `dependencies` et les `capabilities` déclarés dans `ModuleDescriptorBuilder` doivent correspondre exactement à ceux du fichier `manifest.toml` du module.
2. **[OBLIGATOIRE] Respect des Timeouts de Cycle de Vie** : `LifecycleManager` encadre `install`, `start` et `stop` dans un `tokio::time::timeout` (`install_timeout`, `start_timeout`, `stop_timeout` de `RuntimeConfig`). Les hooks `start()` et `stop()` ne doivent **jamais** bloquer indéfiniment ni exécuter une boucle infinie (les boucles continues appartiennent exclusivement à `LyxalWorker::run`).
3. **[OBLIGATOIRE] Ordre Topologique de Démarrage** : [`LyxalRuntime::start_module`](../../../crates/lyxal_runtime/src/runtime.rs) vérifie que toutes les dépendances directes du module sont dans l'état `ModuleState::Running` avant d'autoriser `start()`. Aucun module ne doit contourner cette vérification.
4. **[OBLIGATOIRE] Propagation franche des erreurs** : Toute défaillance lors de `install`, `start` ou `stop` doit retourner `Err(RuntimeError::...)` afin que `LifecycleManager` bascule l'état sur `ModuleState::Failed` et incrémente les compteurs de santé (`install_failures`, `start_failures`).

---

### 2. Enregistrement des Handlers & Intégration `lyxal_event` (`EventConsumerModule` / `HandlerRegistry`)

#### Contrats réels de référence
- Événement de domaine : implémente [`lyxal_event::Event`](../../../crates/lyxal_event/src/handler/event.rs) (`const EVENT_TYPE: &'static str` au format `<module>.<entite>.<action>`, `Serialize + DeserializeOwned + Send + Sync + 'static`).
- Handler typé : implémente [`lyxal_event::Handler<E>`](../../../crates/lyxal_event/src/handler/handler.rs) :
  - `async fn handle(&self, event: E, ctx: &HandlerContext) -> Result<(), LyxalEventError>`
  - `fn name(&self) -> &'static str`
- Contexte de livraison [`HandlerContext`](../../../crates/lyxal_event/src/handler/context.rs) : expose `event_id`, `delivery_id`, `correlation_id`, `causation_id`, `context: EventContext` (`tenant_id`, `namespace`, `database`, `user_id`, `request_id`), `attempt: u32` et `cancellation: CancellationToken`.
- Registre [`HandlerRegistry`](../../../crates/lyxal_event/src/handler/registry.rs) : associe un `event_type` à un `ErasedHandler` unique par processus (`registry.register::<E, H>(handler)` retourne `Err(LyxalEventError::DuplicateHandler)` si le même `EVENT_TYPE` est enregistré deux fois dans le même `HandlerRegistry`).
- Pont Runtime [`EventConsumerModule`](../../../crates/lyxal_runtime/src/event_engine/registration.rs) :
  - `fn module_id(&self) -> &ModuleId`
  - `fn register_event_handlers(&self, registry: &mut HandlerRegistry) -> Result<(), RuntimeError>`

#### Règles de contrôle
1. **[OBLIGATOIRE] Découplage Producteur / Consommateur** : Un module producteur émet ses événements via `DEFINE EVENT ... THEN ( fn::event_publish({...}) )` en SurrealQL ou via `EventPublisher::publish` en Rust, sans **jamais** importer le crate d'un module consommateur.
2. **[OBLIGATOIRE] Enregistrement avant `init_event_engine()`** : Les modules consommateurs doivent être enregistrés auprès du Runtime via `runtime.register_event_consumer(...)` (ou `runtime.register_event_handler(...)`) **avant** l'appel à [`LyxalRuntime::init_event_engine()`](../../../crates/lyxal_runtime/src/runtime.rs), qui fige le `Arc<HandlerRegistry>` injecté dans `EventWorker`.
3. **[OBLIGATOIRE] Unicité par `EVENT_TYPE` dans `HandlerRegistry`** : Vérifier qu'aucun module n'enregistre deux handlers distincts pour le même `EVENT_TYPE` dans le même `HandlerRegistry`. Si plusieurs modules doivent réagir au même événement, chaque consommateur dispose de son propre `EventSubscription` (`consumer_group` distinct en SurrealDB) ou d'un routeur explicite.
4. **[OBLIGATOIRE] Règle d'Idempotence et de Retry (`At-Least-Once`)** :
   - Le transport garantit une livraison *At-Least-Once* (`attempt >= 1`). Tout `Handler<E>::handle` **doit être idempotent** (vérification d'état métier, clé d'idempotence `event_id` / `delivery_id` / `correlation_id`).
   - En cas d'erreur transitoire, le handler **doit retourner `Err(LyxalEventError::Handler(...))`** pour déclencher `store.delivery_failure(...)` et le recalcul du backoff exponentiel avec Full Jitter ([`compute_next_retry_delay`](../../../crates/lyxal_event/src/worker/retry.rs)). Il est **strictement interdit (P0)** d'avaler silencieusement une erreur avec `Ok(())`.

---

### 3. Supervision des Workers (`LyxalWorker`), `EventWorkerService` & `CancellationToken`

#### Contrats réels de référence
- Trait [`LyxalWorker`](../../../crates/lyxal_runtime/src/worker/definition.rs) :
  - `fn descriptor(&self) -> &WorkerDescriptor`
  - `async fn run(&self, ctx: WorkerContext) -> Result<(), RuntimeError>`
- Descripteur [`WorkerDescriptor`](../../../crates/lyxal_runtime/src/worker/descriptor.rs) :
  - `id: WorkerId` (format canonique `<module_id>:<worker_name>`) ;
  - `module_id: ModuleId` ;
  - `criticality: WorkerCriticality` (`Required` ou `Optional`) ;
  - `restart_policy: RestartPolicy` (`Never`, `OnFailure { max_retries, backoff }`, `Always { max_retries, backoff }`) ;
  - `shutdown_timeout: Duration`.
- Contexte [`WorkerContext`](../../../crates/lyxal_runtime/src/worker/context.rs) :
  - `pub module_id: ModuleId`, `pub worker_id: WorkerId`, `pub module_context: ModuleContext`, `pub cancellation: CancellationToken` (et méthode `ctx.is_cancelled()`).
- Adaptateurs Runtime du moteur d'événements ([`worker_adapter.rs`](../../../crates/lyxal_runtime/src/event_engine/worker_adapter.rs)) :
  - `EventWorkerService` : enveloppe `lyxal_event::EventWorker` en `LyxalWorker` avec `WorkerCriticality::Required` et `RestartPolicy::Always` ;
  - `EventGarbageCollectorService` : enveloppe `lyxal_event::GarbageCollector` en `LyxalWorker` avec `WorkerCriticality::Optional` et `RestartPolicy::OnFailure`.

#### Règles de contrôle
1. **[OBLIGATOIRE] Zéro `tokio::spawn` sauvage dans les modules métiers** : Tout traitement périodique ou continu d'arrière-plan d'un module métier doit implémenter `LyxalWorker` et être enregistré dans le Runtime via `runtime.register_worker(...)` pour être supervisé par `WorkerSupervisor`.
2. **[OBLIGATOIRE] Coopération active avec `CancellationToken`** :
   - Dans `LyxalWorker::run(self, ctx: WorkerContext)`, toute boucle ou attente asynchrone (`tokio::time::sleep`, lecture canal/réseau) doit utiliser `tokio::select!` sur `ctx.cancellation.cancelled()` et vérifier `ctx.is_cancelled()` entre deux itérations (modèle canonique : [`IngestionWorker`](../../../crates/lyxal_pipeline_ingestion/src/worker/ingestion_worker.rs)).
   - Dans `Handler<E>::handle`, les opérations longues doivent coopérer avec `ctx.cancellation` (qui est un `child_token()` annulé automatiquement par `EventWorker` à l'expiration de `dispatch_timeout` ou lors du shutdown).
3. **[OBLIGATOIRE] Invariant « No-Zombie » à l'arrêt (`stop_module` / `stop_all`)** :
   - Conformément à [`LyxalRuntime::stop_module`](../../../crates/lyxal_runtime/src/runtime.rs) et `stop_all`, les workers supervisés d'un module sont **toujours arrêtés en premier** (`worker_supervisor.stop_module_workers` / `stop_all`), **avant** l'appel à `lifecycle.stop_module` (exécuté en ordre topologique inverse).
   - Le hook `LyxalModule::stop` ne doit jamais supposer qu'un worker du module tourne encore, et `LyxalWorker::run` doit se terminer en moins de `shutdown_timeout` dès le déclenchement de `ctx.cancellation.cancel()`.
4. **[OBLIGATOIRE] Reprise sur crash du Fan-Out (`recover_pending_fanouts`)** :
   - Vérifier que l'initialisation (`init_event_engine`) et la boucle de maintenance de `EventWorker` (`fanout_recovery_interval`) exécutent bien `store.recover_pending_fanouts(batch_size)` pour reprendre les événements restés en statut `pending` dans `event_outbox` après un crash.
5. **[RECOMMANDATION] Choix de `WorkerCriticality` et `RestartPolicy`** :
   - Utiliser `WorkerCriticality::Required` uniquement si la perte définitive du worker (`WorkerState::Failed` / `TimedOut`) doit faire basculer la santé globale du module en `HealthStatus::Unhealthy` ; utiliser `WorkerCriticality::Optional` pour les tâches de nettoyage ou d'optimisation (qui dégradent le statut en `HealthStatus::Degraded`).

---

### 4. Baux Distribués (`MigrationLeaseManager` & `InstallationLeaseManager`)

#### Contrats réels de référence
- [`MigrationLeaseManager`](../../../crates/lyxal_runtime/src/lock/manager.rs) (`MigrationLockKey`, `MigrationLease`) et [`InstallationLeaseManager`](../../../crates/lyxal_runtime/src/lock/installation.rs) (`InstallationLockKey` = `<module_id>:<version>`, `InstallationLease`).
- Implémentations SurrealDB (`SurrealMigrationLeaseManager`, `SurrealInstallationLeaseManager`) et mémoire (`Memory*`).

#### Règles de contrôle
1. **[OBLIGATOIRE] Monotonie du Fencing Token (`generation`) & Zéro `DELETE`** :
   - Tout bail distribué repose sur un jeton d'escrime monotone `generation: u64` vérifié par CAS (`WHERE generation = $expected_gen`).
   - La libération (`release`) d'un bail SurrealDB ne doit **JAMAIS exécuter `DELETE`** sur l'enregistrement de verrou (`system_installation_lock` / verrou de migration), car cela réinitialiserait `generation` à `1` et violerait la protection contre les écrivains zombies (*split-brain*). La libération doit être strictement logique (`SET is_released = true, expires_at = 0`).
2. **[OBLIGATOIRE] Garantie d'Exécution Unique de `install()`** :
   - Toute mutation d'installation de schéma ou de migration exécutée par le Runtime doit être protégée par l'acquisition préalable du bail (`acquire`), le renouvellement (`renew`) si nécessaire, et la vérification de l'état déjà installé après acquisition du verrou.
3. **[OBLIGATOIRE] Point d'attention SurrealDB 3.2.0 sur les verrous** :
   - Lors d'un audit de `crates/lyxal_runtime/src/lock/`, vérifier si les requêtes SurrealQL internes utilisent `type::thing(...)` (ex. dans [`installation.rs`](../../../crates/lyxal_runtime/src/lock/installation.rs)) et signaler tout écart de compatibilité avec SurrealDB 3.2.0 (`type::record`).

---

### 5. Sondes de Santé (`ModuleHealthCheck` & `HealthEngine`)

#### Contrats réels de référence
- Trait [`ModuleHealthCheck`](../../../crates/lyxal_runtime/src/health/check.rs) :
  - `fn module_id(&self) -> &ModuleId`
  - `async fn check(&self, ctx: &ModuleContext) -> Result<HealthCheckResult, RuntimeError>`
- Résultat [`HealthCheckResult`](../../../crates/lyxal_runtime/src/health/check.rs) : constructeurs `healthy(msg)`, `degraded(msg)`, `unhealthy(msg)`, `unknown(msg)`, `not_applicable()` produisant un `HealthStatus`.

#### Règles de contrôle
1. **[OBLIGATOIRE] Sonde légère et non bloquante** : `ModuleHealthCheck::check` est appelée périodiquement par `HealthEngine` sous un timeout strict (`health_check_timeout`). Elle doit vérifier la disponibilité des ressources critiques du module dans `ctx: &ModuleContext` sans effectuer de requêtes lourdes ou mutantes (modèle de référence : [`IngestionHealthCheck`](../../../crates/lyxal_pipeline_ingestion/src/health.rs)).
2. **[OBLIGATOIRE] Enregistrement dans le Runtime** : Si un module définit une structure implémentant `ModuleHealthCheck`, vérifier qu'elle est effectivement enregistrée via `runtime.register_health_check(...)`.

---

### 6. Dépendances Cargo & Séparation Module vs Hôte

1. **[OBLIGATOIRE] Règle de Séparation Module / Hôte ([`AGENTS.md` §5.8.5](../../AGENTS.md))** :
   - Un module métier (`crates/lyxal_*`) implémente les traits `LyxalModule`, `LyxalWorker`, `ModuleHealthCheck` et `EventConsumerModule`, mais **n'instancie jamais `LyxalRuntime`** en production (seuls `apps/lyxal-server`, la CLI ou les tests d'intégration du module instancient `LyxalRuntime`).
2. **[OBLIGATOIRE] Direction du graphe Cargo** :
   - Les crates de fondation situés sous `lyxal_runtime` (`lyxal_error`, `lyxal_surreal`, `lyxal_crypto`, `lyxal_event`) ne doivent **jamais** dépendre de `lyxal_runtime`.

---

## Format du Livrable `lyxal-runtime-integration`

Lors de l'exécution de ce Skill, toujours produire un rapport structuré comportant :

1. **Tableau de Vérification des Contrats Runtime & Event** :
   - État de conformité (`Conforme`, `Écart P0/P1/P2`, `Non applicable`) pour : `LyxalModule`, `ModuleDescriptor` vs `manifest.toml`, `LyxalWorker` & `CancellationToken`, `Event` / `Handler<E>` / `EventConsumerModule`, Idempotence & Retry, Baux distribués, `ModuleHealthCheck`.
2. **Diagnostic des Risques Runtime Identifiés** :
   - Risques de blocage (`timeout`), de tâches zombies à l'arrêt, de perte ou duplication d'événements (*At-Least-Once*), de collision `DuplicateHandler` ou de violation du fencing token.
3. **Fichiers Concernés & Preuves** :
   - Liste des fichiers et lignes inspectés avec liens cliquables `[fichier](file:///...#Lxx-Lyy)`.
4. **Tests d'Intégration Recommandés ou Exécutés** :
   - Scénarios de test couvrant : cycle `install -> start -> stop`, annulation coopérative d'un worker sous `shutdown_timeout`, idempotence d'un handler rejoué (`attempt = 2`), et reprise `recover_pending_fanouts`.

