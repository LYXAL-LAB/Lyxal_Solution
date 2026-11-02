-- ============================================================================
-- Function   : fn::event_subscription_register
-- Module     : lyxal_event
-- Description: Enregistre ou met à jour de façon idempotente un abonnement d'événement.
-- Contrat    : Retourne fn::result_ok($subscription)
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::event_subscription_register(
    $params: object
) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            name: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }, { rule: "regex", options: { pattern: "^[a-z][a-z0-9_]*$" } }], required: true },
            target_module: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 64 } }, { rule: "regex", options: { pattern: "^[a-z][a-z0-9_]*$" } }], required: true },
            event_pattern: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }, { rule: "regex", options: { pattern: "^(\\*|[a-z][a-z0-9_]*(\\.([a-z][a-z0-9_]*|\\*))*)$" } }], required: true },
            handler_name: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }, { rule: "regex", options: { pattern: "^[a-z][a-z0-9_]*(\\.[a-z][a-z0-9_]*)*$" } }], required: true },
            is_active: { pipeline: [{ rule: "boolean" }], default: true },
            max_attempts: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 100 } }], default: 5 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("EVENT_INVALID_PARAMETERS", $params.language, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $name = $p.name;
    LET $target_module = $p.target_module;
    LET $event_pattern = $p.event_pattern;
    LET $handler_name = $p.handler_name;
    LET $is_active = $p.is_active;
    LET $max_attempts = $p.max_attempts;

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

