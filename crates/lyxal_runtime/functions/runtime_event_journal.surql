-- ============================================================================
-- Journal des événements techniques du runtime (table runtime_event_journal,
-- identifiant runtime_event_journal:[event_id]).
-- Fonctions internes : entrées validées par les primitives de lyxal_core.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::runtime_event_append($params: object) {
    LET $checks = {
        event_id: fn::validation_required_string($params.event_id, 1, 128),
        sequence: fn::validation_integer($params.sequence, 0, NONE),
        node_id: fn::validation_required_string($params.node_id, 1, 128),
        timestamp: fn::validation_integer($params.timestamp, 0, NONE),
        kind: fn::validation_required_string($params.kind, 1, 128),
        module_id: fn::validation_optional_string($params.module_id, NONE, 128),
        correlation_id: fn::validation_optional_string($params.correlation_id, NONE, 256),
        causation_id: fn::validation_optional_string($params.causation_id, NONE, 128),
        payload: fn::validation_object($params.payload),
        language: fn::validation_language_code($params.language ?? "fr", false, NONE)
    };
    LET $invalid = object::from_entries(array::map(array::filter(object::entries($checks), |$e| !$e[1].valid), |$e| [$e[0], [$e[1].code]]));
    IF object::len($invalid) > 0 {
        RETURN fn::error_result("RUNTIME_INVALID_PARAMETERS", $params.language, { fields: $invalid });
    };
    LET $p = object::from_entries(array::map(object::entries($checks), |$e| [$e[0], $e[1].value]));

    -- Réécrire le même événement (rejeu) ne crée pas de doublon
    LET $saved = UPSERT ONLY type::record("runtime_event_journal", [$p.event_id]) CONTENT {
        event_id: $p.event_id,
        sequence: $p.sequence,
        node_id: $p.node_id,
        timestamp: $p.timestamp,
        kind: $p.kind,
        module_id: $p.module_id,
        correlation_id: $p.correlation_id,
        causation_id: $p.causation_id,
        payload: $p.payload
    };
    RETURN fn::result_ok($saved.{ event_id, sequence, node_id, timestamp, kind, module_id, correlation_id, causation_id, payload });
} COMMENT "Ajoute un événement technique au journal du runtime."
PERMISSIONS FULL;

DEFINE FUNCTION OVERWRITE fn::runtime_event_list($params: object) {
    LET $checks = {
        limit: fn::validation_integer($params.limit, 1, 10000),
        module_id: fn::validation_optional_string($params.module_id, NONE, 128),
        language: fn::validation_language_code($params.language ?? "fr", false, NONE)
    };
    LET $invalid = object::from_entries(array::map(array::filter(object::entries($checks), |$e| !$e[1].valid), |$e| [$e[0], [$e[1].code]]));
    IF object::len($invalid) > 0 {
        RETURN fn::error_result("RUNTIME_INVALID_PARAMETERS", $params.language, { fields: $invalid });
    };
    LET $p = object::from_entries(array::map(object::entries($checks), |$e| [$e[0], $e[1].value]));

    RETURN fn::result_ok(
        SELECT event_id, sequence, node_id, timestamp, kind, module_id, correlation_id, causation_id, payload
        FROM runtime_event_journal
        WHERE $p.module_id = NONE OR module_id = $p.module_id
        ORDER BY timestamp DESC, sequence DESC
        LIMIT $p.limit
    );
} COMMENT "Événements récents du journal, du plus récent au plus ancien, éventuellement filtrés par module."
PERMISSIONS FULL;
