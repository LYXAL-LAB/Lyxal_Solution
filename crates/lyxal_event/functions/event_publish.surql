-- ============================================================================
-- Function: fn::event_publish
-- Description: Insère un événement dans event_outbox et tente un fan-out immédiat.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::event_publish(
    $params: object
) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            event_id: { pipeline: [{ rule: "uuid" }], required: true },
            event_type: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }, { rule: "regex", options: { pattern: "^[a-z][a-z0-9_]*(\\.[a-z][a-z0-9_]*)+$" } }], required: true },
            version: { pipeline: [{ rule: "integer", options: { min_value: 1 } }], default: 1 },
            producer: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 64 } }, { rule: "regex", options: { pattern: "^[a-z][a-z0-9_]*$" } }], required: true },
            source: { pipeline: [{ rule: "record_id" }] },
            context: { pipeline: [{ rule: "is_object" }], default: { instance_id: "default", namespace: "default", database: "default" } },
            correlation_id: { pipeline: [{ rule: "uuid" }] },
            causation_id: { pipeline: [{ rule: "uuid" }] },
            payload: { pipeline: [{ rule: "is_object" }], default: {} },
            metadata: { pipeline: [{ rule: "is_object" }], default: {} },
            auto_fanout: { pipeline: [{ rule: "boolean" }], default: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("EVENT_INVALID_PARAMETERS", $params.language, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $event_id = <string> $p.event_id;
    LET $event_type = $p.event_type;
    LET $version = $p.version;
    LET $producer = $p.producer;
    LET $source = $p.source;
    LET $context = $p.context;
    LET $correlation_id = IF $p.correlation_id IS NONE { $event_id } ELSE { <string> $p.correlation_id };
    LET $causation_id = IF $p.causation_id IS NONE { NONE } ELSE { <string> $p.causation_id };
    LET $payload = $p.payload;
    LET $metadata = $p.metadata;
    LET $auto_fanout = $p.auto_fanout;

    -- Création durable et atomique de l'enregistrement outbox
    LET $created = (
        CREATE event_outbox CONTENT {
            event_id: $event_id,
            event_type: $event_type,
            version: $version,
            producer: $producer,
            source: $source,
            context: $context,
            correlation_id: $correlation_id,
            causation_id: $causation_id,
            payload: $payload,
            metadata: $metadata,
            status: "pending",
            created_at: time::now()
        }
    )[0];

    -- Déclenchement facultatif et sécurisé du fan-out immédiat
    IF $auto_fanout {
        LET $fanout_res = fn::event_fanout({
            outbox_id: $created.id
        });
    };

    RETURN fn::result_ok($created);
} COMMENT "Publie un événement dans l'outbox et déclenche le fan-out"
PERMISSIONS FULL;
