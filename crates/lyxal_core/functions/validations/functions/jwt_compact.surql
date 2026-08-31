-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/jwt_compact.surql
-- Fonction     : fn::validation_jwt_compact
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide uniquement la forme compacte d’un JWT à trois segments Base64URL.
--
-- Permissions
-- -----------
-- PERMISSIONS FULL
--
-- Primitive sans accès persistant, sans appel réseau et sans effet secondaire.
--
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::split()
--   - string::matches()
--   - array::all()
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_jwt_compact($value: option<any>, $field: string, $max_length: int) -> string {
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };
    IF $value IS NONE { THROW string::concat($clean_field, "_REQUIRED"); };
    IF type::is_null($value) { THROW string::concat($clean_field, "_NULL_NOT_ALLOWED"); };
    IF !type::is_string($value) { THROW string::concat($clean_field, "_INVALID_TYPE"); };
    LET $clean_value = string::trim($value);
    IF $clean_value = "" { THROW string::concat($clean_field, "_BLANK_NOT_ALLOWED"); };
    IF $max_length < 1 { THROW "VALIDATION_INVALID_JWT_MAX_LENGTH"; };
    IF string::len($clean_value) > $max_length { THROW string::concat($clean_field, "_JWT_TOO_LONG"); };
    LET $segments = string::split($clean_value, ".");
    IF array::len($segments) != 3 OR !array::all($segments, |$segment| $segment != "" AND string::matches($segment, "^[A-Za-z0-9_-]+$")) { THROW string::concat($clean_field, "_INVALID_JWT_FORMAT"); };
    RETURN $clean_value;
}
COMMENT "Valide uniquement la forme compacte d'un JWT; aucune signature n'est vérifiée."
PERMISSIONS FULL;
