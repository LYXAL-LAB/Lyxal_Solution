-- ============================================================================
-- Function   : fn::event_progress_get
-- Module     : lyxal_event
-- Description: Récupère la progression persistée pour un abonnement (compteur et curseur).
--              Utilisé par le superviseur OutboxFeeder lors de la reprise après crash.
-- Contrat    : Retourne fn::result_ok({ subscription: string, partition: int, last_assigned_seq: int, last_persisted_cursor: int, exists: bool })
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::event_progress_get(
    $params: object
) {
    -- Fonction interne du moteur d'événements (appelée par le code Rust avec des types
    -- vérifiés, à chaque livraison) : validation par les primitives de lyxal_core plutôt que
    -- par fn::validation_object_execute, dont le coût par appel pèserait sur le débit
    -- (décision CTO, reprise lyxal_event).
    LET $checks = {
        subscription: fn::validation_record_id($params.subscription, ["event_subscription"]),
        language: fn::validation_language_code($params.language ?? "fr", false, NONE)
    };
    LET $invalid = object::from_entries(array::map(array::filter(object::entries($checks), |$e| !$e[1].valid), |$e| [$e[0], [$e[1].code]]));
    IF object::len($invalid) > 0 {
        RETURN fn::error_result("EVENT_INVALID_PARAMETERS", $params.language, { fields: $invalid });
    };
    LET $p = object::from_entries(array::map(object::entries($checks), |$e| [$e[0], $e[1].value]));
    LET $subscription = $p.subscription;

    LET $prog_rec = type::record(string::concat("event_subscription_progress:prog_", record::id($subscription)));
    LET $prog = (SELECT * FROM ONLY $prog_rec);

    IF $prog == NONE {
        RETURN fn::result_ok({
            subscription: <string> $subscription,
            partition: 0,
            last_assigned_seq: 0,
            last_persisted_cursor: 0,
            exists: false,
            updated_at: NONE
        });
    };

    RETURN fn::result_ok({
        subscription: <string> $prog.subscription,
        partition: $prog.partition,
        last_assigned_seq: $prog.last_assigned_seq,
        last_persisted_cursor: $prog.last_persisted_cursor,
        exists: true,
        updated_at: $prog.updated_at
    });
} COMMENT "Lit l'état durable de la progression et du curseur pour un abonnement."
PERMISSIONS FULL;

