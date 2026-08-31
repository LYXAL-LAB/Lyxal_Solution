-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/json_array_string.surql
-- Fonction     : fn::validation_json_array_string
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide une chaîne JSON dont la racine est un tableau, avec longueur facultative.
--
-- Permissions
-- -----------
-- PERMISSIONS FULL
--
-- Primitive sans accès persistant, sans appel réseau et sans effet secondaire.
--
-- Dépendances natives SurrealDB
-- -----------------------------
--   - encoding::json::decode()
--   - type::is_array()
--   - array::len()
-- Requiert SurrealDB 3.1.0 ou supérieur.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_json_array_string($value: option<any>, $field: string, $allow_empty: bool, $min_length: option<int>, $max_length: option<int>) -> array {
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };
    IF $min_length IS NOT NONE AND $min_length < 0 { THROW "VALIDATION_INVALID_JSON_ARRAY_LENGTH_RANGE"; };
    IF $max_length IS NOT NONE AND $max_length < 0 { THROW "VALIDATION_INVALID_JSON_ARRAY_LENGTH_RANGE"; };
    IF $min_length IS NOT NONE AND $max_length IS NOT NONE AND $min_length > $max_length { THROW "VALIDATION_INVALID_JSON_ARRAY_LENGTH_RANGE"; };
    IF $value IS NONE { THROW string::concat($clean_field, "_REQUIRED"); };
    IF type::is_null($value) { THROW string::concat($clean_field, "_NULL_NOT_ALLOWED"); };
    IF !type::is_string($value) { THROW string::concat($clean_field, "_INVALID_TYPE"); };
    LET $clean_value = string::trim($value);
    IF $clean_value = "" { THROW string::concat($clean_field, "_BLANK_NOT_ALLOWED"); };
    LET $decoded = encoding::json::decode($clean_value);
    IF !type::is_array($decoded) { THROW string::concat($clean_field, "_JSON_ROOT_NOT_ARRAY"); };
    LET $length = array::len($decoded);
    IF !$allow_empty AND $length = 0 { THROW string::concat($clean_field, "_EMPTY_ARRAY_NOT_ALLOWED"); };
    IF $min_length IS NOT NONE AND $length < $min_length { THROW string::concat($clean_field, "_TOO_SHORT"); };
    IF $max_length IS NOT NONE AND $length > $max_length { THROW string::concat($clean_field, "_TOO_LONG"); };
    RETURN $decoded;
}
COMMENT "Valide un tableau JSON textuel et retourne le tableau décodé."
PERMISSIONS FULL;
