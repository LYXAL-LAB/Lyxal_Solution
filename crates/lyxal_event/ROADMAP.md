# 🗺️ Roadmap Officielle — `lyxal_event`

> **Module** : `lyxal_event`  
> **Responsabilité** : Moteur d'événements asynchrone, Transactional Outbox, Fan-out, Distribution & DLQ pour Lyxal OS.  
> **Méthodologie** : Constitution Lyxal OS en 3 Phases (V1 Fonctionnel ──► V2 Observabilité ──► V3 IA & Alerting).

---

## 📊 Synthèse des Phases

```text
┌──────────────────────────────────────────────┐
│           PHASE 1 — V1 FONCTIONNEL           │
│   Transactional Outbox, Fan-out, Workers,    │ ──► [✅ TERMINÉ & INTÉGRÉ]
│      Retries, DLQ, Recovery, Runtime         │
└──────────────────────┬───────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────┐
│          PHASE 2 — V2 OBSERVABILITÉ          │
│    Métriques temps réel, Dashboard UI,       │ ──► [📅 PLANIFIÉ]
│        CLI Dead Letter, Replay batch         │
└──────────────────────┬───────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────┐
│           PHASE 3 — V3 IA & AVANCÉ           │
│   Diagnostic d'erreur IA, Auto-Healing,      │ ──► [📅 PLANIFIÉ]
│        Auto-tuning dynamique des baux        │
└──────────────────────────────────────────────┘
```

---

## 🟢 Phase 1 : V1 — Socle Fonctionnel & Transactional Outbox (Terminé)

L'ensemble des objectifs de la Phase 1 a été atteint et validé par une suite complète de tests unitaires, d'intégration et de concurrence (1 000 livraisons sous 10 workers concurrents).

### Réalisations Majeures
- [x] **Transactional Outbox SurrealDB 2.x** :
  - Publication via Rust (`EventPublisher`).
  - Déclencheurs natifs SurrealQL (`DEFINE EVENT`).
  - Identifiants UUID v7 chronologiques et déterministes.
- [x] **Fan-out Idempotent** :
  - Identité stricte : `UNIQUE(outbox_event, subscription)`.
  - Support des motifs wildcard (`booking.created`, `booking.*`, `*`).
- [x] **Moteur d'Exécution & Workers (`EventWorker`)** :
  - Claim atomique CAS sans lock pessimiste (`fn::event_claim_batch`).
  - Scaling dynamique de la durée de bail en fonction de la taille du lot.
  - Résilience aux conflits MVCC avec boucle de retry et Full Jitter.
- [x] **Résilience & Gestion des Pannes** :
  - Backoff exponentiel borné avec Full Jitter.
  - Bascule automatique en Dead Letter Queue (`event_dead_letter`) après épuisement des tentatives.
  - Procédure de réessai (`fn::event_dead_letter_replay`).
  - Reprise automatique des fan-outs interrompus par un crash (`fn::event_recover_pending_fanouts`).
- [x] **Garbage Collector (`GarbageCollector`)** :
  - Purge déterministe et configurable des livraisons et outboxes archivés (`fn::event_purge_garbage`).
- [x] **Isolation Multi-Instance & Multi-Tenant** :
  - Routage étanche par `EventContext` (`instance_id`, `namespace`, `database`).
- [x] **Intégration Complète `lyxal_runtime`** :
  - Implémentation du trait officiel `LyxalWorker` pour `EventWorker` et `GarbageCollector`.
  - Supervision active par `WorkerSupervisor` (cycle de vie, annulation coopérative `CancellationToken`, politique de restart).

---

## 🟡 Phase 2 : V2 — Observabilité, Métriques & Console Dead Letter (Planifié)

L'objectif de la Phase 2 est d'apporter une observabilité complète et des outils opérationnels pour superviser le flux d'événements en production.

### 1. Métriques & Statistiques (`event_statistics`)
- [ ] **Table SurrealDB `event_statistics`** :
  - Agrégation par minute/heure/jour du volume d'événements publiés, livrés, échoués et envoyés en DLQ.
  - Suivi de la latence médiane et p99 entre publication outbox et livraison effective.
- [ ] **Export OpenTelemetry / Prometheus** :
  - Export de métriques standardisées (`lyxal_events_published_total`, `lyxal_events_delivered_total`, `lyxal_events_dlq_total`, `lyxal_event_delivery_duration_seconds`).

### 2. Console d'Administration & CLI Dead Letter
- [ ] **Commandes CLI d'exploitation (`lyxal-cli event`)** :
  - `lyxal event dlq list [--event-type <pattern>] [--module <name>]` : Lister les messages en échec terminal.
  - `lyxal event dlq inspect <dead-letter-id>` : Inspecter le payload, les métadonnées et la trace d'erreur exacte.
  - `lyxal event dlq replay <dead-letter-id>` : Rejouer unitairement un événement corrigé.
  - `lyxal event dlq replay-all [--event-type <pattern>]` : Rejouer un lot d'événements après résolution d'un bug applicatif.
  - `lyxal event stats` : Afficher le débit et l'état des files en direct.
- [ ] **Intégration Console Web Lyxal OS** :
  - Visualisation en direct des flux d'événements inter-modules.
  - Interface graphique pour visualiser la file d'attente DLQ et déclencher des replays en 1 clic.

### 3. Alerting & Détection d'Engorgement
- [ ] **Alertes sur file d'attente anormale** :
  - Notification automatique si le nombre d'outboxes `pending` dépasse un seuil critique pendant plus de $X$ minutes.
  - Alerte immédiate dès l'apparition d'un nouvel événement en Dead Letter Queue.

---

## 🟣 Phase 3 : V3 — Événementiel Avancé, Diagnostic IA & Auto-Healing (Planifié)

L'objectif de la Phase 3 est d'automatiser le diagnostic des anomalies et d'optimiser dynamiquement les performances du moteur.

### 1. Diagnostic Automatique des Erreurs DLQ par IA
- [ ] **Analyse sémantique des traces d'erreurs** :
  - Détection automatique de la cause racine d'un échec (ex: schéma incompatible, timeout réseau, corruption de données).
  - Proposition de correction ou de patch de schéma automatisé.

### 2. Auto-Tuning Dynamique
- [ ] **Régulation adaptative du polling et du batching** :
  - Ajustement automatique de `batch_size` et `poll_interval` selon la charge instantanée du système.
  - Scaling adaptatif de la durée des baux en fonction de la charge CPU/DB mesurée.

### 3. Détection de Régression sur les Handlers
- [ ] **Monitoring continu des temps d'exécution** :
  - Identification préventive des handlers devenant lents ou sujets à des fuites de mémoire.

---

## 🛠️ Outillage & Ergonomie Développeur (Transversal)

- [ ] **Macro Derive `#[derive(Event)]`** :
  - Implémentation dans `lyxal_macros` pour dériver automatiquement `const EVENT_TYPE: &'static str` à partir du nom ou d'un attribut de la structure Rust.
- [ ] **Générateur de Handlers (`lyxal-cli generate handler`)** :
  - Création rapide de squelettes de handlers typés et d'enregistrements de subscriptions pour les nouveaux modules.

---

## 📌 Règle de Non-Rupture d'API

Toute évolution des Phases 2 et 3 respectera le principe fondamental de Lyxal OS :
- **Rétrocompatibilité totale** des contrats publics (`Event`, `Handler<E>`, `EventPublisher`, `EventStore`).
- **Évolution non-bloquante** des schémas SurrealQL (`schema/` $\rightarrow$ `migration/` $\rightarrow$ `runtime`).
