-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- Version 1.0.0 — PERMISSIONS FULL
-- ============================================================================
-- Fonction : fn::validation_identifier
-- Valide un identifiant ASCII : lettre ou _ au début, puis lettres, chiffres ou _.
DEFINE FUNCTION OVERWRITE fn::validation_identifier(
    $value: option<any>, $field: string, $min_length: int, $max_length: int
) -> string {
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };
    IF $min_length < 1 OR $max_length < 1 OR $min_length > $max_length {
        THROW "VALIDATION_INVALID_IDENTIFIER_LENGTH";
    };
    IF $value IS NONE { THROW string::concat($clean_field, "_REQUIRED"); };
    IF type::is_null($value) { THROW string::concat($clean_field, "_NULL_NOT_ALLOWED"); };
    IF !type::is_string($value) { THROW string::concat($clean_field, "_INVALID_TYPE"); };
    LET $clean_value = string::trim($value);
    IF $clean_value = "" { THROW string::concat($clean_field, "_BLANK_NOT_ALLOWED"); };
    LET $length = string::len($clean_value);
    IF $length < $min_length { THROW string::concat($clean_field, "_TOO_SHORT"); };
    IF $length > $max_length { THROW string::concat($clean_field, "_TOO_LONG"); };
    IF !string::matches($clean_value, "^[A-Za-z_][A-Za-z0-9_]*$") {
        THROW string::concat($clean_field, "_INVALID_IDENTIFIER");
    };
    RETURN $clean_value;
}
COMMENT "Valide un identifiant technique ASCII avec longueur configurable."
PERMISSIONS FULL;
