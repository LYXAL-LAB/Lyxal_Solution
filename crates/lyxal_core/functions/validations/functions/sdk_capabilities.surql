-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_sdk_capabilities
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_sdk_capabilities()
    -> array<string> {
    RETURN [
        "primitive_validation",
        "conditional_validation",
        "schema_validation",
        "pipeline_execution",
        "error_reports",
        "nested_schemas",
        "schema_compilation",
        "schema_cache",
        "validator_registry",
        "validation_dsl",
        "runtime_execution",
        "pipeline_optimization",
        "debug_traces",
        "benchmarks"
    ];
}
COMMENT "
Retourne les capacités publiques du Validation SDK.
"
PERMISSIONS FULL;
