# 🗄️ Référence Technique SurrealQL (SurrealDB 3.2.0) — `lyxal_event`

## 1. Tables Déclaratives

### 1.1. `event_outbox`
Stocke chaque événement publié au sein d'une transaction métier.
* `id` : Record ID déterministe ou auto-généré.
* `event_id` : UUID v7 unique de l'événement.
* `event_type` : Type d'événement (ex: `"booking.created"`).
* `version` : Version du schéma d'événement (entier positif).
* `producer` : Module propriétaire émetteur (ex: `"lyxal_booking"`).
* `context` : Objet d'isolation (`tenant_id`, `instance_id`, `environment`).
* `correlation_id` / `causation_id` : Traçabilité distribuée.
* `payload` : Objet JSON contenant la donnée d'événement.
* `metadata` : Données de transport et contexte technique.
* `status` : `"pending"`, `"fanned_out"`, `"processed"`, `"failed"`.
* `created_at` / `processed_at` : Horodatages UTC.

### 1.2. `event_subscription`
Enregistre les souscriptions de modules consommateurs.
* `name` : Nom unique de la souscription (ex: `"notification_booking_created"`).
* `target_module` : Module consommateur cible (ex: `"lyxal_notification"`).
* `event_pattern` : Pattern de matching (supporte l'égalité exacte, `*` ou les wildcards `prefix.*`).
* `handler_name` : Identifiant du handler récepteur.
* `max_attempts` : Nombre maximal de tentatives (défaut : 5).
* `is_active` : Activation logique de l'abonnement.

### 1.3. `event_delivery`
Matérialise chaque livraison individuelle résultant du fan-out vers un abonnement.
* `outbox_event` : Record link vers `event_outbox`.
* `subscription` : Record link vers `event_subscription`.
* `delivery_seq` : Séquence contiguë sans trou attribuée lors de l'injection streaming.
* `status` : `"pending"`, `"processing"`, `"delivered"`, `"failed"`, `"dead_letter"`, `"dropped"`.
* `attempts` : Compteur de tentatives d'exécution.
* `locked_until` : Échéance du verrou de traitement leader.
* `lease_owner` : Nœud détenant le verrou de traitement.
* `next_retry_at` : Instant minimal pour la prochaine réexpédition.

### 1.4. `event_stream_lease`
Verrou distribué de leadership streaming (Singleton `event_stream_lease:outbox_leader`).
* `owner_node_id` : Identifiant de l'instance leader active.
* `generation` : Compteur strictement monotone de leadership.
* `acquired_at` / `expires_at` : Durée de validité du bail.
* `last_flushed_at` : Horodatage de la dernière écriture transactionnelle.
* `is_released` : Indicateur de libération coopérative (reprise Zero-Wait).

### 1.5. `event_subscription_progress`
Curseur de progression ordonnée par abonnement (`event_subscription_progress:prog_<sub_id>`).
* `subscription` : Record link vers `event_subscription`.
* `last_assigned_seq` : Dernière séquence attribuée de façon monotone.
* `last_persisted_cursor` : Curseur continu sécurisé et confirmé sans aucun trou.
* `updated_at` : Horodatage de dernier avancement.

### 1.6. `event_dead_letter`
Quarantaine pour les messages ayant épuisé leur quota d'essais.
* `delivery` : Record link vers `event_delivery`.
* `outbox_event` : Record link vers `event_outbox`.
* `target_module` : Module cible.
* `last_error` : Motif technique du dernier échec.
* `exhausted_at` : Horodatage d'entrée en quarantaine.
* `replayed` : Booléen marquant le rejeu ultérieur.

---

## 2. Fonctions Métier

### `fn::event_publish($params: object)`
Publie un événement dans `event_outbox` et déclenche immédiatement `fn::event_fanout`.
```surql
LET $res = fn::event_publish({
    event_id: rand::uuid::v7(),
    event_type: "booking.created",
    producer: "lyxal_booking",
    payload: { booking_id: "book_1" },
    metadata: {}
});
```

### `fn::event_delivery_assign_seq($params: object)`
Attribue une séquence contiguë sous protection de fencing :
* **Paramètres obligatoires** : `outbox_event`, `subscription`, `node_id`, `generation`.
* **Idempotence** : Si la livraison possède déjà un `delivery_seq` (reprise après incident), elle est reverrouillée pour le leader actif sans modifier sa séquence ni le compteur de progression.

### `fn::event_flush_batch($params: object)`
Applique les statuts terminaux (`delivered_ids`, `dead_letter_ids`, `dropped_ids`) et avance le curseur persistant :
* **Vérification d'invariant** : Vérifie qu'aucune séquence non résolue ne subsiste entre `last_persisted_cursor` et `target_cursor`.
* **Garde Fencing** : Échoue avec `EVENT_STALE_LEADER_FENCED` si le bail ou la génération ne correspondent plus.

### `fn::event_dead_letter_transfer($params: object)`
Transfère de manière transactionnelle un message poison dans `event_dead_letter` sous garde de bail avant que le curseur ne soit avancé.

### `fn::event_dead_letter_replay($params: object)`
Réarme une livraison en quarantaine en restaurant son statut à `pending` et en réinitialisant son compteur de tentatives pour une réexécution immédiate.

