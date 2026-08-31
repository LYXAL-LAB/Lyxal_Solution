-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_runtime_execute_field
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_runtime_execute_field(
    $compiled_field: object,
    $value: option<any>,
    $max_steps: int
) -> object {
    LET $output = fn::sanitize_pipeline_execute(
        $value,
        $compiled_field.field,
        $compiled_field.steps,
        $max_steps
    );
    RETURN {
        field:$compiled_field.field,
        input:$value,
        output:$output,
        changed:$value != $output
    };
}
COMMENT "Exécute la sanitation d'un champ compilé."
PERMISSIONS FULL;
