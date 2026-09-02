# 📑 Audit Architectural & Technique Approfondi pour `lyxal_event`
## Évaluation comparative d'Oxide Outbox (`Vancoola/oxide-outbox`) et de Hexeract (`nubster-opensources/hexeract`)

> **Date** : 1er Septembre 2026  
> **Auteur** : Antigravity (Assistant Ingénierie & Architecture Système)  
> **Destinataire** : CTO & Équipe d'Ingénierie Lyxal OS  
> **Cible** : Spécification et fondations de conception pour le crate `lyxal_event`

---

## 1. Executive Summary

Le module `lyxal_runtime` ayant été audité et stabilisé, la prochaine étape architecturale de Lyxal OS est la création de **`lyxal_event`** : le bus d'événements asynchrone et découplé de la plateforme.

Dans Lyxal OS, un module métier (ex: `lyxal_booking`) doit pouvoir émettre un événement de domaine (`booking.created`) sans connaître ni référencer les modules consommateurs (`lyxal_notification`, `lyxal_scheduler`, `lyxal_webhook`, `lyxal_crm`, `lyxal_analytics`, IA). Les événements proviennent soit de mutations déclaratives SurrealDB (`DEFINE EVENT ... ON TABLE ...` écrivant dans `event_outbox`), soit de publications explicites via l'API Rust.

Cet audit a analysé en profondeur, au niveau du code source réel, des structures de données, des call chains, des algorithmes de locking/concurrence, de la gestion des erreurs et des licences, deux repositories open source majeurs :
1. **`oxide-outbox` (v0.1.0, Rust edition 2024, Licence MIT)** : Un moteur spécialisé dans le pattern Transactional Outbox avec séparation core/stockage/transport (PostgreSQL, Redis, Kafka).
2. **`hexeract` (v0.6.0, Rust edition 2024, Licence duale MIT / Apache-2.0)** : Un framework complet de messagerie asynchrone (Mediator in-process, Bus distribué, Outbox/Inbox transactionnel SQLx, Scheduler, RPC Request-Reply).

### Synthèse de la Recommandation

| Option | Verdict | Justification |
| :--- | :---: | :--- |
| **A. Forker Oxide Outbox** | ❌ **Rejeté** | Oxide est trop étroit : il suppose un broker externe (Kafka) pour le fan-out, n'a pas de registre de handlers typés, repose sur un type payload statique (`Event<PT>`) et utilise Redis pour son DLQ. |
| **B. Forker Hexeract** | ❌ **Rejeté** | Hexeract est trop vaste et fortement couplé aux dialectes SQL relationnels (`sqlx::PgPool`, MySQL, SQLite). Il embarque des modules redondants avec Lyxal (`hexeract-scheduler`, `hexeract-bus` RabbitMQ). |
| **C. Extraire un bloc unique** | ❌ **Insuffisant** | Aucun des deux frameworks ne gère le modèle de persistance et de fan-out natif requis sur SurrealDB (`event_outbox` -> `event_delivery`). |
| **D / E. Conception Native `lyxal_event` (Approche Hybride & Native Lyxal)** | 🎯 **RECOMMANDÉE** | **Créer un crate natif `crates/lyxal_event`** intégrant les **gold standards d'ingénierie de Hexeract** (gestion des baux de locking avec échelle `batch_size * timeout`, backoff exponentiel avec full-jitter, type-erased handler registry, tokens d'annulation coopératifs `tokio_util::sync::CancellationToken`) et les **abstractions claires d'Oxide** (séparation `OutboxWriter` / `OutboxStorage`, Garbage Collector dédié), tout en implémentant le modèle de persistance relationnel/graphe propre à **SurrealDB**. |

---

## 2. Architecture Globale de `oxide-outbox`

### 2.1 Cartographie du Workspace

```text
oxide-outbox/
├── Cargo.toml                  <-- Workspace (Rust 2024, edition 2024, resolver 2)
├── outbox-core/                <-- Abstractions fondamentales & boucle worker
│   ├── Cargo.toml
│   └── src/
│       ├── lib.rs              <-- Re-exports & prelude
│       ├── model.rs            <-- Event<PT>, EventStatus (Pending, Processing, Sent)
│       ├── object.rs           <-- Newtypes typés (EventId, EventType, IdempotencyToken, Payload)
│       ├── storage.rs          <-- Traits OutboxStorage<P> & OutboxWriter<P>
│       ├── publisher.rs        <-- Trait Transport<P>
│       ├── service.rs          <-- OutboxService<W, S, P> (Point d'entrée producteur)
│       ├── manager.rs          <-- OutboxManager<S, P, PT> (Boucle de run du worker)
│       ├── processor.rs        <-- OutboxProcessor<S, T, P> (Traitement par batch)
│       ├── gc.rs               <-- GarbageCollector (Purge par rétention)
│       ├── builder.rs          <-- OutboxManagerBuilder
│       ├── config.rs           <-- OutboxConfig<P>, IdempotencyStrategy
│       ├── dlq/                <-- Dead Letter Queue (Processor & DlqHeap trait)
│       └── idempotency/        <-- IdempotencyStorageProvider trait
├── outbox-postgres/            <-- Implémentation PostgreSQL (sqlx, LISTEN/NOTIFY)
├── outbox-redis/               <-- Implémentation DLQ Heap & Idempotence Redis
├── outbox-kafka/               <-- Transport d'émission vers Apache Kafka (rdkafka)
└── example/                    <-- Exemples d'intégration
```

### 2.2 Chaîne d'Appel (Call Chain) dans Oxide

```text
[Producteur applicatif]
         │
         ▼
OutboxService::add_event("type", payload, token, &mut tx)
         │──> 1. IdempotencyStrategy::invoke() -> Token
         │──> 2. IdempotencyStorageProvider::try_reserve(token) [Optionnel Redis]
         └──> 3. OutboxWriter::insert_event(Event<P>, &mut tx)
                     │
                     ▼ (Postgres INSERT dans outbox_events)

[Worker Asynchrone]
OutboxManager::run()
         │
         ├──> tokio::spawn(GarbageCollector::run()) -> Storage::delete_garbage()
         ├──> tokio::spawn(DlqProcessor::run()) -> DlqHeap::drain_exceeded() -> Storage::quarantine_events()
         │
         └──> Boucle principale (tokio::select!):
                 ├── Storage::wait_for_notification("outbox_event") [PgListener]
                 ├── interval.tick() [Polling de secours]
                 └── shutdown_rx.changed()
                         │
                         ▼
                 OutboxProcessor::process_pending_events()
                         │
                         ├──> 1. Storage::fetch_next_to_process(batch_size)
                         │       (UPDATE ... RETURNING via FOR UPDATE SKIP LOCKED)
                         │
                         ├──> 2. Pour chaque événement :
                         │       Transport::publish(event).await
                         │       ├── Si Succès : push success_id, DlqHeap::record_success(id)
                         │       └── Si Échec : log error, DlqHeap::record_failure(id)
                         │
                         └──> 3. Storage::update_status(&success_ids, EventStatus::Sent)
```

---

## 3. Architecture Globale de `hexeract`

### 3.1 Cartographie du Workspace

```text
hexeract/
├── Cargo.toml                      <-- Workspace (Rust 2024, resolver 3)
├── crates/
│   ├── hexeract-core/              <-- Primitives fondamentales
│   │   ├── ids.rs                  <-- MessageId, CorrelationId, HandlerId (UUIDv7)
│   │   ├── context.rs              <-- HandlerContext (avec CancellationToken)
│   │   ├── envelope.rs             <-- MessageEnvelope
│   │   ├── command.rs, query.rs    <-- Traits CQRS single-handler
│   │   ├── notification.rs         <-- Trait Notification multi-handler
│   │   ├── handler.rs              <-- CommandHandler, QueryHandler, NotificationHandler
│   │   ├── middleware.rs           <-- Pipeline de middlewares (DynMiddleware)
│   │   └── error.rs                <-- HexeractError
│   │
│   ├── hexeract-outbox/            <-- Cœur Outbox agnostique
│   │   ├── event.rs                <-- Trait Event (const EVENT_TYPE: &'static str)
│   │   ├── envelope.rs             <-- OutboxEnvelope (JSON bytes, attempts, retry, DLQ)
│   │   ├── handler.rs              <-- Trait Handler<E>
│   │   ├── worker.rs               <-- OutboxWorker, OutboxStore trait, TypedHandler, ErasedHandler
│   │   ├── publisher.rs            <-- Trait OutboxPublisher
│   │   ├── idempotent.rs           <-- Trait IdempotentOutboxEnqueue
│   │   └── error.rs                <-- OutboxError (DispatchTimeout, PoolTimeout, etc.)
│   │
│   ├── hexeract-outbox-sql/        <-- Adaptateur SQL outbox (PostgreSQL, MySQL, SQLite)
│   │   ├── dialect.rs              <-- Générateur DDL et requêtes SQL par moteur
│   │   ├── postgres.rs             <-- PgOutboxStore (sqlx::PgPool)
│   │   ├── mysql.rs                <-- MySqlOutboxStore
│   │   ├── sqlite.rs               <-- SqliteOutboxStore
│   │   └── envelope.rs             <-- Mapping SQL <-> OutboxEnvelope
│   │
│   ├── hexeract-mediator/          <-- Médiateur in-process (Command/Query/Notification)
│   ├── hexeract-bus/               <-- Bus distribué (AMQP / RabbitMQ / RPC Request-Reply)
│   ├── hexeract-bus-rabbitmq/      <-- Adaptateur RabbitMQ (lapin)
│   ├── hexeract-scheduler/         <-- Moteur de planification cron/intervalles
│   ├── hexeract-scheduler-sql/     <-- Persistance SQL du scheduler
│   ├── hexeract-middleware/        <-- Middlewares (Tracing, Timeout)
│   ├── hexeract-macros/            <-- Proc-macros (#[derive(Event)], #[handler])
│   └── hexeract-cli/               <-- CLI de gestion
```

### 3.2 Chaîne d'Appel (Call Chain) dans Hexeract Outbox

```text
[Producteur applicatif]
         │
         ▼
OutboxPublisher::enqueue(&mut tx, &event).await
         │──> 1. Serialisation JSON du domaine -> OutboxEnvelope
         └──> 2. INSERT INTO outbox_table (event_id, event_type, payload, ...)

[Outbox Worker Asynchrone]
OutboxWorker::run(cancel_token)
         │
         ▼
Boucle de polling (poll_cycle):
         │
         ├──> PHASE 1 : Claim atomique (Transaction SQL courte)
         │       ├── 1. Store::acquire() & Store::begin()
         │       ├── 2. Store::poll(batch_size, max_attempts)
         │       │      (SELECT ... FOR UPDATE SKIP LOCKED)
         │       ├── 3. Store::claim(&ids, lease_for(batch_len))
         │       │      (UPDATE next_retry_at = NOW() + (batch_len * dispatch_timeout), attempts += 1)
         │       └── 4. Store::commit(tx) -> Relâche immédiatement les verrous lignes !
         │
         └──> PHASE 2 : Dispatch séquentiel & Settle unitaire (Hors verrou global)
                 │
                 Pour chaque OutboxEnvelope du batch :
                 │
                 ├── 1. Recherche du handler dans le registre ErasedHandler (par event_type)
                 ├── 2. Instanciation HandlerContext avec child cancellation token
                 ├── 3. Exécution avec timeout strict :
                 │      tokio::time::timeout(dispatch_timeout, handler.handle(&envelope, &ctx))
                 │
                 ├── Si SUCCÈS :
                 │      Transaction unitaire : Store::mark_delivered(event_id) -> commit
                 │
                 └── Si ÉCHEC ou TIMEOUT :
                        Calcul du backoff : next_retry_delay(attempts) avec Full Jitter
                        Transaction unitaire :
                        ├── Store::mark_failed(event_id, error, retry_in)
                        └── Si attempts >= max_attempts :
                                Store::mark_dead_lettered(event_id, error)
                        Commit de la transaction d'échec
```

---

## 4. Analyse Détaillée de `oxide-outbox`

### 4.1 Points Forts
1. **Séparation Écriture / Lecture** : La ségrégation entre `OutboxWriter<P>` (côté producteur) et `OutboxStorage<P>` (côté worker) est très propre. Un microservice ou module qui se contente de publier n'embarque que `OutboxWriter`.
2. **Garbage Collector Isolé** : `GarbageCollector` s'exécute dans sa propre tâche Tokio sur un intervalle paramétrable et purge les messages `Sent` ayant dépassé le délai de rétention.
3. **Absence de Macros Opaques** : Code Rust direct, typé, sans magie de proc-macros invasives.
4. **Intégration Tracing & Metrics** : Emission native de compteurs et d'histogrammes de durée d'émission (`outbox.events_total`, `outbox.publish_duration_seconds`).

### 4.2 Faiblesses & Limitations Majeures pour Lyxal OS
1. **Monoconsommation / Absence de Fan-Out Interne** : Oxide a été conçu pour vider une table outbox vers un broker externe (Kafka/RabbitMQ). Il ne connaît pas la notion d'abonnements internes multiples (`1 événement -> N modules Lyxal`).
2. **Généricité Monomorphique Rigide (`Event<PT>`)** : Tout le crate `outbox-core` est paramétré par un type payload générique unique `PT`. Pour gérer des événements hétérogènes (`booking.created`, `invoice.paid`, etc.), l'intégrateur est contraint d'utiliser une `enum` monolithique de tous les événements de l'univers ou de typer `PT = serde_json::Value`, ce qui détruit le typage fort au niveau de la signature.
3. **Gestion DLQ Découplée dans Redis / Mémoire** : La gestion des retries et de la DLQ ne vit pas dans la table d'événements : les compteurs d'échecs sont accumulés dans une structure externe (`DlqHeap` en mémoire ou Redis Sorted Set), puis une tâche reaper effectue un `quarantine_events`. Si l'application crash avant que le DlqHeap ne soit persisté, les compteurs d'échecs en mémoire sont perdus !
4. **Pas de Backoff Exponentiel Déterministe en Base** : Lorsqu'un envoi échoue dans Oxide, la ligne reste simplement en statut `Processing` jusqu'à expiration du verrou `locked_until` (ex: 5 minutes fixes). Il n'y a pas d'incrémentation progressive du délai de retry (1s, 2s, 4s, 8s...).

---

## 5. Analyse Détaillée de `hexeract`

### 5.1 Points Forts
1. **Algorithme de Bail (Leasing) de Haute Précision** :
   * Hexeract résout un problème critique de concurrence : la durée du bail (`lease_for`) est dimensionnée à `batch_len * dispatch_timeout`.
   * Le worker acquiert le lot avec `FOR UPDATE SKIP LOCKED`, incrémente `attempts`, pose le bail en base sur l'horloge du serveur SQL (`next_retry_at = NOW() + lease`), puis **commite immédiatement la transaction SQL**.
   * Les verrous de lignes sont relâchés instantanément pour ne pas bloquer les autres workers, tandis que le bail garantit qu'aucun worker concurrent ne réclamera les éléments du lot pendant leur traitement séquentiel.
2. **Backoff Exponentiel avec Full Jitter** :
   * Calcul overflow-safe avec `checked_shl` et saturation (`saturating_mul`).
   * Full jitter tiré via `fastrand` sur `[0, capped_delay]`, évitant les effets d'avalanche (thundering herd) lors du réveil des retries.
3. **Registre de Handlers Type-Erased (`ErasedHandler` + `TypedHandler`)** :
   * Permet d'enregistrer des handlers fortement typés `Handler<E>` pour des événements spécifiques, tout en permettant au worker de router dynamiquement les messages d'après leur string `event_type`.
4. **Contexte d'Annulation Coopératif** :
   * Le `HandlerContext` transmet des identifiants stables (`MessageId`, `CorrelationId`) et un token d'annulation Tokio enfant (`cancel.child_token()`).
   * En cas de dépassement du `dispatch_timeout`, le token enfant est signalé pour permettre au handler de s'interrompre proprement avant le drop.
5. **Isolation des Échecs de Settle** :
   * Si l'acquittement (`mark_delivered` ou `mark_failed`) d'une enveloppe échoue (ex: déconnexion transitoire), l'erreur est journalisée et le worker continue de traiter le reste du batch sans abandonner l'ensemble du lot.

### 5.2 Faiblesses & Incompatibilités pour Lyxal OS
1. **Couplage Fort aux Dialectes SQL Relationnels** :
   * `hexeract-outbox-sql` génère dynamiquement des requêtes SQL pour Postgres (`$1`), MySQL (`?`) et SQLite (`?`).
   * SurrealDB n'utilise pas le SQL standard mais SurrealQL (syntaxe `fn::*`, gestion native des `RecordId`, types `datetime`, schémas schemaless/schemafull, pas de `BIGSERIAL` ni de syntaxe `FOR UPDATE SKIP LOCKED` relationnelle classique).
2. **Périmètre Débordant (Scope Creep)** :
   * Hexeract embarque un ordonnanceur complet (`hexeract-scheduler`), un framework RPC request-reply, et un médiateur CQRS.
   * L'intégration globale de Hexeract violerait la Constitution de Lyxal OS (qui confie l'ordonnancement à `lyxal_scheduler` et le cycle de vie à `lyxal_runtime`).
3. **Fan-Out Persistant Manquant** :
   * Dans `hexeract-outbox`, 1 ligne outbox est consommée par 1 seul `Handler`.
   * Si 4 modules Lyxal doivent réagir au même événement `booking.created`, le modèle outbox de Hexeract nécessiterait d'insérer 4 lignes distinctes ou de déléguer à un broker RabbitMQ.

---

## 6. Comparaison Directe des Deux Projets

| Critère d'Architecture | Oxide Outbox | Hexeract Outbox | Cible Idéale `lyxal_event` |
| :--- | :---: | :---: | :---: |
| **Périmètre & Focus** | Transactional Outbox pur | Framework Messaging large | Moteur d'événements & Fan-Out interne |
| **Typage du Payload** | Statique (`Event<PT>`) | `Vec<u8>` (JSON Type-Erased) | `serde_json::Value` & DTOs typés |
| **Registre de Handlers** | Aucun (Transport unique) | Registry `ErasedHandler` dynamique | Registry typé par module / topic |
| **Durée du Bail (Lease)** | Fixe par ligne (`locked_until`) | Dynamique (`batch * timeout`) | Dynamique sur horloge SurrealDB |
| **Stratégie de Retry** | Timeout fixe (pas de backoff) | Exponentiel + Full Jitter | Exponentiel + Full Jitter |
| **Stockage DLQ** | Externe (Redis / Heap) | Table SQL dédiée (`*_dead_letter`) | Table `event_dead_letter` SurrealDB |
| **Fan-Out Multi-Modules** | Non (délégué à Kafka) | Non (1 ligne = 1 handler) | **Oui natif** (`event_delivery`) |
| **Gestion du Shutdown** | `tokio::sync::watch` | `CancellationToken` | `CancellationToken` |
| **Isolation Multi-Tenant** | Non intégrée | Via headers applicatifs | Contexte `tenant` / `namespace` natif |
| **Adaptabilité SurrealDB** | Moyenne | Moyenne | **100% Natif SurrealQL / Surreal<Any>** |
| **Licence** | MIT | MIT / Apache-2.0 | Compatible Lyxal OS |

---

## 7. Compatibilité SurrealDB & Modélisation des Tables

SurrealDB possède des caractéristiques uniques qui rendent obsolètes les patterns SQL traditionnels (comme `FOR UPDATE SKIP LOCKED` ou les `BIGSERIAL`) et permettent une architecture d'événements beaucoup plus puissante.

### 7.1 Schéma Cible SurrealDB pour `lyxal_event`

Le moteur `lyxal_event` reposera sur 4 tables principales :

```surql
-- 1. Table principale de l'outbox (Événements bruts produits)
DEFINE TABLE OVERWRITE event_outbox SCHEMAFULL;
DEFINE FIELD OVERWRITE event_id ON TABLE event_outbox TYPE string;
DEFINE FIELD OVERWRITE event_type ON TABLE event_outbox TYPE string;
DEFINE FIELD OVERWRITE source ON TABLE event_outbox TYPE record;
DEFINE FIELD OVERWRITE producer ON TABLE event_outbox TYPE string;
DEFINE FIELD OVERWRITE payload ON TABLE event_outbox TYPE object;
DEFINE FIELD OVERWRITE metadata ON TABLE event_outbox TYPE object;
DEFINE FIELD OVERWRITE status ON TABLE event_outbox TYPE string DEFAULT "pending"
    ASSERT $value IN ["pending", "dispatched", "archived"];
DEFINE FIELD OVERWRITE created_at ON TABLE event_outbox TYPE datetime DEFAULT time::now();

DEFINE INDEX OVERWRITE idx_outbox_pending ON TABLE event_outbox
    COLUMNS status, created_at;

-- 2. Table des abonnements (Déclaration des consommateurs)
DEFINE TABLE OVERWRITE event_subscription SCHEMAFULL;
DEFINE FIELD OVERWRITE name ON TABLE event_subscription TYPE string;
DEFINE FIELD OVERWRITE target_module ON TABLE event_subscription TYPE string;
DEFINE FIELD OVERWRITE event_patterns ON TABLE event_subscription TYPE array<string>;
DEFINE FIELD OVERWRITE is_active ON TABLE event_subscription TYPE bool DEFAULT true;
DEFINE FIELD OVERWRITE created_at ON TABLE event_subscription TYPE datetime DEFAULT time::now();

-- 3. Table des distributions / consommations (Fan-Out persistant unitaire)
DEFINE TABLE OVERWRITE event_delivery SCHEMAFULL;
DEFINE FIELD OVERWRITE outbox_event ON TABLE event_delivery TYPE record<event_outbox>;
DEFINE FIELD OVERWRITE subscription ON TABLE event_delivery TYPE record<event_subscription>;
DEFINE FIELD OVERWRITE target_module ON TABLE event_delivery TYPE string;
DEFINE FIELD OVERWRITE status ON TABLE event_delivery TYPE string DEFAULT "pending"
    ASSERT $value IN ["pending", "processing", "delivered", "failed", "dead_letter"];
DEFINE FIELD OVERWRITE attempts ON TABLE event_delivery TYPE number DEFAULT 0;
DEFINE FIELD OVERWRITE max_attempts ON TABLE event_delivery TYPE number DEFAULT 5;
DEFINE FIELD OVERWRITE next_retry_at ON TABLE event_delivery TYPE datetime DEFAULT time::now();
DEFINE FIELD OVERWRITE locked_until ON TABLE event_delivery TYPE option<datetime>;
DEFINE FIELD OVERWRITE last_error ON TABLE event_delivery TYPE option<string>;
DEFINE FIELD OVERWRITE delivered_at ON TABLE event_delivery TYPE option<datetime>;
DEFINE FIELD OVERWRITE created_at ON TABLE event_delivery TYPE datetime DEFAULT time::now();

DEFINE INDEX OVERWRITE idx_delivery_claim ON TABLE event_delivery
    COLUMNS status, next_retry_at;

-- 4. Table Dead Letter Queue (Audit et Replay)
DEFINE TABLE OVERWRITE event_dead_letter SCHEMAFULL;
DEFINE FIELD OVERWRITE delivery_id ON TABLE event_dead_letter TYPE record<event_delivery>;
DEFINE FIELD OVERWRITE outbox_event ON TABLE event_dead_letter TYPE record<event_outbox>;
DEFINE FIELD OVERWRITE target_module ON TABLE event_dead_letter TYPE string;
DEFINE FIELD OVERWRITE attempts ON TABLE event_dead_letter TYPE number;
DEFINE FIELD OVERWRITE last_error ON TABLE event_dead_letter TYPE string;
DEFINE FIELD OVERWRITE payload ON TABLE event_dead_letter TYPE object;
DEFINE FIELD OVERWRITE metadata ON TABLE event_dead_letter TYPE object;
DEFINE FIELD OVERWRITE exhausted_at ON TABLE event_dead_letter TYPE datetime DEFAULT time::now();
```

### 7.2 Mécanisme de Claim Atomique en SurrealQL

En remplacement de `FOR UPDATE SKIP LOCKED`, SurrealDB permet des transactions atomiques et des requêtes UPDATE conditionnelles :

```surql
-- Fonction SurrealQL : fn::event_claim_batch($params: object)
DEFINE FUNCTION OVERWRITE fn::event_claim_batch($params: object) {
    LET $limit = $params.limit DEFAULT 20;
    LET $lease_seconds = $params.lease_seconds DEFAULT 30;
    LET $now = time::now();
    LET $lease_until = time::now() + duration::from::secs($lease_seconds);

    -- 1. Récupération et verrouillage atomique des distributions prêtes
    LET $claimed = (
        UPDATE event_delivery
        SET status = "processing",
            locked_until = $lease_until,
            attempts = attempts + 1
        WHERE status = "pending"
           OR (status = "processing" AND locked_until < $now)
           OR (status = "failed" AND next_retry_at <= $now)
        LIMIT $limit
        RETURN AFTER
    );

    RETURN fn::result_ok($claimed);
};
```

---

## 8. Respect Strict des Frontières & de la Constitution Lyxal OS

Conformément à la Charte d'Architecture (`AGENTS.md` & `LYXAL_ARCHITECTURE.md`), le rôle de `lyxal_event` est strictement délimité :

```text
┌─────────────────────────────────────────────────────────────────────────┐
│                              LYXAL OS                                   │
├───────────────────┬─────────────────────────────────────────────────────┤
│ lyxal_runtime     │ Cycle de vie, migrations, initialisation, santé    │
├───────────────────┼─────────────────────────────────────────────────────┤
│ lyxal_event       │ Bus asynchrone, persistance outbox, fan-out, DLQ   │
├───────────────────┼─────────────────────────────────────────────────────┤
│ lyxal_scheduler   │ Tâches planifiées, cron, exécutions différées       │
├───────────────────┼─────────────────────────────────────────────────────┤
│ lyxal_notification│ Canaux de sortie (Email, SMS, Push, WhatsApp)       │
├───────────────────┼─────────────────────────────────────────────────────┤
│ lyxal_webhook     │ Dispatch HTTP sécurisé vers l'extérieur             │
└───────────────────┴─────────────────────────────────────────────────────┘
```

* **Zéro chevauchement avec `lyxal_scheduler`** : `lyxal_event` ne planifie pas d'événements récurrents dans le futur (pas de syntaxe cron).
* **Zéro émission directe vers l'extérieur** : `lyxal_event` ne fait aucun appel réseau externe (pas de HTTP, pas de SMTP, pas de RabbitMQ obligatoire). Il dispatche localement aux handlers des modules Lyxal enregistrés dans le même process ou sur la même instance.

---

## 9. Classification Complète du Code : REUSE / ADAPT / INSPIRE / REJECT

### 9.1 Repository `oxide-outbox`

| Fichier / Module | Classification | Justification Technique |
| :--- | :---: | :--- |
| `outbox-core/src/storage.rs` | **ADAPT** | La séparation des traits `OutboxWriter` (côté émetteur) et `OutboxStorage` (côté worker) est excellente. À adapter pour retourner `Result<T, LyxalSurrealError>` et consommer `Surreal<Any>`. |
| `outbox-core/src/gc.rs` | **ADAPT** | Le mécanisme de Garbage Collection en tâche de fond pour purger les événements livrés après rétention est simple, propre et directement transposable en SurrealQL (`fn::event_purge_garbage`). |
| `outbox-core/src/processor.rs` | **INSPIRE** | Le principe de boucle de traitement par batch est bon, mais son implémentation monomorphique `Event<PT>` doit être remplacée par un modèle dynamique. |
| `outbox-core/src/manager.rs` | **INSPIRE** | La gestion de l'écoute d'événements combinée au polling de secours est inspirante, mais doit utiliser les `LIVE QUERY` ou notifications SurrealDB plutôt que `PgListener`. |
| `outbox-core/src/dlq/` | **REJECT** | Le stockage du DLQ dans un `DlqHeap` externe (Redis/mémoire) est incompatible avec l'architecture centralisée sur SurrealDB. |
| `outbox-core/src/idempotency/` | **REJECT** | Réservation de jeton dépendante de Redis. L'idempotence Lyxal s'appuie sur la clé logique `(event_id, target_module)` dans SurrealDB. |
| `outbox-postgres/` | **REJECT** | Requêtes spécifiques SQLx / Postgres `FOR UPDATE SKIP LOCKED` non compatibles SurrealDB. |
| `outbox-redis/` | **REJECT** | Dépendance Redis rejetée pour le cœur de Lyxal OS. |
| `outbox-kafka/` | **REJECT** | Broker Kafka externe hors du périmètre interne Lyxal. |

### 9.2 Repository `hexeract`

| Fichier / Module | Classification | Justification Technique |
| :--- | :---: | :--- |
| `hexeract-outbox/src/worker.rs` (Calcul de bail & Backoff) | **REUSE** (Patterns & Algorithmes) | La formule de lease `batch_len * dispatch_timeout` et la fonction `next_retry_delay` avec saturation et **full-jitter** (`fastrand`) sont des gold standards à reprendre intégralement. |
| `hexeract-outbox/src/worker.rs` (`ErasedHandler` & `TypedHandler`) | **ADAPT** | Le pattern d'effacement de type pour stocker des handlers fortement typés `Handler<E>` dans une `HashMap<&'static str, Arc<dyn ErasedHandler>>` est parfait pour enregistrer les handlers des modules Lyxal. |
| `hexeract-core/src/context.rs` (`HandlerContext`) | **ADAPT** | Transporter `MessageId`, `CorrelationId`, `CancellationToken` et le contexte de sécurité/instance `tenant_id` dans un contexte d'exécution unique passé à chaque handler. |
| `hexeract-outbox/src/envelope.rs` | **ADAPT** | Modèle d'enveloppe propre contenant les métadonnées de tracing (`event_id`, `correlation_id`, `attempts`, `last_error`, `next_retry_at`). À enrichir des champs `tenant` et `producer`. |
| `hexeract-mediator/` | **INSPIRE** | La mécanique de fan-out `join_all` est intéressante pour l'exécution in-process, mais doit être reliée à la table de suivi persistant `event_delivery`. |
| `hexeract-outbox-sql/` | **REJECT** | Générateur SQL monolithique spécifique Postgres/MySQL/SQLite, inutile pour SurrealDB. |
| `hexeract-scheduler/` | **REJECT** | Redondant avec `lyxal_scheduler`. |
| `hexeract-bus/` & `hexeract-bus-rabbitmq/` | **REJECT** | Protocoles RPC request-reply et RabbitMQ hors du scope de `lyxal_event`. |
| `hexeract-cli/` | **REJECT** | Lyxal possède sa propre architecture CLI et console web unifiée. |

---

## 10. Architecture Cible Proposée pour `lyxal_event`

### 10.1 Modèle d'Enveloppe Canonique Lyxal (`LyxalEventEnvelope`)

```rust
use serde::{Deserialize, Serialize};
use surrealdb::{Datetime, RecordId};
use uuid::Uuid;

/// Enveloppe universelle d'un événement au sein de Lyxal OS.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LyxalEventEnvelope {
    /// Identifiant unique de l'événement (UUIDv7 ordonnable chronologiquement).
    pub event_id: Uuid,
    /// Type de l'événement (ex: "booking.created", "invoice.issued").
    pub event_type: String,
    /// Version du schéma de l'événement (ex: 1).
    pub version: u32,
    /// Module producteur émetteur (ex: "booking", "runtime").
    pub producer: String,
    /// Enregistrement source à l'origine de l'événement (ex: RecordId("booking", "abc123")).
    pub source: Option<RecordId>,
    /// Contexte d'instance et de multi-tenance (ex: "tenant_lyxal_fr").
    pub tenant: Option<String>,
    /// Identifiant de corrélation pour le traçage distribué.
    pub correlation_id: Uuid,
    /// Identifiant de causalité (événement parent ayant déclenché celui-ci).
    pub causation_id: Option<Uuid>,
    /// Données métier de l'événement au format JSON structuré.
    pub payload: serde_json::Value,
    /// Métadonnées transversales (acteur, IP, headers).
    pub metadata: serde_json::Value,
    /// Horodatage de création UTC.
    pub created_at: Datetime,
}
```

### 10.2 Workflow Complet : De la Mutation au Fan-Out

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│ 1. ÉMISSION                                                                 │
│                                                                             │
│   A. Via SurrealDB DEFINE EVENT          B. Via API Rust (EventPublisher)   │
│      CREATE booking CONTENT {...};          event_bus.publish(envelope)     │
│             │                                           │                   │
│             ▼                                           ▼                   │
│      DEFINE EVENT booking_created                fn::event_publish($params) │
│             │                                           │                   │
│             └─────────────────────┬─────────────────────┘                   │
│                                   ▼                                         │
│                      INSERT INTO event_outbox                               │
└───────────────────────────────────┬─────────────────────────────────────────┘
                                    │
┌───────────────────────────────────▼─────────────────────────────────────────┐
│ 2. FAN-OUT (Éclatement automatique vers les abonnés)                        │
│                                                                             │
│   SurrealQL Function : fn::event_fanout_outbox()                            │
│   Pour chaque abonné actif dans event_subscription correspondant :          │
│                                                                             │
│          event_outbox ("booking.created")                                   │
│                 │                                                           │
│                 ├──> event_delivery (target: "lyxal_notification")          │
│                 ├──> event_delivery (target: "lyxal_scheduler")             │
│                 ├──> event_delivery (target: "lyxal_crm")                   │
│                 └──> event_delivery (target: "lyxal_webhook")               │
└───────────────────────────────────┬─────────────────────────────────────────┘
                                    │
┌───────────────────────────────────▼─────────────────────────────────────────┐
│ 3. WORKER RUNTIME (Moteur Rust asynchrone)                                  │
│                                                                             │
│   OutboxWorker Loop (Tokio Task)                                            │
│   1. Claim atomique par lot via fn::event_claim_batch(limit, lease)         │
│   2. Pour chaque event_delivery réclamé :                                   │
│      - Recherche du Handler dans le HandlerRegistry (ErasedHandler)         │
│      - Création du HandlerContext (CorrelationId + CancellationToken)       │
│      - Exécution avec tokio::time::timeout(dispatch_timeout, handler)       │
│      - Si SUCCÈS : fn::event_delivery_success(delivery_id)                  │
│      - Si ÉCHEC  : fn::event_delivery_failure(delivery_id, error, backoff)  │
│                    (Si attempts >= max_attempts -> event_dead_letter)      │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 11. Analyse des Licences & Conformité Légale

* **`oxide-outbox`** : Sous licence **MIT standard** (Dennis S. Dale, 2026). Permet l'utilisation commerciale, la modification, la distribution et l'adaptation du code sous réserve de conserver la notice de copyright.
* **`hexeract`** : Sous double licence **MIT / Apache-2.0** (Nubster, 2026). Parfaitement compatible avec l'écosystème open source et propriétaire de Lyxal OS.
* **Obligation** : Mentionner les crédits d'inspiration / attribution dans le fichier `THIRD_PARTY_LICENSES.md` ou en en-tête des algorithmes adaptés (ex: calcul du jitter / lease sizing).

---

## 12. Matrice d'Évaluation Finale

| Dimension Technique | Oxide Outbox | Hexeract | Conception Native Lyxal |
| :--- | :---: | :---: | :---: |
| **Qualité du code Rust** | 🟢 Bon (propre, simple) | 🟢 Excellent (très avancé) | 🟢 Gold Standard Lyxal |
| **Gestion de la concurrence & baux** | 🟡 Basique (verrou fixe) | 🟢 Excellent (scaled lease) | 🟢 Idem Hexeract + SurrealQL |
| **Résilience (Retry / Jitter)** | 🔴 Faible (pas de jitter) | 🟢 Excellent (Full Jitter) | 🟢 Idem Hexeract |
| **Gestion DLQ** | 🔴 Inadaptée (Redis/Heap) | 🟢 Bonne (Table SQL) | 🟢 Table `event_dead_letter` |
| **Fan-Out Multi-Modules** | 🔴 Inexistant | 🔴 Non persistant | 🟢 100% Natif (`event_delivery`) |
| **Compatibilité SurrealDB** | 🔴 Nécessite réécriture | 🔴 Nécessite réécriture | 🟢 100% Natif (`Surreal<Any>`) |
| **Respect de la Charte Lyxal** | 🟡 Partiel | 🔴 Trop invasif | 🟢 100% Conforme |
| **Indépendance vis-à-vis de brokers** | 🔴 Dépend de Kafka | 🟡 Dépend de RabbitMQ | 🟢 Zéro broker requis |

---

## 13. Décision Finale & Recommandation Formelle

### 🎯 Décision : Option E — Crate Natif `lyxal_event` Hybride & 100% Adapté à SurrealDB

Nous recommandons formellement de **ne pas forker tels quels Oxide ou Hexeract**, mais de créer **un crate natif `crates/lyxal_event`** qui synthétise le meilleur des deux projets tout en étant bâti dès le premier jour sur le moteur SurrealDB :

1. **Ce que nous reprenons d'Hexeract (Code & Algorithmes adaptés)** :
   * La formule de calcul du bail dynamique : `lease_duration = batch_size * dispatch_timeout`.
   * L'algorithme de backoff exponentiel avec **Full Jitter** (`fastrand`) et saturation.
   * L'architecture du registre de handlers typés (`Handler<E>`, `TypedHandler`, `ErasedHandler`).
   * La gestion du cycle de vie du worker via `tokio_util::sync::CancellationToken` et `HandlerContext`.
   * La politique de timeout strict par handler avec déclenchement d'un token enfant.
2. **Ce que nous reprenons d'Oxide (Patterns d'architecture)** :
   * La séparation stricte des interfaces `EventPublisher` (côté écriture) et `EventWorker` (côté traitement).
   * La tâche asynchrone dédiée `GarbageCollector` pour le nettoyage périodique des événements archivés.
3. **Ce que nous écrivons spécifiquement pour Lyxal OS & SurrealDB** :
   * L'ensemble des schémas et fonctions SurrealQL (`fn::event_publish`, `fn::event_fanout`, `fn::event_claim_batch`, `fn::event_delivery_success`, `fn::event_delivery_failure`, `fn::event_purge_garbage`).
   * La persistance du Fan-Out relationnel unitaire (`event_outbox` -> `event_delivery: [module_notification, module_scheduler, module_crm]`).
   * Le wrapper Rust 1-ligne conforme au contrat `LyxalSurrealCall` et aux types `LyxalResult<T>`.
   * L'isolation multi-tenant stricte via le champ `tenant` de l'enveloppe.

---

## 14. Question Finale : Réponse au CTO

> **Question** : *Si nous devions commencer l'implémentation de `lyxal_event` aujourd'hui, quelle base de code choisirions-nous, quelles parties exactes réutiliserions-nous, et quelle architecture créerions-nous autour de SurrealDB ?*

### Réponse Synthétique & Stratégie d'Action Immédiate :

1. **Base de code choisie** :
   * Création d'un crate natif **`crates/lyxal_event`** dans le workspace Lyxal OS.
2. **Parties exactes réutilisées et adaptées** :
   * De **Hexeract** : La logique du worker (`hexeract-outbox/src/worker.rs`), le registre de handlers (`TypedHandler` / `ErasedHandler`), le calcul de retry avec jitter (`next_retry_delay`), et le contexte d'exécution (`HandlerContext`).
   * D'**Oxide** : La logique du garbage collector (`outbox-core/src/gc.rs`) et la séparation nette des traits producteur/consommateur.
3. **Architecture SurrealDB déployée** :
   * Les 4 tables maîtresses : `event_outbox`, `event_subscription`, `event_delivery`, `event_dead_letter`.
   * Des fonctions SurrealQL transactionnelles pour l'insertion, le fan-out, le claim par lot et l'acquittement.
   * Un worker Tokio autonome capable d'exécuter les handlers des modules abonnés sans jamais introduire de couplage direct entre les producteurs et les consommateurs.

---

## 15. Prochaines Étapes : Plan d'Implémentation Futur

Une fois ce rapport validé par le CTO, la mission de développement de `lyxal_event` pourra démarrer selon les étapes suivantes :
1. **Étape 1 (SurrealQL & Schémas)** : Création des tables `schema/` et des fonctions métier `functions/` (`fn::event_*`).
2. **Étape 2 (Types de Domaine & Modèle d'Enveloppe)** : Implémentation dans `src/models/` de `LyxalEventEnvelope`, `EventDelivery`, `Subscription`.
3. **Étape 3 (Registre de Handlers & HandlerContext)** : Implémentation de `Handler<E>`, `TypedHandler`, `ErasedHandler`, `HandlerContext`.
4. **Étape 4 (Worker & Engine de Traitement)** : Implémentation de `EventWorker`, `EventPublisher`, boucle de claim et settling avec backoff/jitter.
5. **Étape 5 (Master Data d'Erreurs)** : Définition des codes `EVENT_*` dans `error/` conformes à `lyxal_error`.
6. **Étape 6 (Tests d'Intégration & Validation)** : Validation complète sous SurrealDB mémoire (`mem://`) et WebSocket (`ws://`).
