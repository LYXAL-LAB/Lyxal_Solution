-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_dsl_compile
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_dsl_compile(
    $dsl: object
) -> object {
    LET $validated = fn::validation_dsl_validate_object($dsl);

    RETURN fn::validation_schema_compile(
        $validated.name,
        $validated.version,
        $validated.fields
    );
}
COMMENT "
Compile directement un objet DSL en schéma compilé.
"
PERMISSIONS FULL;
