-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/datetime_string.surql
-- Fonction     : fn::validation_datetime_string
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide une chaîne représentant un datetime reconnu par SurrealDB, avec format personnalisé facultatif.
--
-- Règles appliquées
-- -----------------
--   1. Sans format, la chaîne doit pouvoir être interprétée comme datetime.
--   2. Avec un format, la chaîne doit correspondre exactement au format fourni.
--   3. La fonction ne convertit pas la chaîne en datetime.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $format: option<string>
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_BLANK_NOT_ALLOWED
-- <FIELD>_INVALID_DATETIME_STRING
-- VALIDATION_INVALID_DATETIME_FORMAT
--
-- Erreurs communes
-- ----------------
-- <FIELD>_REQUIRED
-- <FIELD>_NULL_NOT_ALLOWED
-- <FIELD>_INVALID_TYPE
-- VALIDATION_INVALID_FIELD_NAME
--
-- Permissions
-- -----------
-- PERMISSIONS FULL
--
-- Cette fonction est une primitive pure. Elle ne consulte ni ne modifie
-- aucune donnée persistante et ne contacte aucun service externe.
--
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::trim()
--   - string::is_datetime()
--   - string::concat()
--   - type::is_null()
--   - type::is_string()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_datetime_string(
    $value: option<any>,
    $field: string,
    $format: option<string>
) -> string {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    IF $value IS NONE {
        THROW string::concat($clean_field, "_REQUIRED");
    };

    IF type::is_null($value) {
        THROW string::concat($clean_field, "_NULL_NOT_ALLOWED");
    };

    IF !type::is_string($value) {
        THROW string::concat($clean_field, "_INVALID_TYPE");
    };

    LET $clean_value = string::trim($value);

    IF $clean_value = "" {
        THROW string::concat($clean_field, "_BLANK_NOT_ALLOWED");
    };

    IF $format IS NOT NONE AND string::trim($format) = "" {
        THROW "VALIDATION_INVALID_DATETIME_FORMAT";
    };

    LET $is_valid = IF $format IS NONE {
        string::is_datetime($clean_value)
    } ELSE {
        string::is_datetime($clean_value, string::trim($format))
    };

    IF !$is_valid {
        THROW string::concat($clean_field, "_INVALID_DATETIME_STRING");
    };

    RETURN $clean_value;
}
COMMENT "
Valide une chaîne datetime selon le format natif ou un format explicite.
"
PERMISSIONS FULL;
