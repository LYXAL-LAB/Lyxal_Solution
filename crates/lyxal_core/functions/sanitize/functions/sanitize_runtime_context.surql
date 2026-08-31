-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_runtime_context
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_runtime_context(
    $schema_name: string,
    $schema_version: string,
    $mode: string,
    $options: option<object>
) -> object {
    LET $m = string::lowercase(string::trim($mode));
    IF !array::contains(["strict","permissive","silent"],$m) {
        THROW "SANITIZE_RUNTIME_INVALID_MODE";
    };
    RETURN {
        schema_name:string::lowercase(string::trim($schema_name)),
        schema_version:fn::sanitize_schema_version($schema_version),
        mode:$m,
        options:IF $options IS NONE {{} } ELSE {$options},
        started_at:time::now()
    };
}
COMMENT "Construit le contexte du runtime de sanitation."
PERMISSIONS FULL;
