-- ============================================================================
-- Function: fn::event_publish
-- Description: Insère un événement dans event_outbox et tente un fan-out immédiat.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::event_publish(
    $params: object
) {
    LET $report = fn::validation_fields_execute($params, {
        event_id: { checks: [|$v: any| fn::validation_uuid($v)], required: true },
        event_type: { checks: [|$v: any| fn::validation_required_string($v, 1, 128), |$v: any| fn::validation_regex($v, "^[a-z][a-z0-9_]*(\\.[a-z][a-z0-9_]*)+$")], required: true },
        version: { checks: [|$v: any| fn::validation_integer($v, 1, NONE)], default: 1 },
        producer: { checks: [|$v: any| fn::validation_required_string($v, 1, 64), |$v: any| fn::validation_regex($v, "^[a-z][a-z0-9_]*$")], required: true },
        source: { checks: [|$v: any| fn::validation_record_id($v, NONE)] },
        context: { checks: [|$v: any| fn::validation_object($v)], default: { instance_id: "default", namespace: "default", database: "default" } },
        correlation_id: { checks: [|$v: any| fn::validation_uuid($v)] },
        causation_id: { checks: [|$v: any| fn::validation_uuid($v)] },
        payload: { checks: [|$v: any| fn::validation_object($v)], default: {} },
        metadata: { checks: [|$v: any| fn::validation_object($v)], default: {} },
        auto_fanout: { checks: [|$v: any| fn::validation_boolean($v)], default: true },
        language: { checks: [|$v: any| fn::validation_language_code($v, false, NONE)], default: "fr" }
    }, "reject");
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
    -- Une écriture refusée par les permissions de la table ne lève pas d'erreur : l'événement
    -- serait perdu en silence (standards §11.4). Seuls la session système et les DEFINE EVENT
    -- publient.
    IF $created == NONE {
        RETURN fn::error_result("EVENT_WRITE_FORBIDDEN", $params.language, { table: "event_outbox" });
    };

    -- Déclenchement facultatif et sécurisé du fan-out immédiat
    IF $auto_fanout {
        LET $fanout_res = fn::event_fanout({
            outbox_id: $created.id
        });
    };

    RETURN fn::result_ok($created);
} COMMENT "Publie un événement dans l'outbox et déclenche le fan-out"
PERMISSIONS FULL;
