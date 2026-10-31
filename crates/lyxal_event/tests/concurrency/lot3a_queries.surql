-- ==============================================================================
-- LYXAL OS — REQUÊTES TRANSACTIONNELLES VALIDÉES LOT 3A SURREALDB 3.2.0
-- Ce fichier regroupe les motifs de requêtes SurrealQL 3.2.0 rigoureusement
-- testés et validés expérimentalement lors du banc Lot 3A pour l'intégration Lot 3B.
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. SCHÉMA DE RÉFÉRENCE LOT 3A / 3B
-- ------------------------------------------------------------------------------
DEFINE TABLE IF NOT EXISTS event_stream_lease SCHEMALESS;
DEFINE TABLE IF NOT EXISTS event_subscription_progress SCHEMALESS;
DEFINE TABLE IF NOT EXISTS event_delivery SCHEMALESS;
DEFINE TABLE IF NOT EXISTS event_dead_letter SCHEMALESS;

DEFINE INDEX IF NOT EXISTS idx_del_event_sub ON TABLE event_delivery FIELDS outbox_event, subscription UNIQUE;
DEFINE INDEX IF NOT EXISTS idx_del_seq_sub ON TABLE event_delivery FIELDS subscription, delivery_seq UNIQUE;

-- ------------------------------------------------------------------------------
-- 2. GARDE TRANSACTIONNELLE DE FENCING (ÉCRITURE CONDITIONNELLE SUR LE BAIL)
-- Protège contre l'anomalie de Write Skew / Snapshot Isolation de SurrealDB.
-- Si un leader concurrent a incrémenté la génération ou pris le bail,
-- l'UPDATE échoue (0 ligne affectée) ou provoque un conflit d'écriture MVCC.
-- ------------------------------------------------------------------------------
-- Entrée : $my_gen (int), $my_node_id (string)
BEGIN TRANSACTION;

LET $guard = (
    UPDATE event_stream_lease:outbox_leader
    SET last_flushed_at = time::now()
    WHERE id = event_stream_lease:outbox_leader
      AND generation = $my_gen
      AND owner_node_id = $my_node_id
    RETURN AFTER
);

IF array::is_empty($guard) THEN
    THROW "STALE_LEADER_FENCED_ACTIVE_LEASE_CHANGED";
END;

-- ... Mutations métier protégées ...

COMMIT TRANSACTION;

-- ------------------------------------------------------------------------------
-- 3. ATTRIBUTION ATOMIQUE DE SÉQUENCE CONTIGUË (OUTBOX FEEDER)
-- Garantit l'absence totale de trous en cas de crash avant commit.
-- ------------------------------------------------------------------------------
-- Entrée : $sub_id (string), $event_id (string), $my_gen (int), $my_node_id (string)
BEGIN TRANSACTION;

-- 3.1 Garde de Fencing
LET $guard = (
    UPDATE event_stream_lease:outbox_leader
    SET last_flushed_at = time::now()
    WHERE id = event_stream_lease:outbox_leader
      AND generation = $my_gen
      AND owner_node_id = $my_node_id
    RETURN AFTER
);
IF array::is_empty($guard) THEN
    THROW "STALE_LEADER_FENCED";
END;

-- 3.2 Récupération et incrément contigu de séquence
LET $progress_rec = type::record('event_subscription_progress', $sub_id);
LET $prog = (SELECT last_assigned_seq FROM ONLY $progress_rec);
LET $current_seq = $prog.last_assigned_seq DEFAULT 0;
LET $next_seq = $current_seq + 1;

UPDATE $progress_rec SET last_assigned_seq = $next_seq;

-- 3.3 Création atomique de la livraison
CREATE type::record('event_delivery', rand::uuid::v7()) CONTENT {
    subscription: $sub_id,
    outbox_event: $event_id,
    delivery_seq: $next_seq,
    status: 'pending',
    attempts: 0,
    created_at: time::now()
};

COMMIT TRANSACTION;

-- ------------------------------------------------------------------------------
-- 4. FLUSH GRANULAIRE DE STATUT ET AVANCEMENT DE CURSEUR
-- Invariant : Le curseur ne peut JAMAIS dépasser une séquence non résolue.
-- Séquences résolues terminales : 'delivered', 'dead_letter', 'dropped'.
-- ------------------------------------------------------------------------------
-- Entrée : $sub_id (string), $target_cursor (int), $my_gen (int), $my_node_id (string)
BEGIN TRANSACTION;

-- 4.1 Garde de Fencing
LET $guard = (
    UPDATE event_stream_lease:outbox_leader
    SET last_flushed_at = time::now()
    WHERE id = event_stream_lease:outbox_leader
      AND generation = $my_gen
      AND owner_node_id = $my_node_id
    RETURN AFTER
);
IF array::is_empty($guard) THEN
    THROW "STALE_LEADER_FENCED";
END;

-- 4.2 Vérification de l'invariant de contiguïté
LET $progress_rec = type::record('event_subscription_progress', $sub_id);
LET $curr = (SELECT last_persisted_cursor FROM ONLY $progress_rec).last_persisted_cursor DEFAULT 0;

LET $unresolved = (
    SELECT VALUE delivery_seq FROM event_delivery
    WHERE subscription = $sub_id
      AND delivery_seq > $curr
      AND delivery_seq <= $target_cursor
      AND status NOT IN ['delivered', 'dead_letter', 'dropped']
);

IF array::len($unresolved) > 0 THEN
    THROW "CURSOR_INVARIANT_VIOLATION_UNRESOLVED_SEQUENCES";
END;

-- 4.3 Avancement durable du curseur
UPDATE $progress_rec SET last_persisted_cursor = $target_cursor;

COMMIT TRANSACTION;

-- ------------------------------------------------------------------------------
-- 5. BARRIÈRE DLQ ATOMIQUE ET IDEMPOTENTE
-- Entrée : $delivery_id (string), $error_msg (string), $my_gen (int), $my_node_id (string)
-- ------------------------------------------------------------------------------
BEGIN TRANSACTION;

-- 5.1 Garde de Fencing
LET $guard = (
    UPDATE event_stream_lease:outbox_leader
    SET last_flushed_at = time::now()
    WHERE id = event_stream_lease:outbox_leader
      AND generation = $my_gen
      AND owner_node_id = $my_node_id
    RETURN AFTER
);
IF array::is_empty($guard) THEN
    THROW "STALE_LEADER_FENCED";
END;

-- 5.2 Chargement de la livraison empoisonnée
LET $del_rec = type::record('event_delivery', $delivery_id);
LET $del = (SELECT * FROM ONLY $del_rec);

-- 5.3 Insertion idempotente dans event_dead_letter avec clé déterministe
LET $dlq_id = type::record('event_dead_letter', 'dlq_' + <string> $del.id);
UPSERT $dlq_id CONTENT {
    delivery_id: $del.id,
    outbox_event: $del.outbox_event,
    subscription: $del.subscription,
    attempts: $del.attempts,
    last_error: $error_msg,
    dead_lettered_at: time::now()
};

-- 5.4 Mise à jour atomique de l'enregistrement de livraison
UPDATE $del_rec SET
    status = 'dead_letter',
    dead_letter_ref = $dlq_id;

COMMIT TRANSACTION;

