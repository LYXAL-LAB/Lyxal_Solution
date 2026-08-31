-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/json_object_string.surql
-- Fonction     : fn::validation_json_object_string
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide une chaîne JSON dont la racine est un objet.
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
--   - type::is_object()
--   - object::is_empty()
-- Requiert SurrealDB 3.1.0 ou supérieur.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_json_object_string($value: option<any>, $field: string, $allow_empty: bool) -> object {
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };
    IF $value IS NONE { THROW string::concat($clean_field, "_REQUIRED"); };
    IF type::is_null($value) { THROW string::concat($clean_field, "_NULL_NOT_ALLOWED"); };
    IF !type::is_string($value) { THROW string::concat($clean_field, "_INVALID_TYPE"); };
    LET $clean_value = string::trim($value);
    IF $clean_value = "" { THROW string::concat($clean_field, "_BLANK_NOT_ALLOWED"); };
    LET $decoded = encoding::json::decode($clean_value);
    IF !type::is_object($decoded) { THROW string::concat($clean_field, "_JSON_ROOT_NOT_OBJECT"); };
    IF !$allow_empty AND object::is_empty($decoded) { THROW string::concat($clean_field, "_EMPTY_OBJECT_NOT_ALLOWED"); };
    RETURN $decoded;
}
COMMENT "Valide un objet JSON textuel et retourne l'objet décodé."
PERMISSIONS FULL;
