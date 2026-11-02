-- ============================================================================
-- Function   : fn::event_subscription_register
-- Module     : lyxal_event
-- Description: Enregistre ou met à jour de façon idempotente un abonnement d'événement.
-- Contrat    : Retourne fn::result_ok($subscription)
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::event_subscription_register(
    $params: object
) {
    IF $params.name == NONE OR $params.target_module == NONE OR $params.event_pattern == NONE OR $params.handler_name == NONE {
        RETURN fn::error_result("EVENT_INVALID_PARAMETERS", "fr", { message: "name, target_module, event_pattern, and handler_name are mandatory" });
    };

    LET $name = <string> $params.name;
    LET $target_module = <string> $params.target_module;
    LET $event_pattern = <string> $params.event_pattern;
    LET $handler_name = <string> $params.handler_name;
    LET $is_active = IF $params.is_active != NONE AND $params.is_active != NULL THEN <bool> $params.is_active ELSE true END;
    LET $max_attempts = IF $params.max_attempts != NONE AND $params.max_attempts != NULL THEN <number> $params.max_attempts ELSE 5 END;

    LET $existing = (SELECT * FROM event_subscription WHERE name = $name)[0];

    IF $existing != NONE {
        LET $updated = (
            UPDATE $existing.id SET
                target_module = $target_module,
                event_pattern = $event_pattern,
                handler_name = $handler_name,
                is_active = $is_active,
                max_attempts = $max_attempts
            RETURN AFTER
        );
        RETURN fn::result_ok($updated[0]);
    } ELSE {
        LET $created = (
            CREATE event_subscription CONTENT {
                name: $name,
                target_module: $target_module,
                event_pattern: $event_pattern,
                handler_name: $handler_name,
                is_active: $is_active,
                max_attempts: $max_attempts,
                created_at: time::now()
            }
        );
        RETURN fn::result_ok($created[0]);
    };
} COMMENT "Enregistre ou met à jour un abonnement d'événement de manière idempotente"
PERMISSIONS FULL;

