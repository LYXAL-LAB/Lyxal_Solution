-- ============================================================================
-- Function: fn::event_publish
-- Description: Insère un événement dans event_outbox et tente un fan-out immédiat.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::event_publish(
    $params: object
) {
    LET $event_id = $params.event_id;
    LET $event_type = $params.event_type;
    LET $version = IF $params.version != NONE { $params.version } ELSE { 1 };
    LET $producer = IF $params.producer != NONE { $params.producer } ELSE { "unknown" };
    LET $source = $params.source;
    LET $context = IF $params.context != NONE { $params.context } ELSE { {
        instance_id: "default",
        namespace: "default",
        database: "default"
    } };
    LET $correlation_id = IF $params.correlation_id != NONE { $params.correlation_id } ELSE { $event_id };
    LET $causation_id = $params.causation_id;
    LET $payload = IF $params.payload != NONE { $params.payload } ELSE { {} };
    LET $metadata = IF $params.metadata != NONE { $params.metadata } ELSE { {} };
    LET $auto_fanout = IF $params.auto_fanout != NONE { $params.auto_fanout } ELSE { true };

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
} COMMENT "Publie un événement dans l'outbox et déclenche le fan-out";
