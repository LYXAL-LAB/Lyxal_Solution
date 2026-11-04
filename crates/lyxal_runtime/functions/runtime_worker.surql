-- ============================================================================
-- État des workers par nœud (table runtime_worker, identifiant runtime_worker:[node_id, worker_id]).
-- Fonctions internes : entrées validées par les primitives de lyxal_core.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::runtime_worker_upsert($params: object) {
    LET $checks = {
        node_id: fn::validation_required_string($params.node_id, 1, 128),
        worker_id: fn::validation_required_string($params.worker_id, 1, 256),
        module_id: fn::validation_required_string($params.module_id, 1, 128),
        state: fn::validation_enum($params.state, ["registered", "starting", "running", "stopping", "stopped", "restarting", "failed"], true),
        criticality: fn::validation_enum($params.criticality, ["required", "optional"], true),
        restart_count: fn::validation_integer($params.restart_count, 0, NONE),
        failure_count: fn::validation_integer($params.failure_count, 0, NONE),
        last_error: fn::validation_optional_string($params.last_error, NONE, 4000),
        started_at: IF $params.started_at IS NONE THEN { valid: true, value: NONE } ELSE fn::validation_integer($params.started_at, 0, NONE) END,
        stopped_at: IF $params.stopped_at IS NONE THEN { valid: true, value: NONE } ELSE fn::validation_integer($params.stopped_at, 0, NONE) END,
        language: fn::validation_language_code($params.language ?? "fr", false, NONE)
    };
    LET $invalid = object::from_entries(array::map(array::filter(object::entries($checks), |$e| !$e[1].valid), |$e| [$e[0], [$e[1].code]]));
    IF object::len($invalid) > 0 {
        RETURN fn::error_result("RUNTIME_INVALID_PARAMETERS", $params.language, { fields: $invalid });
    };
    LET $p = object::from_entries(array::map(object::entries($checks), |$e| [$e[0], $e[1].value]));

    LET $saved = UPSERT ONLY type::record("runtime_worker", [$p.node_id, $p.worker_id]) MERGE {
        node_id: $p.node_id,
        worker_id: $p.worker_id,
        module_id: $p.module_id,
        state: $p.state,
        criticality: $p.criticality,
        restart_count: $p.restart_count,
        failure_count: $p.failure_count,
        last_error: $p.last_error,
        started_at: $p.started_at,
        stopped_at: $p.stopped_at,
        updated_at: time::now()
    };
    RETURN fn::result_ok($saved.{ node_id, worker_id, module_id, state, criticality, restart_count, failure_count, last_error, started_at, stopped_at, updated_at });
} COMMENT "Enregistre l'état et les métriques d'un worker sur un nœud."
PERMISSIONS FULL;

DEFINE FUNCTION OVERWRITE fn::runtime_worker_get($params: object) {
    LET $checks = {
        node_id: fn::validation_required_string($params.node_id, 1, 128),
        worker_id: fn::validation_required_string($params.worker_id, 1, 256),
        language: fn::validation_language_code($params.language ?? "fr", false, NONE)
    };
    LET $invalid = object::from_entries(array::map(array::filter(object::entries($checks), |$e| !$e[1].valid), |$e| [$e[0], [$e[1].code]]));
    IF object::len($invalid) > 0 {
        RETURN fn::error_result("RUNTIME_INVALID_PARAMETERS", $params.language, { fields: $invalid });
    };
    LET $p = object::from_entries(array::map(object::entries($checks), |$e| [$e[0], $e[1].value]));

    RETURN fn::result_ok(SELECT * OMIT id FROM ONLY type::record("runtime_worker", [$p.node_id, $p.worker_id]));
} COMMENT "État d'un worker sur un nœud, ou NONE."
PERMISSIONS FULL;

DEFINE FUNCTION OVERWRITE fn::runtime_worker_list($params: object) {
    LET $checks = {
        node_id: fn::validation_required_string($params.node_id, 1, 128),
        language: fn::validation_language_code($params.language ?? "fr", false, NONE)
    };
    LET $invalid = object::from_entries(array::map(array::filter(object::entries($checks), |$e| !$e[1].valid), |$e| [$e[0], [$e[1].code]]));
    IF object::len($invalid) > 0 {
        RETURN fn::error_result("RUNTIME_INVALID_PARAMETERS", $params.language, { fields: $invalid });
    };
    LET $p = object::from_entries(array::map(object::entries($checks), |$e| [$e[0], $e[1].value]));

    RETURN fn::result_ok(SELECT * OMIT id FROM runtime_worker WHERE node_id = $p.node_id ORDER BY worker_id ASC);
} COMMENT "Workers d'un nœud, triés par identifiant."
PERMISSIONS FULL;
