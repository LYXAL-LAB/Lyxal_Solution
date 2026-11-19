-- ============================================================================
-- Function   : fn::event_delivery_fetch_pending
-- Module     : lyxal_event
-- Description: Récupère les livraisons d'un hôte éligibles au traitement ou à la reprise après
--              crash (lecture du chef des événements de cet hôte).
-- Contrat    : Retourne fn::result_ok(Vec<PendingDelivery>)
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::event_delivery_fetch_pending(
    $params: object
) {
    -- Fonction interne du moteur d'événements (appelée par le code Rust avec des types
    -- vérifiés, à chaque livraison) : validation par les primitives de lyxal_core plutôt que
    -- par fn::validation_object_execute, dont le coût par appel pèserait sur le débit
    -- (décision CTO, reprise lyxal_event).
    LET $checks = {
        host: fn::validation_regex($params.host, "^[a-z][a-z0-9_]{0,63}$"),
        limit: fn::validation_integer(($params.limit ?? 50), 1, 1000),
        instance_id: IF $params.instance_id IS NONE { { valid: true, value: NONE } } ELSE { fn::validation_optional_string($params.instance_id, 1, 128) },
        subscription: IF $params.subscription IS NONE { { valid: true, value: NONE } } ELSE { fn::validation_record_id($params.subscription, ["event_subscription"]) },
        language: fn::validation_language_code($params.language ?? "fr", false, NONE)
    };
    LET $invalid = object::from_entries(array::map(array::filter(object::entries($checks), |$e| !$e[1].valid), |$e| [$e[0], [$e[1].code]]));
    IF object::len($invalid) > 0 {
        RETURN fn::error_result("EVENT_INVALID_PARAMETERS", $params.language, { fields: $invalid });
    };
    LET $p = object::from_entries(array::map(object::entries($checks), |$e| [$e[0], $e[1].value]));
    LET $host = $p.host;
    LET $limit = $p.limit;
    LET $instance_id = $p.instance_id;
    LET $subscription = $p.subscription;

    LET $now = time::now();

    -- Livraisons de cet hôte seulement, non soldées. Une lecture par statut (égalité sur les deux
    -- premiers champs de l'index idx_delivery_claim_eligibility (host, status, next_retry_at)) :
    -- « status IN [...] » ne parcourt que le préfixe host de l'index, livraisons soldées comprises
    -- (mesure : 7 fois plus lent sur 100 000 livraisons). Chaque lecture garde ses $limit plus
    -- anciennes ; la fusion garde les $limit plus anciennes de l'ensemble. Une livraison orpheline
    -- (abonnement supprimé) reste à l'hôte inscrit sur la livraison. Abonnement suspendu
    -- (is_active = false) : ses livraisons attendent sa réactivation.
    LET $pending = (
        SELECT id, created_at FROM event_delivery
        WHERE host = $host AND status = 'pending'
          AND (next_retry_at = NONE OR next_retry_at <= $now)
          AND (locked_until = NONE OR locked_until < $now)
          AND ($instance_id = NONE OR context.instance_id = $instance_id)
          AND ($subscription = NONE OR subscription = $subscription)
          AND subscription.is_active != false
        ORDER BY created_at ASC, id ASC
        LIMIT $limit
    );
    LET $processing = (
        SELECT id, created_at FROM event_delivery
        WHERE host = $host AND status = 'processing'
          AND (next_retry_at = NONE OR next_retry_at <= $now)
          AND (locked_until = NONE OR locked_until < $now)
          AND ($instance_id = NONE OR context.instance_id = $instance_id)
          AND ($subscription = NONE OR subscription = $subscription)
          AND subscription.is_active != false
        ORDER BY created_at ASC, id ASC
        LIMIT $limit
    );
    LET $failed = (
        SELECT id, created_at FROM event_delivery
        WHERE host = $host AND status = 'failed'
          AND (next_retry_at = NONE OR next_retry_at <= $now)
          AND (locked_until = NONE OR locked_until < $now)
          AND ($instance_id = NONE OR context.instance_id = $instance_id)
          AND ($subscription = NONE OR subscription = $subscription)
          AND subscription.is_active != false
        ORDER BY created_at ASC, id ASC
        LIMIT $limit
    );
    LET $eligible = (
        SELECT VALUE id FROM array::concat($pending, $processing, $failed)
        ORDER BY created_at ASC, id ASC
        LIMIT $limit
    );

    LET $deliveries = (
        SELECT
            id,
            created_at,
            outbox_event,
            subscription,
            subscription.max_attempts AS max_attempts,
            delivery_seq,
            target_module,
            context,
            outbox_event.event_id AS event_id,
            outbox_event.event_type AS event_type,
            outbox_event.version AS version,
            outbox_event.producer AS producer,
            outbox_event.source AS source,
            outbox_event.correlation_id AS correlation_id,
            outbox_event.causation_id AS causation_id,
            outbox_event.payload AS payload,
            outbox_event.metadata AS metadata
        FROM $eligible
        ORDER BY created_at ASC, id ASC
    );

    RETURN fn::result_ok($deliveries);
} COMMENT "Récupère les livraisons de l'hôte demandé ({ host, limit, instance_id, subscription }) éligibles au traitement ou à la reprise post-crash, des plus anciennes aux plus récentes ; celles d'un abonnement suspendu attendent sa réactivation, celles des autres hôtes ne sont jamais lues"
PERMISSIONS FULL;

