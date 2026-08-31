-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_dsl_rule
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_dsl_rule(
    $name: string,
    $value: option<any>
) -> object {
    LET $clean_name = string::lowercase(string::trim($name));

    IF !array::contains(
        [
            "required",
            "nullable",
            "type",
            "default",
            "trim",
            "lowercase",
            "uppercase",
            "min_length",
            "max_length",
            "min",
            "max",
            "pattern",
            "enum"
        ],
        $clean_name
    ) {
        THROW "VALIDATION_DSL_UNKNOWN_RULE";
    };

    RETURN {
        name: $clean_name,
        value: $value
    };
}
COMMENT "
Construit une règle élémentaire du DSL de validation.
"
PERMISSIONS FULL;
