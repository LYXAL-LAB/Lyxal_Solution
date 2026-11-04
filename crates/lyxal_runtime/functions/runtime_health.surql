-- ============================================================================
-- Santé des modules par nœud (table runtime_health, identifiant runtime_health:[node_id, module_id]).
-- Fonctions internes : entrées validées par les primitives de lyxal_core.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::runtime_health_record($params: object) {
    LET $checks = {
        node_id: fn::validation_required_string($params.node_id, 1, 128),
        module_id: fn::validation_required_string($params.module_id, 1, 128),
        status: fn::validation_enum($params.status, ["healthy", "degraded", "unhealthy", "unknown", "not_applicable"], true),
        latency_ms: IF $params.latency_ms IS NONE THEN { valid: true, value: NONE } ELSE fn::validation_integer($params.latency_ms, 0, NONE) END,
        message: fn::validation_optional_string($params.message, NONE, 4000),
        language: fn::validation_language_code($params.language ?? "fr", false, NONE)
    };
    LET $invalid = object::from_entries(array::map(array::filter(object::entries($checks), |$e| !$e[1].valid), |$e| [$e[0], [$e[1].code]]));
    IF object::len($invalid) > 0 {
        RETURN fn::error_result("RUNTIME_INVALID_PARAMETERS", $params.language, { fields: $invalid });
    };
    LET $p = object::from_entries(array::map(object::entries($checks), |$e| [$e[0], $e[1].value]));

    LET $saved = UPSERT ONLY type::record("runtime_health", [$p.node_id, $p.module_id]) MERGE {
        node_id: $p.node_id,
        module_id: $p.module_id,
        status: $p.status,
        latency_ms: $p.latency_ms,
        message: $p.message,
        checked_at: time::now(),
        updated_at: time::now()
    };
    RETURN fn::result_ok($saved.{ node_id, module_id, status, latency_ms, message, checked_at });
} COMMENT "Enregistre l'état de santé d'un module sur un nœud."
PERMISSIONS FULL;

DEFINE FUNCTION OVERWRITE fn::runtime_health_list($params: object) {
    LET $checks = {
        node_id: fn::validation_required_string($params.node_id, 1, 128),
        language: fn::validation_language_code($params.language ?? "fr", false, NONE)
    };
    LET $invalid = object::from_entries(array::map(array::filter(object::entries($checks), |$e| !$e[1].valid), |$e| [$e[0], [$e[1].code]]));
    IF object::len($invalid) > 0 {
        RETURN fn::error_result("RUNTIME_INVALID_PARAMETERS", $params.language, { fields: $invalid });
    };
    LET $p = object::from_entries(array::map(object::entries($checks), |$e| [$e[0], $e[1].value]));

    RETURN fn::result_ok(SELECT node_id, module_id, status, latency_ms, message, checked_at FROM runtime_health WHERE node_id = $p.node_id ORDER BY module_id ASC);
} COMMENT "États de santé des modules d'un nœud, triés par module."
PERMISSIONS FULL;
