-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/api_key.surql
-- Fonction     : fn::validation_api_key
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide lexicalement une clé API opaque avec préfixes et longueur configurables.
--
-- Permissions
-- -----------
-- PERMISSIONS FULL
--
-- Primitive sans accès persistant, sans appel réseau et sans effet secondaire.
--
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::matches()
--   - string::starts_with()
--   - array::any()
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_api_key($value: option<any>, $field: string, $allowed_prefixes: option<array<string>>, $min_length: int, $max_length: int) -> string {
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };
    IF $min_length < 1 OR $max_length < 1 OR $min_length > $max_length { THROW "VALIDATION_INVALID_API_KEY_LENGTH_RANGE"; };
    LET $prefixes = IF $allowed_prefixes IS NONE { NONE } ELSE { array::map($allowed_prefixes, |$prefix| string::trim($prefix)) };
    IF $prefixes IS NOT NONE AND array::len($prefixes) = 0 { THROW "VALIDATION_EMPTY_API_KEY_PREFIXES"; };
    IF $value IS NONE { THROW string::concat($clean_field, "_REQUIRED"); };
    IF type::is_null($value) { THROW string::concat($clean_field, "_NULL_NOT_ALLOWED"); };
    IF !type::is_string($value) { THROW string::concat($clean_field, "_INVALID_TYPE"); };
    LET $clean_value = string::trim($value); LET $length = string::len($clean_value);
    IF $length < $min_length { THROW string::concat($clean_field, "_TOO_SHORT"); };
    IF $length > $max_length { THROW string::concat($clean_field, "_TOO_LONG"); };
    IF !string::matches($clean_value, "^[A-Za-z0-9._-]+$") { THROW string::concat($clean_field, "_INVALID_API_KEY"); };
    IF $prefixes IS NOT NONE AND !array::any($prefixes, |$prefix| string::starts_with($clean_value, $prefix)) { THROW string::concat($clean_field, "_API_KEY_PREFIX_NOT_ALLOWED"); };
    RETURN $clean_value;
}
COMMENT "Valide la forme d'une clé API; son existence et ses droits ne sont pas vérifiés." PERMISSIONS FULL;
