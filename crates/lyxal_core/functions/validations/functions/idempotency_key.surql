-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/idempotency_key.surql
-- Fonction     : fn::validation_idempotency_key
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide une clé d’idempotence HTTP opaque en ASCII visible.
--
-- Permissions
-- -----------
-- PERMISSIONS FULL
--
-- Primitive sans accès persistant, sans appel réseau et sans effet secondaire.
--
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::is_ascii()
--   - string::matches()
--   - string::len()
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_idempotency_key($value: option<any>, $field: string, $min_length: int, $max_length: int) -> string {
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };
    IF $min_length < 1 OR $max_length < 1 OR $min_length > $max_length { THROW "VALIDATION_INVALID_IDEMPOTENCY_LENGTH_RANGE"; };
    IF $value IS NONE { THROW string::concat($clean_field, "_REQUIRED"); };
    IF type::is_null($value) { THROW string::concat($clean_field, "_NULL_NOT_ALLOWED"); };
    IF !type::is_string($value) { THROW string::concat($clean_field, "_INVALID_TYPE"); };
    LET $clean_value = string::trim($value); LET $length = string::len($clean_value);
    IF $length < $min_length { THROW string::concat($clean_field, "_TOO_SHORT"); };
    IF $length > $max_length { THROW string::concat($clean_field, "_TOO_LONG"); };
    IF !string::is_ascii($clean_value) OR !string::matches($clean_value, "^[A-Za-z0-9._~:-]+$") { THROW string::concat($clean_field, "_INVALID_IDEMPOTENCY_KEY"); };
    RETURN $clean_value;
}
COMMENT "Valide la forme d'une clé d'idempotence; l'unicité doit être gérée par la logique métier." PERMISSIONS FULL;
