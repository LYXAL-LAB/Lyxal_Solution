-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- Version 1.0.0 — PERMISSIONS FULL
-- ============================================================================
-- Fonction : fn::validation_base64
DEFINE FUNCTION OVERWRITE fn::validation_base64(
    $value: option<any>, $field: string, $url_safe: bool, $require_padding: bool
) -> string {
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };
    IF $value IS NONE { THROW string::concat($clean_field, "_REQUIRED"); };
    IF type::is_null($value) { THROW string::concat($clean_field, "_NULL_NOT_ALLOWED"); };
    IF !type::is_string($value) { THROW string::concat($clean_field, "_INVALID_TYPE"); };
    LET $clean_value = string::trim($value);
    IF $clean_value = "" { THROW string::concat($clean_field, "_BLANK_NOT_ALLOWED"); };
    LET $pattern = IF $url_safe { "^[A-Za-z0-9_-]+={0,2}$" } ELSE { "^[A-Za-z0-9+/]+={0,2}$" };
    IF !string::matches($clean_value, $pattern) { THROW string::concat($clean_field, "_INVALID_BASE64"); };
    IF $require_padding AND string::len($clean_value) % 4 != 0 {
        THROW string::concat($clean_field, "_INVALID_BASE64_PADDING");
    };
    RETURN $clean_value;
}
COMMENT "Valide la forme lexicale d'une chaîne Base64 standard ou URL-safe."
PERMISSIONS FULL;
