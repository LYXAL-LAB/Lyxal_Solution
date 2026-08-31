-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_dsl_validate_field
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_dsl_validate_field(
    $field: string,
    $definition: object
) -> object {
    LET $normalized = fn::validation_dsl_normalize_field(
        $definition
    );

    IF $normalized.lowercase = true
        AND $normalized.uppercase = true
    {
        THROW "VALIDATION_DSL_CONFLICTING_CASE_RULES";
    };

    IF $normalized.min_length IS NOT NONE
        AND (
            !type::is_int($normalized.min_length)
            OR $normalized.min_length < 0
        )
    {
        THROW "VALIDATION_DSL_INVALID_MIN_LENGTH";
    };

    IF $normalized.max_length IS NOT NONE
        AND (
            !type::is_int($normalized.max_length)
            OR $normalized.max_length < 0
        )
    {
        THROW "VALIDATION_DSL_INVALID_MAX_LENGTH";
    };

    IF $normalized.min_length IS NOT NONE
        AND $normalized.max_length IS NOT NONE
        AND $normalized.min_length > $normalized.max_length
    {
        THROW "VALIDATION_DSL_INVALID_LENGTH_RANGE";
    };

    RETURN {
        field: string::trim($field),
        definition: $normalized
    };
}
COMMENT "
Valide la cohérence interne d'une définition de champ DSL.
"
PERMISSIONS FULL;
