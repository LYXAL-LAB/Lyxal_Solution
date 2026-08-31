-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- Version 1.0.0 — PERMISSIONS FULL
-- ============================================================================
-- Fonction : fn::validation_hexadecimal
DEFINE FUNCTION OVERWRITE fn::validation_hexadecimal(
    $value: option<any>, $field: string,
    $min_length: option<int>, $max_length: option<int>, $allow_prefix: bool
) -> string {
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };
    IF $min_length IS NOT NONE AND $min_length < 1 { THROW "VALIDATION_INVALID_HEX_MIN_LENGTH"; };
    IF $max_length IS NOT NONE AND $max_length < 1 { THROW "VALIDATION_INVALID_HEX_MAX_LENGTH"; };
    IF $min_length IS NOT NONE AND $max_length IS NOT NONE AND $min_length > $max_length {
        THROW "VALIDATION_INVALID_HEX_LENGTH_RANGE";
    };
    IF $value IS NONE { THROW string::concat($clean_field, "_REQUIRED"); };
    IF type::is_null($value) { THROW string::concat($clean_field, "_NULL_NOT_ALLOWED"); };
    IF !type::is_string($value) { THROW string::concat($clean_field, "_INVALID_TYPE"); };
    LET $clean_value = string::trim($value);
    IF $clean_value = "" { THROW string::concat($clean_field, "_BLANK_NOT_ALLOWED"); };
    LET $pattern = IF $allow_prefix { "^(0x|0X)?[0-9A-Fa-f]+$" } ELSE { "^[0-9A-Fa-f]+$" };
    IF !string::matches($clean_value, $pattern) { THROW string::concat($clean_field, "_INVALID_HEXADECIMAL"); };
    LET $hex_value = IF string::starts_with($clean_value, "0x") OR string::starts_with($clean_value, "0X") {
        string::slice($clean_value, 2)
    } ELSE { $clean_value };
    LET $length = string::len($hex_value);
    IF $min_length IS NOT NONE AND $length < $min_length { THROW string::concat($clean_field, "_TOO_SHORT"); };
    IF $max_length IS NOT NONE AND $length > $max_length { THROW string::concat($clean_field, "_TOO_LONG"); };
    RETURN string::lowercase($clean_value);
}
COMMENT "Valide une chaîne hexadécimale avec longueur et préfixe facultatifs."
PERMISSIONS FULL;
