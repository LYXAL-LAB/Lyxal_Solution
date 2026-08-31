-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- Version 1.0.0 — PERMISSIONS FULL
-- ============================================================================
-- Fonction : fn::validation_mime_type
DEFINE FUNCTION OVERWRITE fn::validation_mime_type(
    $value: option<any>, $field: string, $allowed_types: option<array<string>>
) -> string {
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };
    IF $value IS NONE { THROW string::concat($clean_field, "_REQUIRED"); };
    IF type::is_null($value) { THROW string::concat($clean_field, "_NULL_NOT_ALLOWED"); };
    IF !type::is_string($value) { THROW string::concat($clean_field, "_INVALID_TYPE"); };
    LET $clean_value = string::lowercase(string::trim($value));
    IF $clean_value = "" { THROW string::concat($clean_field, "_BLANK_NOT_ALLOWED"); };
    IF !string::matches($clean_value, "^[a-z0-9!#$&^_.+-]+/[a-z0-9!#$&^_.+-]+$") {
        THROW string::concat($clean_field, "_INVALID_MIME_TYPE");
    };
    IF $allowed_types IS NOT NONE {
        IF array::len($allowed_types) = 0 { THROW "VALIDATION_EMPTY_ALLOWED_MIME_TYPES"; };
        LET $allowed = array::map($allowed_types, |$mime| string::lowercase(string::trim($mime)));
        IF !array::contains($allowed, $clean_value) {
            THROW string::concat($clean_field, "_MIME_TYPE_NOT_ALLOWED");
        };
    };
    RETURN $clean_value;
}
COMMENT "Valide et normalise un type MIME, avec liste autorisée facultative."
PERMISSIONS FULL;
