-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_dsl_execute
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_dsl_execute(
    $dsl: object,
    $value: object,
    $max_steps: int
) -> object {
    LET $compiled = fn::validation_dsl_compile($dsl);

    RETURN fn::validation_compiled_execute_object(
        $compiled,
        $value,
        $max_steps
    );
}
COMMENT "
Compile puis exécute un objet DSL sur une valeur.
"
PERMISSIONS FULL;
