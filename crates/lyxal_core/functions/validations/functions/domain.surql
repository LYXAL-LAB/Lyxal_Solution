-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- Version 1.0.0 — PERMISSIONS FULL
-- ============================================================================
-- Fonction : fn::validation_domain
DEFINE FUNCTION OVERWRITE fn::validation_domain(
    $value: option<any>, $field: string, $allow_subdomains: bool
) -> string {
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };
    IF $value IS NONE { THROW string::concat($clean_field, "_REQUIRED"); };
    IF type::is_null($value) { THROW string::concat($clean_field, "_NULL_NOT_ALLOWED"); };
    IF !type::is_string($value) { THROW string::concat($clean_field, "_INVALID_TYPE"); };
    LET $clean_value = string::lowercase(string::trim($value));
    IF $clean_value = "" { THROW string::concat($clean_field, "_BLANK_NOT_ALLOWED"); };
    IF !string::is_domain($clean_value) { THROW string::concat($clean_field, "_INVALID_DOMAIN"); };
    IF !$allow_subdomains {
        LET $labels = string::split($clean_value, ".");
        IF array::len($labels) != 2 { THROW string::concat($clean_field, "_SUBDOMAIN_NOT_ALLOWED"); };
    };
    RETURN $clean_value;
}
COMMENT "Valide et normalise un nom de domaine, avec sous-domaines facultatifs."
PERMISSIONS FULL;
