-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- Version 1.0.0 — PERMISSIONS FULL
-- ============================================================================
-- Fonction : fn::validation_extension
DEFINE FUNCTION OVERWRITE fn::validation_extension(
    $value: option<any>, $field: string,
    $allowed_extensions: option<array<string>>, $allow_leading_dot: bool
) -> string {
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };
    IF $value IS NONE { THROW string::concat($clean_field, "_REQUIRED"); };
    IF type::is_null($value) { THROW string::concat($clean_field, "_NULL_NOT_ALLOWED"); };
    IF !type::is_string($value) { THROW string::concat($clean_field, "_INVALID_TYPE"); };
    LET $clean_value = string::lowercase(string::trim($value));
    IF $clean_value = "" { THROW string::concat($clean_field, "_BLANK_NOT_ALLOWED"); };
    LET $valid = IF $allow_leading_dot {
        string::matches($clean_value, "^\\.[a-z0-9][a-z0-9._-]*$")
    } ELSE {
        string::matches($clean_value, "^[a-z0-9][a-z0-9._-]*$")
    };
    IF !$valid { THROW string::concat($clean_field, "_INVALID_EXTENSION"); };
    IF $allowed_extensions IS NOT NONE {
        IF array::len($allowed_extensions) = 0 { THROW "VALIDATION_EMPTY_ALLOWED_EXTENSIONS"; };
        LET $allowed = array::map($allowed_extensions, |$ext| string::lowercase(string::trim($ext)));
        IF !array::contains($allowed, $clean_value) {
            THROW string::concat($clean_field, "_EXTENSION_NOT_ALLOWED");
        };
    };
    RETURN $clean_value;
}
COMMENT "Valide et normalise une extension de fichier."
PERMISSIONS FULL;
