-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_compiled_execute_field
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_compiled_execute_field(
    $compiled_schema: object,
    $field: string,
    $value: option<any>,
    $max_steps: int
) -> any {
    LET $pipeline = fn::validation_compiled_field($compiled_schema,$field);
    RETURN fn::validation_pipeline_execute(
        $value,
        string::uppercase($field),
        $pipeline,
        $max_steps
    );
}
COMMENT "Exécute le pipeline compilé d'un champ."
PERMISSIONS FULL;
