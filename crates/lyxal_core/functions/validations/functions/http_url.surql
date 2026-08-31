-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- Version 1.0.0 — PERMISSIONS FULL
-- ============================================================================
-- Fonction : fn::validation_http_url
DEFINE FUNCTION OVERWRITE fn::validation_http_url(
    $value: option<any>, $field: string, $allow_http: bool, $allow_https: bool
) -> string {
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };
    IF !$allow_http AND !$allow_https { THROW "VALIDATION_NO_HTTP_SCHEME_ALLOWED"; };
    IF $value IS NONE { THROW string::concat($clean_field, "_REQUIRED"); };
    IF type::is_null($value) { THROW string::concat($clean_field, "_NULL_NOT_ALLOWED"); };
    IF !type::is_string($value) { THROW string::concat($clean_field, "_INVALID_TYPE"); };
    LET $clean_value = string::trim($value);
    IF $clean_value = "" { THROW string::concat($clean_field, "_BLANK_NOT_ALLOWED"); };
    LET $lower = string::lowercase($clean_value);
    LET $is_http = string::starts_with($lower, "http://");
    LET $is_https = string::starts_with($lower, "https://");
    IF ($is_http AND !$allow_http) OR ($is_https AND !$allow_https) OR (!$is_http AND !$is_https) {
        THROW string::concat($clean_field, "_INVALID_HTTP_SCHEME");
    };
    IF !string::is_url($clean_value) { THROW string::concat($clean_field, "_INVALID_HTTP_URL"); };
    RETURN $clean_value;
}
COMMENT "Valide une URL absolue utilisant HTTP ou HTTPS."
PERMISSIONS FULL;
