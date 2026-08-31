-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_dsl_field
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_dsl_field(
    $field: string,
    $definition: object
) -> object {
    LET $clean_field = string::trim($field);

    IF !string::matches(
        $clean_field,
        "^[A-Za-z_][A-Za-z0-9_]*$"
    ) {
        THROW "VALIDATION_DSL_INVALID_FIELD_NAME";
    };

    IF object::is_empty($definition) {
        THROW "VALIDATION_DSL_EMPTY_FIELD_DEFINITION";
    };

    RETURN {
        field: $clean_field,
        definition: $definition
    };
}
COMMENT "
Construit la définition DSL d'un champ.
"
PERMISSIONS FULL;
