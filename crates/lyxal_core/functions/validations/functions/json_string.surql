-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/json_string.surql
-- Fonction     : fn::validation_json_string
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide et décode une chaîne JSON vers une valeur SurrealQL.
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
--   - string::trim()
--   - type::is_string()
-- Requiert SurrealDB 3.1.0 ou supérieur.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_json_string($value: option<any>, $field: string) -> any {
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };
    IF $value IS NONE { THROW string::concat($clean_field, "_REQUIRED"); };
    IF type::is_null($value) { THROW string::concat($clean_field, "_NULL_NOT_ALLOWED"); };
    IF !type::is_string($value) { THROW string::concat($clean_field, "_INVALID_TYPE"); };
    LET $clean_value = string::trim($value);
    IF $clean_value = "" { THROW string::concat($clean_field, "_BLANK_NOT_ALLOWED"); };
    RETURN encoding::json::decode($clean_value);
}
COMMENT "Valide et décode une chaîne JSON."
PERMISSIONS FULL;
