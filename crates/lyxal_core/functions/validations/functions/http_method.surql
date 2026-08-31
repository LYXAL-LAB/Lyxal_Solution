-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/http_method.surql
-- Fonction     : fn::validation_http_method
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide et normalise une méthode HTTP selon une liste facultative.
--
-- Permissions
-- -----------
-- PERMISSIONS FULL
--
-- Primitive sans accès persistant, sans appel réseau et sans effet secondaire.
--
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::uppercase()
--   - string::matches()
--   - array::contains()
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_http_method($value: option<any>, $field: string, $allowed_methods: option<array<string>>) -> string {
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };
    IF $value IS NONE { THROW string::concat($clean_field, "_REQUIRED"); };
    IF type::is_null($value) { THROW string::concat($clean_field, "_NULL_NOT_ALLOWED"); };
    IF !type::is_string($value) { THROW string::concat($clean_field, "_INVALID_TYPE"); };
    LET $clean_value = string::trim($value);
    IF $clean_value = "" { THROW string::concat($clean_field, "_BLANK_NOT_ALLOWED"); };
    LET $method = string::uppercase($clean_value);
    IF !string::matches($method, "^[A-Z]+$") { THROW string::concat($clean_field, "_INVALID_HTTP_METHOD"); };
    IF $allowed_methods IS NOT NONE {
        IF array::len($allowed_methods) = 0 { THROW "VALIDATION_EMPTY_ALLOWED_HTTP_METHODS"; };
        LET $allowed = array::map($allowed_methods, |$item| string::uppercase(string::trim($item)));
        IF !array::contains($allowed, $method) { THROW string::concat($clean_field, "_HTTP_METHOD_NOT_ALLOWED"); };
    };
    RETURN $method;
}
COMMENT "Valide et normalise une méthode HTTP."
PERMISSIONS FULL;
