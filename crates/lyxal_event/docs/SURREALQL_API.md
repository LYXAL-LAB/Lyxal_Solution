# Référence SurrealQL — `lyxal_event`

Cible : SurrealDB 3.3.4. Les ressources sont installées dans l'ordre de `manifest.toml`
(`EventStore::install`).

---

## 1. Tables

Les six tables sont en `TYPE NORMAL SCHEMAFULL PERMISSIONS NONE` : seules les fonctions du
module, exécutées côté serveur, y accèdent.

### `event_outbox` — événements publiés

| Champ | Type | Rôle |
| :--- | :--- | :--- |
| `event_id` | `string` (UUID v7) | Identifiant unique de l'événement (index unique). |
| `event_type` | `string` | Type, ex. `booking.created`. |
| `version` | `number` | Version du schéma de l'événement (≥ 1). |
| `producer` | `string` | Module émetteur, ex. `lyxal_booking`. |
| `source` | `option<record>` | Enregistrement à l'origine de l'événement. |
| `context` | `object` | `instance_id`, `namespace`, `database`. |
| `correlation_id`, `causation_id` | `string`, `option<string>` | Traçabilité. |
| `payload`, `metadata` | `object` | Données métier et métadonnées. |
| `status` | `string` | `pending` puis `fanned_out`. |
| `created_at`, `fanned_out_at` | `datetime` | Horodatages. |

### `event_subscription` — abonnements

| Champ | Type | Rôle |
| :--- | :--- | :--- |
| `name` | `string` | Nom unique. |
| `target_module` | `string` | Module consommateur. |
| `event_pattern` | `string` | Type exact, `prefixe.*` ou `*`. |
| `handler_name` | `string` | Nom du handler. |
| `max_attempts` | `number` | Budget d'essais d'une livraison avant dead letter (1 à 100, défaut 5). |
| `is_active` | `bool` | Un abonnement inactif ne reçoit plus de livraison au fan-out. |

### `event_delivery` — une livraison par couple (événement, abonnement)

| Champ | Type | Rôle |
| :--- | :--- | :--- |
| `outbox_event`, `subscription` | `record` | Couple unique (index `idx_delivery_unique_fanout`). |
| `target_module`, `context` | `string`, `object` | Repris de l'abonnement et de l'événement. |
| `status` | `string` | `pending`, `processing`, `failed` (retry programmé), `delivered`, `dead_letter`, `dropped`. |
| `delivery_seq` | `option<int>` | Séquence dans le flux de l'abonnement, attribuée au premier séquencement, conservée aux reprises. |
| `attempts` | `number` | Nombre de séquencements (premier envoi et reprises après expiration du verrou). |
| `locked_until`, `lease_owner` | `option` | Verrou du leader qui traite la livraison (30 s par défaut). |
| `next_retry_at` | `datetime` | Date à partir de laquelle la livraison peut être reprise. |
| `last_error` | `option<string>` | Dernier échec. |
| `delivered_at`, `dropped_at`, `drop_reason`, `dead_letter_ref` | `option` | Résolution. |

### `event_subscription_progress` — curseur par abonnement

Enregistrement `event_subscription_progress:prog_<id de l'abonnement>`.

| Champ | Rôle |
| :--- | :--- |
| `last_assigned_seq` | Dernière séquence attribuée. |
| `last_persisted_cursor` | Plus grande séquence telle que toutes les séquences jusqu'à elle sont résolues (`delivered`, `dead_letter`, `dropped`). |
| `partition`, `updated_at` | Partition (toujours 0) et dernier avancement. |

### `event_stream_lease` — bail du leader

Enregistrement unique `event_stream_lease:outbox_leader` : `owner_node_id`, `generation`
(croît à chaque prise de bail), `acquired_at`, `expires_at`, `last_flushed_at`, `is_released`.

### `event_dead_letter` — quarantaine

`delivery`, `outbox_event`, `subscription`, `target_module`, `context`, `attempts`,
`last_error` (4 000 caractères au plus), `payload`, `metadata`, `exhausted_at`, `replayed`,
`replayed_at`.

---

## 2. Fonctions

Toutes prennent un objet unique `$params`, acceptent `language` (défaut `fr`), renvoient
`{ ok, data, error }` et déclarent `PERMISSIONS FULL`. Une entrée invalide renvoie
`EVENT_INVALID_PARAMETERS` avec le détail par champ dans `error.details.fields`.

La validation des entrées suit la décision CTO de la reprise :

* **fonctions appelées par les modules** : moteur `fn::validation_object_execute` de
  `lyxal_core`, champs inconnus refusés ;
* **fonctions internes du moteur**, appelées à chaque livraison : primitives de `lyxal_core`
  (`fn::validation_record_id`, `fn::validation_integer`, etc.), le moteur d'objet coûtant
  environ 23 ms par appel.

### 2.1. Fonctions appelées par les modules

| Fonction | Paramètres (requis en gras) | Donnée renvoyée |
| :--- | :--- | :--- |
| `fn::event_publish` | **event_id** (UUID), **event_type**, **producer**, version (défaut 1), source, context, correlation_id, causation_id, payload, metadata, auto_fanout (défaut `true`) | événement créé |
| `fn::event_subscription_register` | **name**, **target_module**, **event_pattern**, **handler_name**, is_active (défaut `true`), max_attempts (1 à 100, défaut 5) | abonnement (créé, ou mis à jour s'il existe sous ce nom) |
| `fn::event_outbox_get` | **id** (`record<event_outbox>`) | événement ou `NONE` |
| `fn::event_delivery_get` | **id** (`record<event_delivery>`) | livraison ou `NONE` |
| `fn::event_dead_letter_list` | limit (1 à 1 000, défaut 100), delivery | dead letters |
| `fn::event_dead_letter_replay` | **dead_letter_id** | `true`, ou `false` si la dead letter n'existe pas |
| `fn::event_purge_garbage` | **retention_days** (1 à 3 650) | `true` |

`fn::event_dead_letter_replay` remet la livraison en `pending` **sans séquence** : elle en
reçoit une nouvelle en fin de flux. Le rejeu est refusé (`EVENT_DEAD_LETTER_REPLAY_NOT_SETTLED`)
tant que le curseur persisté ne couvre pas l'ancienne séquence, sans quoi la séquence libérée
laisserait un trou.

`fn::event_purge_garbage` supprime les livraisons `delivered` et les événements `fanned_out`
plus anciens que la rétention. Un événement dont une livraison n'est pas livrée (en attente,
en retry ou en dead letter rejouable) est conservé.

### 2.2. Fonctions internes du moteur

Appelées par `EventWorker` et ses composants, jamais par un module.

| Fonction | Paramètres | Rôle |
| :--- | :--- | :--- |
| `fn::event_fanout` | **outbox_id** | Crée les livraisons des abonnements actifs correspondants (idempotent) et passe l'événement en `fanned_out`. |
| `fn::event_recover_pending_fanouts` | limit | Ventile les événements restés `pending`. Renvoie `{ recovered_count }`. |
| `fn::event_delivery_fetch_pending` | **limit**, instance_id, subscription | Livraisons éligibles (non résolues, verrou expiré, retry échu), avec l'événement d'origine et `max_attempts` de l'abonnement. |
| `fn::event_delivery_assign_seq` | **outbox_event**, **subscription**, **target_module**, **node_id**, **generation**, **context**, lock_seconds (défaut 30) | Sous garde de bail : attribue la séquence suivante, ou reverrouille une livraison qui en a déjà une sans la changer. |
| `fn::event_delivery_failure` | **delivery_id**, **error**, retry_delay_seconds | Enregistre un échec transitoire (`failed`, `last_error`, `next_retry_at`). Ne libère pas le verrou et ne décide jamais d'une dead letter. |
| `fn::event_dead_letter_transfer` | **delivery_id**, **error**, **node_id**, **generation** | Sous garde de bail : crée la dead letter et passe la livraison en `dead_letter` (barrière DLQ). |
| `fn::event_flush_batch` | **subscription**, **target_cursor**, **node_id**, **generation**, delivered_ids, dead_letter_ids, dropped_ids, drop_reason | Sous garde de bail : applique les résolutions et avance le curseur après contrôle de contiguïté. |
| `fn::event_progress_get` | **subscription** | `{ last_assigned_seq, last_persisted_cursor, exists, … }` |
| `fn::event_lease_acquire` | **node_id**, **ttl_seconds** | `{ acquired, generation, owner_node_id, expires_at }` |
| `fn::event_lease_renew` | **node_id**, **generation**, **ttl_seconds** | `{ renewed, generation, expires_at }` |
| `fn::event_lease_release` | **node_id**, **generation** | `{ released }` |

### 2.3. Erreurs levées par `THROW`

Les trois fonctions protégées par le bail (`event_delivery_assign_seq`,
`event_dead_letter_transfer`, `event_flush_batch`) écrivent d'abord sur le bail pour se
protéger. Un échec ultérieur doit annuler toute la transaction : il est donc levé par `THROW`,
exception documentée au contrat `fn::error_result` (décision CTO Q2). Côté Rust, ces codes sont
reconnus en un seul endroit (`src/error.rs`) et deviennent `LyxalEventError::StaleLeaderFenced`
ou une erreur d'invariant de curseur.

---

## 3. Codes d'erreur (`error/events.surql`)

| Code | Catégorie | HTTP | Émis par |
| :--- | :--- | :--- | :--- |
| `EVENT_INVALID_PARAMETERS` | `validation` | 400 | toutes les fonctions (`details.fields`) |
| `EVENT_DELIVERY_NOT_FOUND` | `not_found` | 404 | `event_delivery_failure`, `event_dead_letter_replay`, `event_dead_letter_transfer` (`THROW`) |
| `EVENT_DEAD_LETTER_REPLAY_NOT_SETTLED` | `conflict` | 409 | `event_dead_letter_replay` (réessayable) |
| `EVENT_STALE_LEADER_FENCED` | `conflict` | 412 | fonctions protégées par le bail (`THROW`) |
| `EVENT_CURSOR_NON_MONOTONIC` | `validation` | 422 | `event_flush_batch` (`THROW`) |
| `EVENT_CURSOR_EXCEEDS_ASSIGNED_SEQ` | `validation` | 422 | `event_flush_batch` (`THROW`) |
| `EVENT_CURSOR_INVARIANT_VIOLATION_UNRESOLVED_SEQUENCES` | `validation` | 422 | `event_flush_batch` (`THROW`) |
| `EVENT_CURSOR_MISSING_SEQUENCE_HOLE` | `validation` | 422 | `event_flush_batch` (`THROW`) |
