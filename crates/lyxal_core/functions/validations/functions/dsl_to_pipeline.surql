-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_dsl_to_pipeline
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_dsl_to_pipeline(
    $definition: object
) -> array<object> {
    LET $normalized = fn::validation_dsl_normalize_field(
        $definition
    );

    RETURN fn::validation_compile_field_rule(
        "field",
        $normalized
    );
}
COMMENT "
Transforme une définition de champ DSL en pipeline ordonné.
"
PERMISSIONS FULL;
