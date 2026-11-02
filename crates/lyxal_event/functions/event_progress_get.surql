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
    IF $params.subscription == NONE OR $params.subscription == NULL {
        RETURN fn::error_result("EVENT_INVALID_PARAMETERS", "fr", { message: "subscription is mandatory" });
    };

    LET $subscription = <record<event_subscription>> $params.subscription;
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

