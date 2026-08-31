-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_validator_name
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_validator_name(
    $value: option<any>,
    $field: string
) -> string {
    LET $clean_field = string::trim($field);

    IF $value IS NONE {
        THROW string::concat($clean_field, "_REQUIRED");
    };

    IF !type::is_string($value) {
        THROW string::concat($clean_field, "_INVALID_TYPE");
    };

    LET $name = string::lowercase(string::trim($value));

    IF !string::matches(
        $name,
        "^[a-z][a-z0-9_]*(?:::[a-z][a-z0-9_]*)*$"
    ) {
        THROW string::concat(
            $clean_field,
            "_INVALID_VALIDATOR_NAME"
        );
    };

    RETURN $name;
}
COMMENT "
Valide le nom canonique d'un validateur enregistré.
"
PERMISSIONS FULL;
