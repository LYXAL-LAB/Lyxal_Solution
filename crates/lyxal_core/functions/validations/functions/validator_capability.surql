-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_validator_capability
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_validator_capability(
    $value: any,
    $field: string
) -> string {
    LET $clean_field = string::trim($field);

    IF $value IS NONE
        OR !type::is_string($value)
    {
        THROW string::concat($clean_field, "_INVALID_TYPE");
    };

    LET $capability = string::lowercase(string::trim($value));

    IF !(([
            "presence",
            "type",
            "format",
            "range",
            "length",
            "transform",
            "combinator",
            "schema",
            "report"
        ]) CONTAINS ($capability)) {
        THROW string::concat(
            $clean_field,
            "_INVALID_CAPABILITY"
        );
    };

    RETURN $capability;
}
COMMENT "
Valide une capacité déclarée par un validateur.
"
PERMISSIONS FULL;
