-- ============================================================================
-- Modules connus du runtime (table runtime_module, identifiant runtime_module:[module_id]).
-- Fonctions internes : entrées validées par les primitives de lyxal_core.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::runtime_module_upsert($params: object) {
    LET $checks = {
        module_id: fn::validation_required_string($params.module_id, 1, 128),
        name: fn::validation_required_string($params.name, 1, 256),
        description: fn::validation_optional_string($params.description, NONE, 4000),
        language: fn::validation_language_code($params.language ?? "fr", false, NONE)
    };
    LET $invalid = object::from_entries(array::map(array::filter(object::entries($checks), |$e| !$e[1].valid), |$e| [$e[0], [$e[1].code]]));
    IF object::len($invalid) > 0 {
        RETURN fn::error_result("RUNTIME_INVALID_PARAMETERS", $params.language, { fields: $invalid });
    };
    LET $p = object::from_entries(array::map(object::entries($checks), |$e| [$e[0], $e[1].value]));

    LET $saved = UPSERT ONLY type::record("runtime_module", [$p.module_id]) MERGE {
        module_id: $p.module_id,
        name: $p.name,
        description: $p.description,
        updated_at: time::now()
    };
    RETURN fn::result_ok($saved.{ module_id, name, description, created_at, updated_at });
} COMMENT "Enregistre ou met à jour un module connu du runtime."
PERMISSIONS FULL;

DEFINE FUNCTION OVERWRITE fn::runtime_module_get($params: object) {
    LET $checks = {
        module_id: fn::validation_required_string($params.module_id, 1, 128),
        language: fn::validation_language_code($params.language ?? "fr", false, NONE)
    };
    LET $invalid = object::from_entries(array::map(array::filter(object::entries($checks), |$e| !$e[1].valid), |$e| [$e[0], [$e[1].code]]));
    IF object::len($invalid) > 0 {
        RETURN fn::error_result("RUNTIME_INVALID_PARAMETERS", $params.language, { fields: $invalid });
    };
    LET $p = object::from_entries(array::map(object::entries($checks), |$e| [$e[0], $e[1].value]));

    RETURN fn::result_ok(SELECT * OMIT id FROM ONLY type::record("runtime_module", [$p.module_id]));
} COMMENT "Module connu du runtime, ou NONE."
PERMISSIONS FULL;

DEFINE FUNCTION OVERWRITE fn::runtime_module_list($params: object) {
    RETURN fn::result_ok(SELECT * OMIT id FROM runtime_module ORDER BY module_id ASC);
} COMMENT "Modules connus du runtime, triés par identifiant."
PERMISSIONS FULL;
