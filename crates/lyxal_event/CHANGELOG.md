# Changelog — `lyxal_event`

Toutes les modifications notables apportées à ce module sont documentées dans ce fichier.
Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/) et ce projet adhère à [Semantic Versioning](https://semver.org/lang/fr/).

---

## [1.0.0] - 2026-10-31

### Ajouté
* **Architecture Streaming In-Process & Transactional Outbox Unifiée** :
  * Fusion de la persistance Outbox SurrealDB avec le moteur de distribution in-process haute résilience.
  * `ReliableDispatcher` : distribution round-robin, fenêtre de glissement contiguë sans trou (`DispatchWindow`), gestion unifiée de backpressure.
  * Machine à états de livraisons `PendingDelivery` avec politiques de retry configurables (exponentiel, full jitter, bornes maximales).
  * `PoisonHandler` : barrière transactionnelle DLQ (`DeadLetter`) et politique d'abandon (`Drop`).
  * `HandlerConsumerBridge` : exécution supervisée de handlers asynchrones Rust avec isolation des paniques, timeouts et gestion ACK/NACK.
* **Persistance & Fencing Transactionnel SurrealDB 3.2.0** :
  * Tables `event_stream_lease` et `event_subscription_progress`.
  * `fn::event_lease_acquire`, `fn::event_lease_renew`, `fn::event_lease_release` avec protection par génération monotone.
  * `fn::event_delivery_assign_seq` : attribution atomique de séquence contiguë et verrouillage de livraison sous garde de fencing.
  * `fn::event_flush_batch` : application granulaire des statuts terminaux (`delivered`, `dead_letter`, `dropped`) et avancement persistant du curseur sûr sous vérification de contiguïté stricte.
  * `fn::event_dead_letter_transfer` et `fn::event_dead_letter_replay`.
* **Résilience Post-Crash (ANO-01)** :
  * Reprise automatique et sans saut des livraisons en cours après interruption brutale de processus ou redémarrage serveur (`fetch_and_enqueue_pending`).
  * Protection contre les boucles de ré-enfilage infini via mise à jour transactionnelle des verrous `locked_until`.
* **Traitement Robuste des NACK (ANO-02)** :
  * Suppression des masquages silencieux d'erreurs d'écriture.
  * Raccordement canonique à `fn::event_delivery_failure` avec incrément systématique de `attempts`.
* **Contrats & Supervision Runtime Lyxal OS** :
  * Manifeste canonique `manifest.toml` (`manifest_version = 1`, `capabilities = ["event", "outbox", "event_stream"]`).
  * Adaptateur officiel `EventWorkerService` pour `lyxal_runtime` sous contrat `LyxalWorker` et coopération avec `CancellationToken`.
  * Trait d'extension découplé `EventConsumerModule` pour l'enregistrement des handlers par les modules consommateurs.

### Corrigé
* Élimination des conflits d'index non partiels `UNIQUE` sur SurrealDB 3.2.0 pour les champs contenant `NONE`.
* Purge intégrale de la nomenclature obsolète « Danube » dans l'ensemble des modules Rust, docstrings et codes d'erreur.

### Sécurité
* Invariant de contiguïté vérifié au niveau base de données (interdiction d'avancer le curseur si des séquences antérieures ne sont pas résolues).
* Exclusion mutuelle stricte des leaders par détection MVCC des conflits d'écriture sur le bail distribué.

