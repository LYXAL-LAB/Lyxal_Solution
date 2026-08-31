-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/bearer_token.surql
-- Fonction     : fn::validation_bearer_token
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide un en-tête Authorization Bearer et retourne uniquement le jeton.
--
-- Permissions
-- -----------
-- PERMISSIONS FULL
--
-- Primitive sans accès persistant, sans appel réseau et sans effet secondaire.
--
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::starts_with()
--   - string::slice()
--   - string::matches()
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_bearer_token($value: option<any>, $field: string, $min_length: int, $max_length: int) -> string {
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };
    IF $min_length < 1 OR $max_length < 1 OR $min_length > $max_length { THROW "VALIDATION_INVALID_BEARER_LENGTH_RANGE"; };
    IF $value IS NONE { THROW string::concat($clean_field, "_REQUIRED"); };
    IF type::is_null($value) { THROW string::concat($clean_field, "_NULL_NOT_ALLOWED"); };
    IF !type::is_string($value) { THROW string::concat($clean_field, "_INVALID_TYPE"); };
    LET $clean_value = string::trim($value);
    IF !string::starts_with($clean_value, "Bearer ") { THROW string::concat($clean_field, "_INVALID_BEARER_FORMAT"); };
    LET $token = string::trim(string::slice($clean_value, 7));
    IF $token = "" OR !string::matches($token, "^[A-Za-z0-9._~+/-]+=*$") { THROW string::concat($clean_field, "_INVALID_BEARER_FORMAT"); };
    LET $length = string::len($token);
    IF $length < $min_length { THROW string::concat($clean_field, "_TOKEN_TOO_SHORT"); };
    IF $length > $max_length { THROW string::concat($clean_field, "_TOKEN_TOO_LONG"); };
    RETURN $token;
}
COMMENT "Valide un en-tête Bearer et retourne le jeton." PERMISSIONS FULL;
