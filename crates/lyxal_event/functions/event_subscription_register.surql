-- ============================================================================
-- Function   : fn::event_subscription_register
-- Module     : lyxal_event
-- Description: Enregistre ou met à jour de façon idempotente un abonnement d'événement, pour
--              l'hôte qui porte son handler.
-- Contrat    : Retourne fn::result_ok($subscription)
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::event_subscription_register(
    $params: object
) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            name: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }, { rule: "regex", options: { pattern: "^[a-z][a-z0-9_]*$" } }], required: true },
            target_module: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 64 } }, { rule: "regex", options: { pattern: "^[a-z][a-z0-9_]*$" } }], required: true },
            host: { pipeline: [{ rule: "regex", options: { pattern: "^[a-z][a-z0-9_]{0,63}$" } }], required: true },
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

    LET $existing = (SELECT * FROM event_subscription WHERE name = $p.name)[0];

    -- Un abonnement appartient à un seul hôte : un autre hôte qui le réclame est une erreur de
    -- montage (deux binaires portent le même handler). Le changement d'hôte passe par
    -- fn::event_subscription_transfer.
    IF $existing != NONE AND $existing.host != $p.host {
        RETURN fn::error_result("EVENT_SUBSCRIPTION_HOST_CONFLICT", $p.language, {
            name: $p.name,
            host: $existing.host,
            requested_host: $p.host
        });
    };

    LET $saved = IF $existing != NONE {
        UPDATE $existing.id SET
            target_module = $p.target_module,
            event_pattern = $p.event_pattern,
            handler_name = $p.handler_name,
            is_active = $p.is_active,
            max_attempts = $p.max_attempts
        RETURN AFTER
    } ELSE {
        CREATE event_subscription CONTENT {
            name: $p.name,
            target_module: $p.target_module,
            host: $p.host,
            event_pattern: $p.event_pattern,
            handler_name: $p.handler_name,
            is_active: $p.is_active,
            max_attempts: $p.max_attempts,
            created_at: time::now()
        }
    };
    -- Écriture filtrée (session sans droit sur la table) : jamais de succès annoncé
    IF array::len($saved) == 0 {
        RETURN fn::error_result("EVENT_WRITE_FORBIDDEN", $p.language, { table: "event_subscription" });
    };
    RETURN fn::result_ok($saved[0]);
} COMMENT "Enregistre ou met à jour un abonnement ({ name, target_module, host, event_pattern, handler_name, is_active, max_attempts }) de manière idempotente, pour l'hôte qui porte son handler. Abonnement existant d'un autre hôte : EVENT_SUBSCRIPTION_HOST_CONFLICT (changement d'hôte : fn::event_subscription_transfer). Écriture refusée par les permissions : EVENT_WRITE_FORBIDDEN."
PERMISSIONS FULL;
